// One direction of a VNet-to-VNet IPsec connection (deploy in gateway1's RG).
targetScope = 'resourceGroup'

param location string
param name string
param gateway1Id string
param gateway2Id string
@secure()
param sharedKey string
param tags object

resource conn 'Microsoft.Network/connections@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    connectionType: 'Vnet2Vnet'
    virtualNetworkGateway1: {
      id: gateway1Id
      properties: {}
    }
    virtualNetworkGateway2: {
      id: gateway2Id
      properties: {}
    }
    sharedKey: sharedKey
    enableBgp: true
    connectionProtocol: 'IKEv2'
  }
}
