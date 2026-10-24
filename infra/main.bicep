// Azure DNS Private Resolver regional failover lab - recommended architecture.
//
// Multi-region hub-spoke (Cloud Adoption Framework):
//   * One hub per region with a DNS Private Resolver (static inbound endpoint), a regional
//     forwarding ruleset, a dnsmasq "on-premises DNS" simulator and a Linux router (NVA).
//   * One spoke per region, peered ONLY to its regional hub. Spokes use custom DNS
//     [local inbound IP, remote inbound IP] so clients fail over between resolvers.
//   * Hubs are globally peered to each other. Peering is non-transitive, so spoke-to-remote
//     traffic is steered through the regional NVAs with UDRs (Learn: firewall-multi-hub-spoke).
targetScope = 'subscription'

@description('Short prefix used in every resource name.')
@maxLength(8)
param prefix string = 'dnsfo'

@description('Primary region (r1).')
param primaryLocation string = 'eastus2'

@description('Secondary region (r2).')
param secondaryLocation string = 'centralus'

@description('Owner tag value.')
param owner string

@description('TTL tag value (informational).')
param ttlTag string = '7d'

@description('Admin user name for all VMs.')
param adminUsername string = 'azureuser'

@description('SSH public key for Linux VMs.')
@secure()
param sshPublicKey string

@description('Admin password for Windows clients (required when deployWindows = true).')
@secure()
param windowsAdminPassword string = ''

@description('Deploy a Windows client in each spoke.')
param deployWindows bool = true

@description('Linux VM size.')
param linuxVmSize string = 'Standard_B2ats_v2'

@description('Windows VM size.')
param windowsVmSize string = 'Standard_B2as_v2'

@description('Enable daily auto-shutdown on every VM.')
param enableAutoShutdown bool = true

@description('Auto-shutdown time (UTC, HHmm).')
param autoShutdownTimeUtc string = '0300'

@description('Enable DNS security policy query logging to Log Analytics.')
param enableDnsQueryLogs bool = true

@description('Short TTL (seconds) for app1.')
param shortTtl int = 10

@description('Long TTL (seconds) for app2.')
param longTtl int = 3600

@description('Attach an NSG to the resolver subnets (required for the F1 fault injection).')
param attachResolverSubnetNsg bool = true

@description('Attach the hub route table to the resolver subnets (return path for cross-region queries).')
param attachResolverSubnetRouteTable bool = true

var tags = {
  purpose: 'dns-resolver-failover-lab'
  owner: owner
  ttl: ttlTag
}

var suffix = take(uniqueString(subscription().id, prefix), 6)

var r1 = {
  tag: 'r1'
  location: primaryLocation
  hub: '10.10.0.0/22'
  inbound: '10.10.0.0/28'
  inboundIp: '10.10.0.4'
  outbound: '10.10.0.16/28'
  workload: '10.10.1.0/24'
  pe: '10.10.2.0/24'
  gw: '10.10.3.0/27'
  nva: '10.10.3.64/27'
  nvaIp: '10.10.3.68'
  spoke: '10.11.1.0/24'
  onprem: '10.110.0.0/16'
  summaries: [
    '10.10.0.0/16'
    '10.11.0.0/16'
    '10.110.0.0/16'
  ]
  dnsmasqIp: '10.10.1.10'
  whoami: '10.255.1.1'
  onpremAnswer: '192.168.10.1'
}

var r2 = {
  tag: 'r2'
  location: secondaryLocation
  hub: '10.20.0.0/22'
  inbound: '10.20.0.0/28'
  inboundIp: '10.20.0.4'
  outbound: '10.20.0.16/28'
  workload: '10.20.1.0/24'
  pe: '10.20.2.0/24'
  gw: '10.20.3.0/27'
  nva: '10.20.3.64/27'
  nvaIp: '10.20.3.68'
  spoke: '10.21.1.0/24'
  onprem: '10.120.0.0/16'
  summaries: [
    '10.20.0.0/16'
    '10.21.0.0/16'
    '10.120.0.0/16'
  ]
  dnsmasqIp: '10.20.1.10'
  whoami: '10.255.2.2'
  onpremAnswer: '192.168.20.2'
}

var rgSharedName = 'rg-${prefix}-shared'
var rgR1Name = 'rg-${prefix}-r1'
var rgR2Name = 'rg-${prefix}-r2'

var hubR1Name = 'vnet-${prefix}-hub-r1'
var hubR2Name = 'vnet-${prefix}-hub-r2'
var spokeR1Name = 'vnet-${prefix}-spoke-r1'
var spokeR2Name = 'vnet-${prefix}-spoke-r2'

var hubR1Id = resourceId(subscription().subscriptionId, rgR1Name, 'Microsoft.Network/virtualNetworks', hubR1Name)
var hubR2Id = resourceId(subscription().subscriptionId, rgR2Name, 'Microsoft.Network/virtualNetworks', hubR2Name)
var spokeR1Id = resourceId(subscription().subscriptionId, rgR1Name, 'Microsoft.Network/virtualNetworks', spokeR1Name)
var spokeR2Id = resourceId(subscription().subscriptionId, rgR2Name, 'Microsoft.Network/virtualNetworks', spokeR2Name)

var dnsmasqCloudInit = '''#cloud-config
package_update: true
packages:
  - dnsmasq
write_files:
  - path: /etc/dnsmasq.d/onprem.conf
    content: |
      no-resolv
      listen-address=__LISTEN_IP__
      bind-interfaces
      address=/onprem.contoso.internal/__ANSWER__
      log-queries
runcmd:
  - systemctl restart dnsmasq
'''

var nvaCloudInit = '''#cloud-config
package_update: true
packages:
  - tcpdump
  - traceroute
write_files:
  - path: /etc/sysctl.d/99-ipforward.conf
    content: |
      net.ipv4.ip_forward=1
runcmd:
  - sysctl --system
'''

var linuxClientCloudInit = '''#cloud-config
package_update: true
packages:
  - bind9-dnsutils
  - tcpdump
  - python3
  - jq
  - curl
  - traceroute
runcmd:
  - mkdir -p /opt/dnsprobe /var/log/dnsprobe
'''

// ---------------------------------------------------------------- resource groups
resource rgShared 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgSharedName
  location: primaryLocation
  tags: tags
}

resource rgR1 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgR1Name
  location: primaryLocation
  tags: tags
}

resource rgR2 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgR2Name
  location: secondaryLocation
  tags: tags
}

// ---------------------------------------------------------------- hubs
module hubR1 'modules/hub.bicep' = {
  name: 'hub-r1'
  scope: rgR1
  params: {
    location: r1.location
    prefix: prefix
    regionTag: r1.tag
    addressPrefix: r1.hub
    inboundSubnetPrefix: r1.inbound
    inboundIp: r1.inboundIp
    outboundSubnetPrefix: r1.outbound
    workloadSubnetPrefix: r1.workload
    peSubnetPrefix: r1.pe
    gatewaySubnetPrefix: r1.gw
    nvaSubnetPrefix: r1.nva
    localNvaIp: r1.nvaIp
    remoteNvaIp: r2.nvaIp
    remoteSummaries: r2.summaries
    attachResolverSubnetNsg: attachResolverSubnetNsg
    attachResolverSubnetRouteTable: attachResolverSubnetRouteTable
    tags: tags
  }
}

module hubR2 'modules/hub.bicep' = {
  name: 'hub-r2'
  scope: rgR2
  params: {
    location: r2.location
    prefix: prefix
    regionTag: r2.tag
    addressPrefix: r2.hub
    inboundSubnetPrefix: r2.inbound
    inboundIp: r2.inboundIp
    outboundSubnetPrefix: r2.outbound
    workloadSubnetPrefix: r2.workload
    peSubnetPrefix: r2.pe
    gatewaySubnetPrefix: r2.gw
    nvaSubnetPrefix: r2.nva
    localNvaIp: r2.nvaIp
    remoteNvaIp: r1.nvaIp
    remoteSummaries: r1.summaries
    attachResolverSubnetNsg: attachResolverSubnetNsg
    attachResolverSubnetRouteTable: attachResolverSubnetRouteTable
    tags: tags
  }
}

// ---------------------------------------------------------------- spokes
module spokeR1 'modules/spoke.bicep' = {
  name: 'spoke-r1'
  scope: rgR1
  params: {
    location: r1.location
    prefix: prefix
    regionTag: r1.tag
    addressPrefix: r1.spoke
    subnetPrefix: r1.spoke
    dnsServers: [
      r1.inboundIp
      r2.inboundIp
    ]
    routes: [
      for p in concat(r2.summaries, [r1.onprem]): {
        name: 'via-nva-${replace(replace(p, '.', '-'), '/', '_')}'
        addressPrefix: p
        nextHopType: 'VirtualAppliance'
        nextHopIpAddress: r1.nvaIp
      }
    ]
    tags: tags
  }
}

module spokeR2 'modules/spoke.bicep' = {
  name: 'spoke-r2'
  scope: rgR2
  params: {
    location: r2.location
    prefix: prefix
    regionTag: r2.tag
    addressPrefix: r2.spoke
    subnetPrefix: r2.spoke
    dnsServers: [
      r2.inboundIp
      r1.inboundIp
    ]
    routes: [
      for p in concat(r1.summaries, [r2.onprem]): {
        name: 'via-nva-${replace(replace(p, '.', '-'), '/', '_')}'
        addressPrefix: p
        nextHopType: 'VirtualAppliance'
        nextHopIpAddress: r2.nvaIp
      }
    ]
    tags: tags
  }
}

// ---------------------------------------------------------------- peerings
// hub <-> hub (global) and spoke <-> own hub only. No spoke-to-remote-hub peering.
var peerings = [
  { rg: rgR1Name, local: hubR1Name, remote: hubR2Id, name: 'to-hub-r2' }
  { rg: rgR2Name, local: hubR2Name, remote: hubR1Id, name: 'to-hub-r1' }
  { rg: rgR1Name, local: spokeR1Name, remote: hubR1Id, name: 'to-hub-r1' }
  { rg: rgR1Name, local: hubR1Name, remote: spokeR1Id, name: 'to-spoke-r1' }
  { rg: rgR2Name, local: spokeR2Name, remote: hubR2Id, name: 'to-hub-r2' }
  { rg: rgR2Name, local: hubR2Name, remote: spokeR2Id, name: 'to-spoke-r2' }
]

@batchSize(1)
module peering 'modules/peering.bicep' = [
  for (p, i) in peerings: {
    name: 'peer-${i}-${p.name}'
    scope: resourceGroup(p.rg)
    params: {
      localVnetName: p.local
      remoteVnetId: p.remote
      peeringName: p.name
      allowForwardedTraffic: true
    }
    dependsOn: [
      hubR1
      hubR2
      spokeR1
      spokeR2
    ]
  }
]

// ---------------------------------------------------------------- private DNS zones
var hubLinks = [
  { name: 'hub-r1', vnetId: hubR1Id }
  { name: 'hub-r2', vnetId: hubR2Id }
]

module zoneApp 'modules/privatezone.bicep' = {
  name: 'zone-azure-contoso-internal'
  scope: rgShared
  params: {
    zoneName: 'azure.contoso.internal'
    aRecords: [
      { name: 'app1', ip: '10.50.0.1', ttl: shortTtl }
      { name: 'app2', ip: '10.50.0.2', ttl: longTtl }
    ]
    links: hubLinks
    tags: tags
  }
  dependsOn: [
    hubR1
    hubR2
  ]
}

module zoneBlob 'modules/privatezone.bicep' = {
  name: 'zone-privatelink-blob'
  scope: rgShared
  params: {
    #disable-next-line no-hardcoded-env-urls
    zoneName: 'privatelink.blob.core.windows.net'
    aRecords: []
    links: hubLinks
    tags: tags
  }
  dependsOn: [
    hubR1
    hubR2
  ]
}

// Same zone name in each region with a different answer: proves which resolver answered.
module zoneLabR1 'modules/privatezone.bicep' = {
  name: 'zone-lab-r1'
  scope: rgR1
  params: {
    zoneName: 'lab.contoso.internal'
    aRecords: [
      { name: 'whoami', ip: r1.whoami, ttl: shortTtl }
    ]
    links: [
      { name: 'hub-r1', vnetId: hubR1Id }
    ]
    tags: tags
  }
  dependsOn: [
    hubR1
  ]
}

module zoneLabR2 'modules/privatezone.bicep' = {
  name: 'zone-lab-r2'
  scope: rgR2
  params: {
    zoneName: 'lab.contoso.internal'
    aRecords: [
      { name: 'whoami', ip: r2.whoami, ttl: shortTtl }
    ]
    links: [
      { name: 'hub-r2', vnetId: hubR2Id }
    ]
    tags: tags
  }
  dependsOn: [
    hubR2
  ]
}

// ---------------------------------------------------------------- forwarding rulesets
module rsHubR1 'modules/ruleset.bicep' = {
  name: 'rs-hub-r1'
  scope: rgR1
  params: {
    location: r1.location
    name: 'dnsfrs-${prefix}-hub-r1'
    outboundEndpointId: hubR1.outputs.outboundEndpointId
    rules: [
      { name: 'onprem', domain: 'onprem.contoso.internal.', targets: [r1.dnsmasqIp] }
    ]
    links: [
      { name: 'hub-r1', vnetId: hubR1Id }
    ]
    tags: tags
  }
}

module rsHubR2 'modules/ruleset.bicep' = {
  name: 'rs-hub-r2'
  scope: rgR2
  params: {
    location: r2.location
    name: 'dnsfrs-${prefix}-hub-r2'
    outboundEndpointId: hubR2.outputs.outboundEndpointId
    rules: [
      { name: 'onprem', domain: 'onprem.contoso.internal.', targets: [r2.dnsmasqIp] }
    ]
    links: [
      { name: 'hub-r2', vnetId: hubR2Id }
    ]
    tags: tags
  }
}

// ---------------------------------------------------------------- storage + private endpoints
module saR1 'modules/storage-pe.bicep' = {
  name: 'sa-pe-r1'
  scope: rgR1
  params: {
    location: r1.location
    name: 'st${prefix}r1${suffix}'
    peSubnetId: hubR1.outputs.peSubnetId
    blobZoneId: zoneBlob.outputs.zoneId
    tags: tags
  }
}

module saR2 'modules/storage-pe.bicep' = {
  name: 'sa-pe-r2'
  scope: rgR2
  params: {
    location: r2.location
    name: 'st${prefix}r2${suffix}'
    peSubnetId: hubR2.outputs.peSubnetId
    blobZoneId: zoneBlob.outputs.zoneId
    tags: tags
  }
}

// ---------------------------------------------------------------- hub VMs (dnsmasq + NVA)
module dnsmasqR1 'modules/vm.bicep' = {
  name: 'vm-dnsmasq-r1'
  scope: rgR1
  params: {
    location: r1.location
    name: 'vm-${prefix}-dnsmasq-r1'
    subnetId: hubR1.outputs.workloadSubnetId
    osType: 'linux'
    vmSize: linuxVmSize
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    privateIp: r1.dnsmasqIp
    customData: replace(replace(dnsmasqCloudInit, '__LISTEN_IP__', r1.dnsmasqIp), '__ANSWER__', r1.onpremAnswer)
    enableAutoShutdown: enableAutoShutdown
    autoShutdownTime: autoShutdownTimeUtc
    tags: union(tags, { role: 'onprem-dns-sim' })
  }
}

module dnsmasqR2 'modules/vm.bicep' = {
  name: 'vm-dnsmasq-r2'
  scope: rgR2
  params: {
    location: r2.location
    name: 'vm-${prefix}-dnsmasq-r2'
    subnetId: hubR2.outputs.workloadSubnetId
    osType: 'linux'
    vmSize: linuxVmSize
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    privateIp: r2.dnsmasqIp
    customData: replace(replace(dnsmasqCloudInit, '__LISTEN_IP__', r2.dnsmasqIp), '__ANSWER__', r2.onpremAnswer)
    enableAutoShutdown: enableAutoShutdown
    autoShutdownTime: autoShutdownTimeUtc
    tags: union(tags, { role: 'onprem-dns-sim' })
  }
}

module nvaR1 'modules/vm.bicep' = {
  name: 'vm-nva-r1'
  scope: rgR1
  params: {
    location: r1.location
    name: 'vm-${prefix}-nva-r1'
    subnetId: hubR1.outputs.nvaSubnetId
    osType: 'linux'
    vmSize: linuxVmSize
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    privateIp: r1.nvaIp
    customData: nvaCloudInit
    enableIpForwarding: true
    enableAutoShutdown: enableAutoShutdown
    autoShutdownTime: autoShutdownTimeUtc
    tags: union(tags, { role: 'router' })
  }
}

module nvaR2 'modules/vm.bicep' = {
  name: 'vm-nva-r2'
  scope: rgR2
  params: {
    location: r2.location
    name: 'vm-${prefix}-nva-r2'
    subnetId: hubR2.outputs.nvaSubnetId
    osType: 'linux'
    vmSize: linuxVmSize
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    privateIp: r2.nvaIp
    customData: nvaCloudInit
    enableIpForwarding: true
    enableAutoShutdown: enableAutoShutdown
    autoShutdownTime: autoShutdownTimeUtc
    tags: union(tags, { role: 'router' })
  }
}

// ---------------------------------------------------------------- spoke clients
module lnxR1 'modules/vm.bicep' = {
  name: 'vm-lnx-r1'
  scope: rgR1
  params: {
    location: r1.location
    name: 'vm-${prefix}-lnx-r1'
    subnetId: spokeR1.outputs.subnetId
    osType: 'linux'
    vmSize: linuxVmSize
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    customData: linuxClientCloudInit
    enableAutoShutdown: enableAutoShutdown
    autoShutdownTime: autoShutdownTimeUtc
    tags: union(tags, { design: 'R1', role: 'client' })
  }
}

module lnxR2 'modules/vm.bicep' = {
  name: 'vm-lnx-r2'
  scope: rgR2
  params: {
    location: r2.location
    name: 'vm-${prefix}-lnx-r2'
    subnetId: spokeR2.outputs.subnetId
    osType: 'linux'
    vmSize: linuxVmSize
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    customData: linuxClientCloudInit
    enableAutoShutdown: enableAutoShutdown
    autoShutdownTime: autoShutdownTimeUtc
    tags: union(tags, { design: 'R2', role: 'client' })
  }
}

module winR1 'modules/vm.bicep' = if (deployWindows) {
  name: 'vm-win-r1'
  scope: rgR1
  params: {
    location: r1.location
    name: 'vm-${prefix}-win-r1'
    subnetId: spokeR1.outputs.subnetId
    osType: 'windows'
    vmSize: windowsVmSize
    adminUsername: adminUsername
    adminPassword: windowsAdminPassword
    enableAutoShutdown: enableAutoShutdown
    autoShutdownTime: autoShutdownTimeUtc
    tags: union(tags, { design: 'R1', role: 'client' })
  }
}

module winR2 'modules/vm.bicep' = if (deployWindows) {
  name: 'vm-win-r2'
  scope: rgR2
  params: {
    location: r2.location
    name: 'vm-${prefix}-win-r2'
    subnetId: spokeR2.outputs.subnetId
    osType: 'windows'
    vmSize: windowsVmSize
    adminUsername: adminUsername
    adminPassword: windowsAdminPassword
    enableAutoShutdown: enableAutoShutdown
    autoShutdownTime: autoShutdownTimeUtc
    tags: union(tags, { design: 'R2', role: 'client' })
  }
}

// ---------------------------------------------------------------- monitoring
module shared 'modules/shared.bicep' = {
  name: 'shared'
  scope: rgShared
  params: {
    location: primaryLocation
    prefix: prefix
    ingestPrincipalIds: [
      lnxR1.outputs.principalId
      lnxR2.outputs.principalId
    ]
    extraIngestPrincipalIds: deployWindows
      ? [
          winR1!.outputs.principalId
          winR2!.outputs.principalId
        ]
      : []
    tags: tags
  }
}

module dnsLogR1 'modules/dnslogging.bicep' = if (enableDnsQueryLogs) {
  name: 'dnslog-r1'
  scope: rgR1
  params: {
    location: r1.location
    prefix: prefix
    regionTag: r1.tag
    vnetIds: [hubR1Id]
    extraVnetIds: [spokeR1Id]
    workspaceId: shared.outputs.workspaceId
    tags: tags
  }
  dependsOn: [
    rsHubR1
    peering
  ]
}

module dnsLogR2 'modules/dnslogging.bicep' = if (enableDnsQueryLogs) {
  name: 'dnslog-r2'
  scope: rgR2
  params: {
    location: r2.location
    prefix: prefix
    regionTag: r2.tag
    vnetIds: [hubR2Id]
    extraVnetIds: [spokeR2Id]
    workspaceId: shared.outputs.workspaceId
    tags: tags
  }
  dependsOn: [
    rsHubR2
    peering
  ]
}

// ---------------------------------------------------------------- outputs
output rgShared string = rgSharedName
output rgR1 string = rgR1Name
output rgR2 string = rgR2Name
output inboundIpR1 string = r1.inboundIp
output inboundIpR2 string = r2.inboundIp
output nvaIpR1 string = r1.nvaIp
output nvaIpR2 string = r2.nvaIp
output nvaVmR1 string = nvaR1.outputs.vmName
output nvaVmR2 string = nvaR2.outputs.vmName
output hubR1 string = hubR1Name
output hubR2 string = hubR2Name
output spokeR1 string = spokeR1Name
output spokeR2 string = spokeR2Name
output whoamiR1 string = r1.whoami
output whoamiR2 string = r2.whoami
output blobFqdnR1 string = saR1.outputs.blobFqdn
output blobFqdnR2 string = saR2.outputs.blobFqdn
output workspaceCustomerId string = shared.outputs.workspaceCustomerId
output ingestEndpoint string = shared.outputs.ingestEndpoint
output dcrImmutableId string = shared.outputs.dcrImmutableId
output resolverR1 string = hubR1.outputs.resolverName
output resolverR2 string = hubR2.outputs.resolverName
output linuxClients array = [
  { design: 'r1', vm: lnxR1.outputs.vmName, rg: rgR1Name }
  { design: 'r2', vm: lnxR2.outputs.vmName, rg: rgR2Name }
]
output windowsClients array = deployWindows
  ? [
      { design: 'r1', vm: winR1!.outputs.vmName, rg: rgR1Name }
      { design: 'r2', vm: winR2!.outputs.vmName, rg: rgR2Name }
    ]
  : []
