// Shared monitoring + probe-results sink.
// Probe results go to a Log Analytics custom table through the Logs Ingestion API (DCR, kind
// Direct) using each client VM's managed identity. A storage account is deliberately NOT used:
// many enterprise tenants force storage publicNetworkAccess=Disabled by policy, which would
// make results unreachable from the admin workstation. Ingestion is not part of any DNS test path.
param location string
param prefix string
@description('Client VM principal IDs granted Monitoring Metrics Publisher on the probe DCR.')
param ingestPrincipalIds array
param extraIngestPrincipalIds array = []
var allIngestPrincipalIds = concat(ingestPrincipalIds, extraIngestPrincipalIds)
param tags object

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-${prefix}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

var probeColumns = [
  { name: 'TimeGenerated', type: 'datetime' }
  { name: 'RunId', type: 'string' }
  { name: 'Vm', type: 'string' }
  { name: 'Os', type: 'string' }
  { name: 'Design', type: 'string' }
  { name: 'Profile', type: 'string' }
  { name: 'Name', type: 'string' }
  { name: 'Method', type: 'string' }
  { name: 'Server', type: 'string' }
  { name: 'Rcode', type: 'string' }
  { name: 'Answer', type: 'string' }
  { name: 'Ms', type: 'int' }
]

resource table 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = {
  parent: law
  name: 'DnsProbe_CL'
  properties: {
    schema: {
      name: 'DnsProbe_CL'
      columns: probeColumns
    }
    retentionInDays: 30
  }
}

resource dcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: 'dcr-${prefix}-probe'
  location: location
  tags: tags
  kind: 'Direct'
  properties: {
    streamDeclarations: {
      'Custom-DnsProbe': {
        columns: probeColumns
      }
    }
    destinations: {
      logAnalytics: [
        {
          name: 'law'
          workspaceResourceId: law.id
        }
      ]
    }
    dataFlows: [
      {
        streams: ['Custom-DnsProbe']
        destinations: ['law']
        transformKql: 'source'
        outputStream: 'Custom-DnsProbe_CL'
      }
    ]
  }
  dependsOn: [table]
}

var metricsPublisher = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '3913510d-42f4-4e42-8a64-420c390055eb'
)

resource ingestRoles 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for p in allIngestPrincipalIds: {
    name: guid(dcr.id, p, 'ingest')
    scope: dcr
    properties: {
      principalId: p
      principalType: 'ServicePrincipal'
      roleDefinitionId: metricsPublisher
    }
  }
]

output workspaceId string = law.id
output workspaceCustomerId string = law.properties.customerId
output ingestEndpoint string = dcr.properties.endpoints.logsIngestion
output dcrImmutableId string = dcr.properties.immutableId
