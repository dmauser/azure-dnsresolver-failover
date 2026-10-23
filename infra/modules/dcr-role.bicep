// Grants Monitoring Metrics Publisher on an existing probe DCR to extra principals
// (e.g. on-prem client VMs deployed after the shared module).
param dcrName string
param principalIds array

var metricsPublisherRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '3913510d-42f4-4e42-8a64-420c390055eb'
)

resource dcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' existing = {
  name: dcrName
}

resource ingestRoles 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for p in principalIds: {
    name: guid(dcr.id, p, 'ingest')
    scope: dcr
    properties: {
      roleDefinitionId: metricsPublisherRoleId
      principalId: p
      principalType: 'ServicePrincipal'
    }
  }
]
