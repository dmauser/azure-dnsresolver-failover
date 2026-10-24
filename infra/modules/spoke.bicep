// Regional spoke VNet with one client subnet. The route table sends the other region's summaries
// to the local hub NVA (spokes peer only with their own hub). Failure scripts add NSG rules.
param location string
param prefix string
param regionTag string // r1 | r2
param addressPrefix string
param subnetPrefix string
@description('Custom DNS servers. Empty array = Default (Azure-provided).')
param dnsServers array = []
@description('Route table entries (name, addressPrefix, nextHopType, nextHopIpAddress).')
param routes array = []
param tags object

var name = 'vnet-${prefix}-spoke-${regionTag}'

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-${prefix}-spoke-${regionTag}'
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

resource rt 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'rt-${prefix}-spoke-${regionTag}'
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      for r in routes: {
        name: r.name
        properties: {
          addressPrefix: r.addressPrefix
          nextHopType: r.nextHopType
          nextHopIpAddress: r.?nextHopIpAddress
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: name
  location: location
  tags: union(tags, { region: regionTag })
  properties: {
    addressSpace: {
      addressPrefixes: [addressPrefix]
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
    subnets: [
      {
        name: 'snet-clients'
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: { id: nsg.id }
          routeTable: { id: rt.id }
          // Lab only: lets clients install dnsutils and send probe results to Log Analytics. Use explicit egress in production.
          defaultOutboundAccess: true
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output subnetId string = '${vnet.id}/subnets/snet-clients'
