targetScope = 'subscription'

// ---------------------------------------------------------------------------------------------
// Optional add-on to main.bicep: two emulated on-premises sites attached to the regional hubs.
//
//   op1 (primaryLocation)   BIND forwards Azure zones to [IE-r1, IE-r2]
//   op2 (secondaryLocation) BIND forwards Azure zones to [IE-r2, IE-r1]
//
// Each site attaches to its REGIONAL hub only (op1 -> hub-r1, op2 -> hub-r2). Cross-region traffic
// (e.g. op1 -> IE-r2 during failover) is steered by a UDR to the local hub NVA, which forwards it
// over the hub<->hub peering.
// connectivity = 'Peering' (default, cheapest): site VNet peered to its regional hub.
// connectivity = 'Vpn': site VPN gateway + VNet-to-VNet IPsec/BGP connection to a VPN gateway in
// its regional hub (closer to a real branch, ~45 min to deploy, higher cost).
//
// Requires main.bicep to be deployed first with the same prefix / locations.
// ---------------------------------------------------------------------------------------------

@maxLength(8)
param prefix string = 'dnsfo'
param primaryLocation string = 'eastus2'
param secondaryLocation string = 'centralus'
param owner string
param ttlTag string
param adminUsername string = 'azureuser'
@secure()
param sshPublicKey string
param linuxVmSize string = 'Standard_B2ats_v2'
param enableAutoShutdown bool = true
param autoShutdownTimeUtc string = '0300'
@allowed([
  'Peering'
  'Vpn'
])
param connectivity string = 'Peering'
@secure()
@description('IPsec pre-shared key (Vpn mode only).')
param vpnSharedKey string = ''
param vpnGatewaySku string = 'VpnGw1AZ'

var tags = {
  purpose: 'dns-resolver-failover-lab'
  owner: owner
  ttl: ttlTag
  component: 'onprem'
}

var hubs = [
  {
    tag: 'r1'
    rg: 'rg-${prefix}-r1'
    location: primaryLocation
    vnetName: 'vnet-${prefix}-hub-r1'
    inboundIp: '10.10.0.4'
    nvaIp: '10.10.3.68'
    asn: 65511
  }
  {
    tag: 'r2'
    rg: 'rg-${prefix}-r2'
    location: secondaryLocation
    vnetName: 'vnet-${prefix}-hub-r2'
    inboundIp: '10.20.0.4'
    nvaIp: '10.20.3.68'
    asn: 65512
  }
]

var sites = [
  {
    id: 'op1'
    rg: 'rg-${prefix}-onprem1'
    location: primaryLocation
    addressPrefix: '10.110.0.0/16'
    forwarders: [
      hubs[0].inboundIp
      hubs[1].inboundIp
    ]
    hub: 0
    remoteRoutes: [
      '10.11.0.0/16'
      '10.20.0.0/16'
      '10.21.0.0/16'
      '10.120.0.0/16'
    ]
    asn: 65521
  }
  {
    id: 'op2'
    rg: 'rg-${prefix}-onprem2'
    location: secondaryLocation
    addressPrefix: '10.120.0.0/16'
    forwarders: [
      hubs[1].inboundIp
      hubs[0].inboundIp
    ]
    hub: 1
    remoteRoutes: [
      '10.21.0.0/16'
      '10.10.0.0/16'
      '10.11.0.0/16'
      '10.110.0.0/16'
    ]
    asn: 65522
  }
]

resource siteRgs 'Microsoft.Resources/resourceGroups@2024-03-01' = [
  for s in sites: {
    name: s.rg
    location: s.location
    tags: tags
  }
]

module site 'modules/onprem-site.bicep' = [
  for (s, i) in sites: {
    name: 'onprem-${s.id}'
    scope: resourceGroup(s.rg)
    dependsOn: [
      siteRgs
    ]
    params: {
      location: s.location
      prefix: prefix
      siteId: s.id
      addressPrefix: s.addressPrefix
      inboundEndpointIps: s.forwarders
      // UDR to the hub NVA only applies over peering; in VPN mode the gateway's BGP routes are used.
      nvaIp: connectivity == 'Peering' ? hubs[s.hub].nvaIp : ''
      remoteRoutes: s.remoteRoutes
      adminUsername: adminUsername
      sshPublicKey: sshPublicKey
      vmSize: linuxVmSize
      enableAutoShutdown: enableAutoShutdown
      autoShutdownTime: autoShutdownTimeUtc
      tags: tags
    }
  }
]

// ---- Peering mode ----------------------------------------------------------------------------
var pairs = [
  {
    s: 0
    h: 0
  }
  {
    s: 1
    h: 1
  }
]

module siteToHub 'modules/peering.bicep' = [
  for p in pairs: if (connectivity == 'Peering') {
    name: 'peer-${sites[p.s].id}-to-hub-${hubs[p.h].tag}'
    scope: resourceGroup(sites[p.s].rg)
    params: {
      localVnetName: 'vnet-${prefix}-${sites[p.s].id}'
      remoteVnetId: resourceId(subscription().subscriptionId, hubs[p.h].rg, 'Microsoft.Network/virtualNetworks', hubs[p.h].vnetName)
      peeringName: 'to-hub-${hubs[p.h].tag}'
      allowForwardedTraffic: true
    }
    dependsOn: [
      site
    ]
  }
]

module hubToSite 'modules/peering.bicep' = [
  for p in pairs: if (connectivity == 'Peering') {
    name: 'peer-hub-${hubs[p.h].tag}-to-${sites[p.s].id}'
    scope: resourceGroup(hubs[p.h].rg)
    params: {
      localVnetName: hubs[p.h].vnetName
      remoteVnetId: resourceId(subscription().subscriptionId, sites[p.s].rg, 'Microsoft.Network/virtualNetworks', 'vnet-${prefix}-${sites[p.s].id}')
      peeringName: 'to-${sites[p.s].id}'
      allowForwardedTraffic: true
    }
    dependsOn: [
      site
    ]
  }
]

// ---- VPN mode --------------------------------------------------------------------------------
module hubGw 'modules/vpn-gateway.bicep' = [
  for h in hubs: if (connectivity == 'Vpn') {
    name: 'vpngw-hub-${h.tag}'
    scope: resourceGroup(h.rg)
    params: {
      location: h.location
      name: 'vpngw-${prefix}-hub-${h.tag}'
      vnetName: h.vnetName
      asn: h.asn
      sku: vpnGatewaySku
      tags: tags
    }
  }
]

module siteGw 'modules/vpn-gateway.bicep' = [
  for (s, i) in sites: if (connectivity == 'Vpn') {
    name: 'vpngw-${s.id}'
    scope: resourceGroup(s.rg)
    params: {
      location: s.location
      name: 'vpngw-${prefix}-${s.id}'
      vnetName: 'vnet-${prefix}-${s.id}'
      asn: s.asn
      sku: vpnGatewaySku
      tags: tags
    }
    dependsOn: [
      site
    ]
  }
]

module connSiteToHub 'modules/vpn-connection.bicep' = [
  for p in pairs: if (connectivity == 'Vpn') {
    name: 'cn-${sites[p.s].id}-to-hub-${hubs[p.h].tag}'
    scope: resourceGroup(sites[p.s].rg)
    params: {
      location: sites[p.s].location
      name: 'cn-${sites[p.s].id}-to-hub-${hubs[p.h].tag}'
      gateway1Id: resourceId(subscription().subscriptionId, sites[p.s].rg, 'Microsoft.Network/virtualNetworkGateways', 'vpngw-${prefix}-${sites[p.s].id}')
      gateway2Id: resourceId(subscription().subscriptionId, hubs[p.h].rg, 'Microsoft.Network/virtualNetworkGateways', 'vpngw-${prefix}-hub-${hubs[p.h].tag}')
      sharedKey: vpnSharedKey
      tags: tags
    }
    dependsOn: [
      hubGw
      siteGw
    ]
  }
]

module connHubToSite 'modules/vpn-connection.bicep' = [
  for p in pairs: if (connectivity == 'Vpn') {
    name: 'cn-hub-${hubs[p.h].tag}-to-${sites[p.s].id}'
    scope: resourceGroup(hubs[p.h].rg)
    params: {
      location: hubs[p.h].location
      name: 'cn-hub-${hubs[p.h].tag}-to-${sites[p.s].id}'
      gateway1Id: resourceId(subscription().subscriptionId, hubs[p.h].rg, 'Microsoft.Network/virtualNetworkGateways', 'vpngw-${prefix}-hub-${hubs[p.h].tag}')
      gateway2Id: resourceId(subscription().subscriptionId, sites[p.s].rg, 'Microsoft.Network/virtualNetworkGateways', 'vpngw-${prefix}-${sites[p.s].id}')
      sharedKey: vpnSharedKey
      tags: tags
    }
    dependsOn: [
      hubGw
      siteGw
    ]
  }
]

// On-prem probe clients ingest to the shared probe DCR with their managed identity.
module dcrIngest 'modules/dcr-role.bicep' = {
  name: 'onprem-dcr-ingest'
  scope: resourceGroup('rg-${prefix}-shared')
  params: {
    dcrName: 'dcr-${prefix}-probe'
    principalIds: [
      site[0].outputs.clientPrincipalId
      site[1].outputs.clientPrincipalId
    ]
  }
}

output connectivity string = connectivity
output onpremResourceGroups array = [for s in sites: s.rg]
output onpremClients array = [for (s, i) in sites: '${s.id}:${site[i].outputs.clientVmName}:${s.rg}']
output onpremDnsIps array = [for (s, i) in sites: site[i].outputs.dnsIp]
output onpremBindVms array = [for (s, i) in sites: site[i].outputs.bindVmName]
output onpremAppFqdns array = [for (s, i) in sites: site[i].outputs.appFqdn]
