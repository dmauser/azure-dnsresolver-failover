// DNS forwarding ruleset bound to one outbound endpoint, with rules and VNet links.
param location string
param name string
param outboundEndpointId string
@description('Array of { name, domain, targets: [ip,...] }')
param rules array
@description('Array of { name, vnetId }')
param links array
param tags object

resource ruleset 'Microsoft.Network/dnsForwardingRulesets@2025-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: outboundEndpointId
      }
    ]
  }
}

resource fwdRules 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2025-05-01' = [
  for r in rules: {
    parent: ruleset
    name: r.name
    properties: {
      domainName: r.domain
      forwardingRuleState: 'Enabled'
      targetDnsServers: [
        for ip in r.targets: {
          ipAddress: ip
          port: 53
        }
      ]
    }
  }
]

resource vnetLinks 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2025-05-01' = [
  for l in links: {
    parent: ruleset
    name: l.name
    properties: {
      virtualNetwork: {
        id: l.vnetId
      }
    }
  }
]

output rulesetName string = ruleset.name
