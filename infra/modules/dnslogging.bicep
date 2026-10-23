// DNS security policy used only for DNS query logging (DNSQueryLogs table).
// A single Allow rule for '.' keeps resolution unchanged while logging every query from linked VNets.
param location string
param prefix string
param regionTag string
param vnetIds array
param extraVnetIds array = []
var allvnetIds = concat(vnetIds, extraVnetIds)
param workspaceId string
param tags object

resource policy 'Microsoft.Network/dnsResolverPolicies@2025-05-01' = {
  name: 'dnspol-${prefix}-${regionTag}'
  location: location
  tags: tags
  properties: {}
}

resource domainList 'Microsoft.Network/dnsResolverDomainLists@2025-05-01' = {
  name: 'dnsdl-${prefix}-${regionTag}-all'
  location: location
  tags: tags
  properties: {
    domains: ['.']
  }
}

resource allowAll 'Microsoft.Network/dnsResolverPolicies/dnsSecurityRules@2025-05-01' = {
  parent: policy
  name: 'allow-all-log'
  location: location
  tags: tags
  properties: {
    priority: 100
    action: {
      actionType: 'Allow'
    }
    dnsResolverDomainLists: [
      {
        id: domainList.id
      }
    ]
    dnsSecurityRuleState: 'Enabled'
  }
}

resource links 'Microsoft.Network/dnsResolverPolicies/virtualNetworkLinks@2025-05-01' = [
  for (v, i) in allvnetIds: {
    parent: policy
    name: 'link-${i}'
    location: location
    tags: tags
    properties: {
      virtualNetwork: {
        id: v
      }
    }
    dependsOn: [allowAll]
  }
]

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'to-law'
  scope: policy
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}
