// Hub VNet with DNS Private Resolver (static inbound endpoint), one or two outbound endpoints,
// a workload subnet (dnsmasq "on-prem" simulator) and a private-endpoint subnet.
param location string
param prefix string
param regionTag string // r1 | r2
param addressPrefix string // e.g. 10.10.0.0/22
param inboundSubnetPrefix string // /28
param inboundIp string // static IP inside inboundSubnetPrefix
param outboundSubnetPrefix string // /28
param outbound2SubnetPrefix string = '' // optional second outbound endpoint (/28)
param workloadSubnetPrefix string
param peSubnetPrefix string
param attachResolverSubnetNsg bool = true
param tags object

var vnetName = 'vnet-${prefix}-hub-${regionTag}'
var deployOutbound2 = !empty(outbound2SubnetPrefix)

// Empty NSGs: failure-injection scripts add/remove deny rules at runtime.
resource nsgInbound 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-${prefix}-hub-${regionTag}-dnsin'
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

resource nsgOutbound 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-${prefix}-hub-${regionTag}-dnsout'
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

resource nsgWorkload 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-${prefix}-hub-${regionTag}-workload'
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

var resolverDelegation = [
  {
    name: 'Microsoft.Network.dnsResolvers'
    properties: {
      serviceName: 'Microsoft.Network/dnsResolvers'
    }
  }
]

var baseSubnets = [
  {
    name: 'snet-dns-inbound'
    properties: {
      addressPrefix: inboundSubnetPrefix
      delegations: resolverDelegation
      networkSecurityGroup: attachResolverSubnetNsg ? { id: nsgInbound.id } : null
      defaultOutboundAccess: false
    }
  }
  {
    name: 'snet-dns-outbound'
    properties: {
      addressPrefix: outboundSubnetPrefix
      delegations: resolverDelegation
      networkSecurityGroup: attachResolverSubnetNsg ? { id: nsgOutbound.id } : null
      defaultOutboundAccess: false
    }
  }
  {
    name: 'snet-workload'
    properties: {
      addressPrefix: workloadSubnetPrefix
      networkSecurityGroup: { id: nsgWorkload.id }
      // Lab only: allows package installs without a NAT gateway. Use explicit egress in production.
      defaultOutboundAccess: true
    }
  }
  {
    name: 'snet-pe'
    properties: {
      addressPrefix: peSubnetPrefix
      defaultOutboundAccess: false
    }
  }
]

var outbound2Subnet = deployOutbound2
  ? [
      {
        name: 'snet-dns-outbound2'
        properties: {
          addressPrefix: outbound2SubnetPrefix
          delegations: resolverDelegation
          networkSecurityGroup: attachResolverSubnetNsg ? { id: nsgOutbound.id } : null
          defaultOutboundAccess: false
        }
      }
    ]
  : []

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [addressPrefix]
    }
    subnets: concat(baseSubnets, outbound2Subnet)
  }
}

resource resolver 'Microsoft.Network/dnsResolvers@2025-05-01' = {
  name: 'dnspr-${prefix}-${regionTag}'
  location: location
  tags: tags
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource inbound 'Microsoft.Network/dnsResolvers/inboundEndpoints@2025-05-01' = {
  parent: resolver
  name: 'in-${regionTag}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        privateIpAllocationMethod: 'Static'
        privateIpAddress: inboundIp
        subnet: {
          id: '${vnet.id}/subnets/snet-dns-inbound'
        }
      }
    ]
  }
}

resource outbound 'Microsoft.Network/dnsResolvers/outboundEndpoints@2025-05-01' = {
  parent: resolver
  name: 'out-${regionTag}'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: '${vnet.id}/subnets/snet-dns-outbound'
    }
  }
  dependsOn: [inbound]
}

resource outbound2 'Microsoft.Network/dnsResolvers/outboundEndpoints@2025-05-01' = if (deployOutbound2) {
  parent: resolver
  name: 'out2-${regionTag}'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: '${vnet.id}/subnets/snet-dns-outbound2'
    }
  }
  dependsOn: [outbound]
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output resolverName string = resolver.name
output inboundIp string = inboundIp
output outboundEndpointId string = outbound.id
output outbound2EndpointId string = deployOutbound2 ? outbound2.id : ''
output workloadSubnetId string = '${vnet.id}/subnets/snet-workload'
output peSubnetId string = '${vnet.id}/subnets/snet-pe'
