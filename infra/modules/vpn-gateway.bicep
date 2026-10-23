// Route-based VPN gateway (+ optional GatewaySubnet on an existing VNet).
targetScope = 'resourceGroup'

param location string
param name string
param vnetName string
@description('When set, creates GatewaySubnet with this prefix on vnetName (used for the Azure hub VNets).')
param createGatewaySubnetPrefix string = ''
param asn int
param sku string = 'VpnGw1AZ'
param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
}

resource gwSubnetNew 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = if (!empty(createGatewaySubnetPrefix)) {
  parent: vnet
  name: 'GatewaySubnet'
  properties: {
    addressPrefix: createGatewaySubnetPrefix
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'pip-${name}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource gw 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation1'
    sku: {
      name: sku
      tier: sku
    }
    enableBgp: true
    bgpSettings: {
      asn: asn
    }
    activeActive: false
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnet.id}/subnets/GatewaySubnet'
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
  dependsOn: [
    gwSubnetNew
  ]
}

output gatewayId string = gw.id
