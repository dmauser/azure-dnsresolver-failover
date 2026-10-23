// Regional hub VNet (CAF hub-spoke): DNS Private Resolver (static inbound endpoint + outbound
// endpoint), a workload subnet (dnsmasq simulator), a private-endpoint subnet, a GatewaySubnet
// (used only in VPN mode) and an NVA subnet hosting the regional router.
//
// Routing (Learn: azure/firewall/firewall-multi-hub-spoke):
//   rt-...-hub-<r>      remote-region summaries -> local NVA   (resolver, workload, GatewaySubnet)
//   rt-...-hub-<r>-nva  remote-region summaries -> remote NVA  (NVA subnet; gateway propagation on)
param location string
param prefix string
param regionTag string // r1 | r2
param addressPrefix string // e.g. 10.10.0.0/22
param inboundSubnetPrefix string // /28
param inboundIp string // static IP inside inboundSubnetPrefix
param outboundSubnetPrefix string // /28
param workloadSubnetPrefix string
param peSubnetPrefix string
param gatewaySubnetPrefix string // /27, VPN mode only (an empty GatewaySubnet is free)
param nvaSubnetPrefix string // /27
param localNvaIp string
param remoteNvaIp string
@description('Address summaries of the OTHER region (hub, spokes, on-prem site).')
param remoteSummaries array
param attachResolverSubnetNsg bool = true
@description('Associate the hub route table with the resolver-delegated subnets (return path to the remote region).')
param attachResolverSubnetRouteTable bool = true
param tags object

var vnetName = 'vnet-${prefix}-hub-${regionTag}'

resource rtHub 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'rt-${prefix}-hub-${regionTag}'
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      for (p, i) in remoteSummaries: {
        name: 'remote-${i}'
        properties: {
          addressPrefix: p
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: localNvaIp
        }
      }
    ]
  }
}

resource rtNva 'Microsoft.Network/routeTables@2024-05-01' = {
  name: 'rt-${prefix}-hub-${regionTag}-nva'
  location: location
  tags: tags
  properties: {
    // Keep gateway propagation so the NVA learns on-prem routes in VPN mode.
    disableBgpRoutePropagation: false
    routes: [
      for (p, i) in remoteSummaries: {
        name: 'remote-${i}'
        properties: {
          addressPrefix: p
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: remoteNvaIp
        }
      }
    ]
  }
}

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
      routeTable: attachResolverSubnetRouteTable ? { id: rtHub.id } : null
      defaultOutboundAccess: false
    }
  }
  {
    name: 'snet-dns-outbound'
    properties: {
      addressPrefix: outboundSubnetPrefix
      delegations: resolverDelegation
      networkSecurityGroup: attachResolverSubnetNsg ? { id: nsgOutbound.id } : null
      routeTable: attachResolverSubnetRouteTable ? { id: rtHub.id } : null
      defaultOutboundAccess: false
    }
  }
  {
    name: 'snet-workload'
    properties: {
      addressPrefix: workloadSubnetPrefix
      networkSecurityGroup: { id: nsgWorkload.id }
      routeTable: { id: rtHub.id }
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
  {
    name: 'GatewaySubnet'
    properties: {
      addressPrefix: gatewaySubnetPrefix
      routeTable: { id: rtHub.id }
    }
  }
  {
    name: 'snet-nva'
    properties: {
      addressPrefix: nvaSubnetPrefix
      routeTable: { id: rtNva.id }
      // Lab only: lets the router VM reach Ubuntu mirrors. Use explicit egress in production.
      defaultOutboundAccess: true
    }
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [addressPrefix]
    }
    subnets: baseSubnets
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


output vnetId string = vnet.id
output vnetName string = vnet.name
output resolverName string = resolver.name
output inboundIp string = inboundIp
output outboundEndpointId string = outbound.id
output workloadSubnetId string = '${vnet.id}/subnets/snet-workload'
output peSubnetId string = '${vnet.id}/subnets/snet-pe'
output nvaSubnetId string = '${vnet.id}/subnets/snet-nva'
