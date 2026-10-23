targetScope = 'subscription'

// ---------------------------------------------------------------------------------------------
// Azure DNS Private Resolver regional failover lab (Azure-to-Azure).
// Designs A-D are deployed side by side as four spokes in the primary region so that a single
// injected failure is observed by every design at the same time.
// ---------------------------------------------------------------------------------------------

@description('Short prefix for all resource names.')
@maxLength(8)
param prefix string = 'dnsfo'
param primaryLocation string = 'eastus2'
param secondaryLocation string = 'centralus'
param owner string
@description('Tag value telling humans when the lab can be deleted, e.g. 2026-11-30.')
param ttlTag string
param adminUsername string = 'azureuser'
@secure()
param sshPublicKey string
@secure()
@description('One-time generated password for Windows clients. Not stored by the scripts.')
param windowsAdminPassword string = ''
param deployWindows bool = true
param linuxVmSize string = 'Standard_B2ats_v2'
param windowsVmSize string = 'Standard_B2as_v2'
param enableAutoShutdown bool = true
param autoShutdownTimeUtc string = '0300'
param enableDnsQueryLogs bool = true
@description('TTL (s) of app1 / whoami test records. Low on purpose so caches do not hide failover.')
param shortTtl int = 10
@description('TTL (s) of app2, used to show cache masking (H10).')
param longTtl int = 3600
@description('Set false if the platform rejects NSGs on resolver-delegated subnets.')
param attachResolverSubnetNsg bool = true

var tags = {
  purpose: 'dns-resolver-failover-lab'
  owner: owner
  ttl: ttlTag
}

var suffix = take(uniqueString(subscription().id, prefix), 6)

// Address plan -------------------------------------------------------------------------------
var r1 = {
  tag: 'r1'
  location: primaryLocation
  hub: '10.10.0.0/22'
  inbound: '10.10.0.0/28'
  inboundIp: '10.10.0.4'
  outbound: '10.10.0.16/28'
  outbound2: '10.10.0.32/28'
  workload: '10.10.1.0/24'
  pe: '10.10.2.0/24'
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
  outbound2: ''
  workload: '10.20.1.0/24'
  pe: '10.20.2.0/24'
  dnsmasqIp: '10.20.1.10'
  whoami: '10.255.2.2'
  onpremAnswer: '192.168.20.2'
}

var spokes = [
  {
    design: 'a'
    prefix: '10.11.0.0/24'
    dns: [] // Default (Azure-provided)
    windows: false
  }
  {
    design: 'b'
    prefix: '10.11.1.0/24'
    dns: [r1.inboundIp, r2.inboundIp]
    windows: true
  }
  {
    design: 'c'
    prefix: '10.11.2.0/24'
    dns: ['168.63.129.16', r2.inboundIp]
    windows: true
  }
  {
    design: 'd'
    prefix: '10.11.3.0/24'
    dns: [] // Default (Azure-provided) + multi-target ruleset
    windows: false
  }
]

// Resource groups ----------------------------------------------------------------------------
resource rgShared 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefix}-shared'
  location: primaryLocation
  tags: tags
}
resource rgR1 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefix}-r1'
  location: primaryLocation
  tags: tags
}
resource rgR2 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefix}-r2'
  location: secondaryLocation
  tags: tags
}

// Hubs + resolvers ---------------------------------------------------------------------------
module hub1 'modules/hub.bicep' = {
  scope: rgR1
  name: 'hub-r1'
  params: {
    location: r1.location
    prefix: prefix
    regionTag: r1.tag
    addressPrefix: r1.hub
    inboundSubnetPrefix: r1.inbound
    inboundIp: r1.inboundIp
    outboundSubnetPrefix: r1.outbound
    outbound2SubnetPrefix: r1.outbound2
    workloadSubnetPrefix: r1.workload
    peSubnetPrefix: r1.pe
    attachResolverSubnetNsg: attachResolverSubnetNsg
    tags: tags
  }
}

module hub2 'modules/hub.bicep' = {
  scope: rgR2
  name: 'hub-r2'
  params: {
    location: r2.location
    prefix: prefix
    regionTag: r2.tag
    addressPrefix: r2.hub
    inboundSubnetPrefix: r2.inbound
    inboundIp: r2.inboundIp
    outboundSubnetPrefix: r2.outbound
    outbound2SubnetPrefix: r2.outbound2
    workloadSubnetPrefix: r2.workload
    peSubnetPrefix: r2.pe
    attachResolverSubnetNsg: attachResolverSubnetNsg
    tags: tags
  }
}

// Spokes (all in primary region) -------------------------------------------------------------
module spoke 'modules/spoke.bicep' = [
  for s in spokes: {
    scope: rgR1
    name: 'spoke-${s.design}'
    params: {
      location: primaryLocation
      prefix: prefix
      design: s.design
      addressPrefix: s.prefix
      subnetPrefix: s.prefix
      dnsServers: s.dns
      tags: tags
    }
  }
]

// Peerings: hub1<->hub2 (global), every spoke <-> hub1 and every spoke <-> hub2 (global).
// Spoke<->hub2 is required for direct client queries to the secondary inbound endpoint (H8).
var rgR1Name = 'rg-${prefix}-r1'
var rgR2Name = 'rg-${prefix}-r2'
var hub1Name = 'vnet-${prefix}-hub-r1'
var hub2Name = 'vnet-${prefix}-hub-r2'
var hub1Id = resourceId(subscription().subscriptionId, rgR1Name, 'Microsoft.Network/virtualNetworks', hub1Name)
var hub2Id = resourceId(subscription().subscriptionId, rgR2Name, 'Microsoft.Network/virtualNetworks', hub2Name)
var hubPeerings = [
  {
    rg: rgR1Name
    local: hub1Name
    remote: hub2Id
    name: 'to-hub-r2'
  }
  {
    rg: rgR2Name
    local: hub2Name
    remote: hub1Id
    name: 'to-hub-r1'
  }
]
var spokePeerings = flatten(map(
  spokes,
  s => [
    {
      rg: rgR1Name
      local: 'vnet-${prefix}-spoke-${s.design}'
      remote: hub1Id
      name: 'to-hub-r1'
    }
    {
      rg: rgR1Name
      local: hub1Name
      remote: resourceId(subscription().subscriptionId, rgR1Name, 'Microsoft.Network/virtualNetworks', 'vnet-${prefix}-spoke-${s.design}')
      name: 'to-spoke-${s.design}'
    }
    {
      rg: rgR1Name
      local: 'vnet-${prefix}-spoke-${s.design}'
      remote: hub2Id
      name: 'to-hub-r2'
    }
    {
      rg: rgR2Name
      local: hub2Name
      remote: resourceId(subscription().subscriptionId, rgR1Name, 'Microsoft.Network/virtualNetworks', 'vnet-${prefix}-spoke-${s.design}')
      name: 'to-spoke-${s.design}'
    }
  ]
))
// Serial to avoid concurrent-update conflicts on the hub VNets.
@batchSize(1)
module peerings 'modules/peering.bicep' = [
  for (p, i) in concat(hubPeerings, spokePeerings): {
    scope: resourceGroup(p.rg)
    name: 'peer-${i}-${p.name}'
    params: {
      localVnetName: p.local
      remoteVnetId: p.remote
      peeringName: p.name
    }
    dependsOn: [hub1, hub2, spoke]
  }
]

// Private DNS zones ---------------------------------------------------------------------------
var hubLinks = [
  {
    name: 'hub-r1'
    vnetId: hub1.outputs.vnetId
  }
  {
    name: 'hub-r2'
    vnetId: hub2.outputs.vnetId
  }
]

module zoneApp 'modules/privatezone.bicep' = {
  scope: rgShared
  name: 'zone-azure-contoso-internal'
  params: {
    zoneName: 'azure.contoso.internal'
    aRecords: [
      {
        name: 'app1'
        ip: '10.50.0.1'
        ttl: shortTtl
      }
      {
        name: 'app2'
        ip: '10.50.0.2'
        ttl: longTtl
      }
    ]
    links: hubLinks
    tags: tags
  }
}

module zoneBlob 'modules/privatezone.bicep' = {
  scope: rgShared
  name: 'zone-privatelink-blob'
  params: {
    #disable-next-line no-hardcoded-env-urls
    zoneName: 'privatelink.blob.core.windows.net'
    links: hubLinks
    tags: tags
  }
}

// Region identity: two zones with the SAME name in different RGs, each linked to one hub only.
// whoami.lab.contoso.internal therefore proves which region's inbound endpoint answered.
module zoneLabR1 'modules/privatezone.bicep' = {
  scope: rgR1
  name: 'zone-lab-r1'
  params: {
    zoneName: 'lab.contoso.internal'
    aRecords: [
      {
        name: 'whoami'
        ip: r1.whoami
        ttl: shortTtl
      }
    ]
    links: [hubLinks[0]]
    tags: tags
  }
}

module zoneLabR2 'modules/privatezone.bicep' = {
  scope: rgR2
  name: 'zone-lab-r2'
  params: {
    zoneName: 'lab.contoso.internal'
    aRecords: [
      {
        name: 'whoami'
        ip: r2.whoami
        ttl: shortTtl
      }
    ]
    links: [hubLinks[1]]
    tags: tags
  }
}

// Forwarding rulesets -------------------------------------------------------------------------
// Hub rulesets: only the simulated on-prem domain. No rule targets an inbound endpoint (no loop).
module rsHub1 'modules/ruleset.bicep' = {
  scope: rgR1
  name: 'rs-hub-r1'
  params: {
    location: r1.location
    name: 'dnsfrs-${prefix}-hub-r1'
    outboundEndpointId: hub1.outputs.outboundEndpointId
    rules: [
      {
        name: 'onprem'
        domain: 'onprem.contoso.internal.'
        targets: [r1.dnsmasqIp]
      }
    ]
    links: [
      {
        name: 'hub-r1'
        vnetId: hub1.outputs.vnetId
      }
    ]
    tags: tags
  }
}

module rsHub2 'modules/ruleset.bicep' = {
  scope: rgR2
  name: 'rs-hub-r2'
  params: {
    location: r2.location
    name: 'dnsfrs-${prefix}-hub-r2'
    outboundEndpointId: hub2.outputs.outboundEndpointId
    rules: [
      {
        name: 'onprem'
        domain: 'onprem.contoso.internal.'
        targets: [r2.dnsmasqIp]
      }
    ]
    links: [
      {
        name: 'hub-r2'
        vnetId: hub2.outputs.vnetId
      }
    ]
    tags: tags
  }
}

var spokeDomains = [
  {
    name: 'azure'
    domain: 'azure.contoso.internal.'
  }
  {
    name: 'lab'
    domain: 'lab.contoso.internal.'
  }
  {
    name: 'onprem'
    domain: 'onprem.contoso.internal.'
  }
  {
    name: 'privatelink-blob'
    #disable-next-line no-hardcoded-env-urls
    domain: 'privatelink.blob.core.windows.net.'
  }
]

// Design A + C: spoke ruleset -> local inbound endpoint only (distributed pattern).
module rsSpoke 'modules/ruleset.bicep' = {
  scope: rgR1
  name: 'rs-spoke-r1'
  params: {
    location: r1.location
    name: 'dnsfrs-${prefix}-spoke-r1'
    outboundEndpointId: hub1.outputs.outboundEndpointId
    rules: [
      for d in spokeDomains: {
        name: d.name
        domain: d.domain
        targets: [r1.inboundIp]
      }
    ]
    links: [
      {
        name: 'spoke-a'
        vnetId: spoke[0].outputs.vnetId
      }
      {
        name: 'spoke-c'
        vnetId: spoke[2].outputs.vnetId
      }
    ]
    tags: tags
  }
  dependsOn: [rsHub1]
}

// Design D: multi-target rules [local IE, remote IE] on a second outbound endpoint
// (max 2 rulesets per outbound endpoint).
module rsSpokeD 'modules/ruleset.bicep' = {
  scope: rgR1
  name: 'rs-spoke-r1-d'
  params: {
    location: r1.location
    name: 'dnsfrs-${prefix}-spoke-r1-d'
    outboundEndpointId: hub1.outputs.outbound2EndpointId
    rules: [
      for d in spokeDomains: {
        name: d.name
        domain: d.domain
        targets: [r1.inboundIp, r2.inboundIp]
      }
    ]
    links: [
      {
        name: 'spoke-d'
        vnetId: spoke[3].outputs.vnetId
      }
    ]
    tags: tags
  }
}

// Storage + private endpoints (H7) -----------------------------------------------------------
module saR1 'modules/storage-pe.bicep' = {
  scope: rgR1
  name: 'sa-pe-r1'
  params: {
    location: r1.location
    name: 'st${prefix}r1${suffix}'
    peSubnetId: hub1.outputs.peSubnetId
    blobZoneId: zoneBlob.outputs.zoneId
    tags: tags
  }
}

module saR2 'modules/storage-pe.bicep' = {
  scope: rgR2
  name: 'sa-pe-r2'
  params: {
    location: r2.location
    name: 'st${prefix}r2${suffix}'
    peSubnetId: hub2.outputs.peSubnetId
    blobZoneId: zoneBlob.outputs.zoneId
    tags: tags
  }
}

// dnsmasq "on-prem" simulators --------------------------------------------------------------
var dnsmasqCloudInit = '''
#cloud-config
package_update: true
packages: [dnsmasq]
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

module dnsmasq1 'modules/vm.bicep' = {
  scope: rgR1
  name: 'vm-dnsmasq-r1'
  params: {
    location: r1.location
    name: 'vm-${prefix}-dnsmasq-r1'
    subnetId: hub1.outputs.workloadSubnetId
    osType: 'linux'
    vmSize: linuxVmSize
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    privateIp: r1.dnsmasqIp
    customData: replace(replace(dnsmasqCloudInit, '__LISTEN_IP__', r1.dnsmasqIp), '__ANSWER__', r1.onpremAnswer)
    enableAutoShutdown: enableAutoShutdown
    autoShutdownTime: autoShutdownTimeUtc
    tags: tags
  }
}

module dnsmasq2 'modules/vm.bicep' = {
  scope: rgR2
  name: 'vm-dnsmasq-r2'
  params: {
    location: r2.location
    name: 'vm-${prefix}-dnsmasq-r2'
    subnetId: hub2.outputs.workloadSubnetId
    osType: 'linux'
    vmSize: linuxVmSize
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    privateIp: r2.dnsmasqIp
    customData: replace(replace(dnsmasqCloudInit, '__LISTEN_IP__', r2.dnsmasqIp), '__ANSWER__', r2.onpremAnswer)
    enableAutoShutdown: enableAutoShutdown
    autoShutdownTime: autoShutdownTimeUtc
    tags: tags
  }
}

// Client VMs ---------------------------------------------------------------------------------
var linuxClientCloudInit = '''
#cloud-config
package_update: true
packages: [bind9-dnsutils, tcpdump, python3, jq, curl]
runcmd:
  - mkdir -p /opt/dnsprobe /var/log/dnsprobe
'''

module linuxClients 'modules/vm.bicep' = [
  for (s, i) in spokes: {
    scope: rgR1
    name: 'vm-lnx-${s.design}'
    params: {
      location: primaryLocation
      name: 'vm-${prefix}-lnx-${s.design}'
      subnetId: spoke[i].outputs.subnetId
      osType: 'linux'
      vmSize: linuxVmSize
      adminUsername: adminUsername
      sshPublicKey: sshPublicKey
      customData: linuxClientCloudInit
      enableAutoShutdown: enableAutoShutdown
      autoShutdownTime: autoShutdownTimeUtc
      tags: union(tags, { design: toUpper(s.design), role: 'client' })
    }
  }
]

var windowsSpokes = filter(range(0, length(spokes)), i => spokes[i].windows && deployWindows)

module windowsClients 'modules/vm.bicep' = [
  for i in windowsSpokes: {
    scope: rgR1
    name: 'vm-win-${spokes[i].design}'
    params: {
      location: primaryLocation
      name: 'vm-${prefix}-win-${spokes[i].design}'
      subnetId: spoke[i].outputs.subnetId
      osType: 'windows'
      vmSize: windowsVmSize
      adminUsername: adminUsername
      adminPassword: windowsAdminPassword
      enableAutoShutdown: enableAutoShutdown
      autoShutdownTime: autoShutdownTimeUtc
      tags: union(tags, { design: toUpper(spokes[i].design), role: 'client' })
    }
  }
]

// Shared monitoring + results ----------------------------------------------------------------
module shared 'modules/shared.bicep' = {
  scope: rgShared
  name: 'shared'
  params: {
    location: primaryLocation
    prefix: prefix
    ingestPrincipalIds: [for (s, i) in spokes: linuxClients[i].outputs.principalId]
    extraIngestPrincipalIds: [for (w, j) in windowsSpokes: windowsClients[j].outputs.principalId]
    tags: tags
  }
}

module dnsLogR1 'modules/dnslogging.bicep' = if (enableDnsQueryLogs) {
  scope: rgR1
  name: 'dnslog-r1'
  params: {
    location: r1.location
    prefix: prefix
    regionTag: r1.tag
    vnetIds: [hub1.outputs.vnetId]
    extraVnetIds: [for (s, i) in spokes: spoke[i].outputs.vnetId]
    workspaceId: shared.outputs.workspaceId
    tags: tags
  }
  dependsOn: [rsSpoke, rsSpokeD, rsHub1]
}

module dnsLogR2 'modules/dnslogging.bicep' = if (enableDnsQueryLogs) {
  scope: rgR2
  name: 'dnslog-r2'
  params: {
    location: r2.location
    prefix: prefix
    regionTag: r2.tag
    vnetIds: [hub2.outputs.vnetId]
    workspaceId: shared.outputs.workspaceId
    tags: tags
  }
  dependsOn: [rsHub2]
}

// Outputs consumed by scripts/lab.env generation ---------------------------------------------
output rgShared string = rgShared.name
output rgR1 string = rgR1.name
output rgR2 string = rgR2.name
output inboundIpR1 string = r1.inboundIp
output inboundIpR2 string = r2.inboundIp
output whoamiR1 string = r1.whoami
output whoamiR2 string = r2.whoami
output blobFqdnR1 string = saR1.outputs.blobFqdn
output blobFqdnR2 string = saR2.outputs.blobFqdn
output workspaceCustomerId string = shared.outputs.workspaceCustomerId
output ingestEndpoint string = shared.outputs.ingestEndpoint
output dcrImmutableId string = shared.outputs.dcrImmutableId
output resolverR1 string = hub1.outputs.resolverName
output resolverR2 string = hub2.outputs.resolverName
output linuxClients array = [for (s, i) in spokes: { design: s.design, vm: linuxClients[i].outputs.vmName }]
output windowsClients array = [for (i, j) in windowsSpokes: { design: spokes[i].design, vm: windowsClients[j].outputs.vmName }]
