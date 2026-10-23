// Shared monitoring + results storage.
param location string
param prefix string
param resultsStorageName string
@description('Principal IDs granted Storage Blob Data Contributor on the results account (client VMs + deployer).')
param blobWriterPrincipalIds array
param extraBlobWriterPrincipalIds array = []
var allblobWriterPrincipalIds = concat(blobWriterPrincipalIds, extraBlobWriterPrincipalIds)
param deployerPrincipalId string = ''
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

// Results upload target. Public endpoint (Entra ID only, no shared key) so results can be
// collected from the admin workstation; it is NOT part of any DNS test path.
resource results 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: resultsStorageName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowSharedKeyAccess: false
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Enabled'
  }
}

resource blobSvc 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: results
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobSvc
  name: 'results'
}

var blobDataContributor = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
)

resource vmWriters 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for p in allblobWriterPrincipalIds: {
    name: guid(results.id, p, 'blobwriter')
    scope: results
    properties: {
      principalId: p
      principalType: 'ServicePrincipal'
      roleDefinitionId: blobDataContributor
    }
  }
]

resource deployerWriter 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(deployerPrincipalId)) {
  name: guid(results.id, deployerPrincipalId, 'blobwriter')
  scope: results
  properties: {
    principalId: deployerPrincipalId
    roleDefinitionId: blobDataContributor
  }
}

output workspaceId string = law.id
output resultsAccount string = results.name
