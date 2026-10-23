// Spoke VNet with one client subnet. NSG and route table start empty; failure scripts add rules.
param location string
param prefix string
param design string // a | b | c | d
param addressPrefix string
param subnetPrefix string
@description('Custom DNS servers. Empty array = Default (Azure-provided).')
param dnsServers array = []
param tags object

var name = 'vnet-${prefix}-spoke-${design}'

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-${prefix}-spoke-${design}'
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

resource rt 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'rt-${prefix}-spoke-${design}'
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: []
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: name
  location: location
  tags: union(tags, { design: toUpper(design) })
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
