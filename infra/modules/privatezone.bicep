// Private DNS zone with optional A records and VNet links (no auto-registration).
param zoneName string
@description('Array of { name, ip, ttl }')
param aRecords array = []
@description('Array of { name, vnetId }')
param links array
param tags object

resource zone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: zoneName
  location: 'global'
  tags: tags
}

resource records 'Microsoft.Network/privateDnsZones/A@2024-06-01' = [
  for r in aRecords: {
    parent: zone
    name: r.name
    properties: {
      ttl: r.ttl
      aRecords: [
        {
          ipv4Address: r.ip
        }
      ]
    }
  }
]

resource zoneLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = [
  for l in links: {
    parent: zone
    name: l.name
    location: 'global'
    tags: tags
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: l.vnetId
      }
    }
  }
]

output zoneId string = zone.id
