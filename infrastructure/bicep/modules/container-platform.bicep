
targetScope = 'resourceGroup'

@description('Log Analytics workspace name.')
param logAnalyticsName string

@description('Container Apps Environment name.')
param containerAppsEnvironmentName string

@description('User Assigned Managed Identity name.')
param managedIdentityName string

@description('Name of the ACR created by the parent deployment.')
param acrName string

@description('Resource tags.')
param tags object = {}

// --------------------------------------------------
// 1. Log Analytics Workspace
// --------------------------------------------------

resource workspace 'Microsoft.OperationalInsights/workspaces@2026-03-01' = {
  name: logAnalyticsName
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: tags
}

// --------------------------------------------------
// 2. Container Apps Environment
// --------------------------------------------------

resource managedEnvironment 'Microsoft.App/managedEnvironments@2026-01-01' = {
  name: containerAppsEnvironmentName
  location: resourceGroup().location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: workspace.properties.customerId
        sharedKey: workspace.listKeys().primarySharedKey
      }
    }
  }
  tags: tags
}

// --------------------------------------------------
// 3. User Assigned Managed Identity
// --------------------------------------------------

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: managedIdentityName
  location: resourceGroup().location
  tags: tags
}

// --------------------------------------------------
// 4. Reference the ACR
// --------------------------------------------------

resource registry 'Microsoft.ContainerRegistry/registries@2025-11-01' existing = {
  name: acrName
}

// --------------------------------------------------
// 5. Assign ACR Pull permission
// --------------------------------------------------

var repositoryReaderCondition = '''
(
  (
    !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})
    AND
    !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'})
  )
  OR
  (
    @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringEqualsIgnoreCase 'product-api'
  )
)
'''


var acrRepositoryReaderRoleId = 'b93aa761-3e63-49ed-ac28-beffa264f7ac'
var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrRepositoryReaderRoleId)

resource acrPullAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(registry.id, managedIdentity.id, acrRepositoryReaderRoleId)
  scope: registry
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    condition: repositoryReaderCondition
    conditionVersion: '2.0'
  }
}

// --------------------------------------------------
// Outputs
// --------------------------------------------------

output logAnalyticsWorkspaceId string = workspace.id
output containerAppsEnvironmentId string = managedEnvironment.id
output managedIdentityResourceId string = managedIdentity.id
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
output managedIdentityClientId string = managedIdentity.properties.clientId
