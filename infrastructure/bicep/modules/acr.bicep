targetScope = 'resourceGroup'

@description('Globally unique Azure Container Registry name.')
@maxLength(24)
@minLength(5)
param acrName string

@description('Object ID of GitHub Actions CI/CD Service Principal.')
param githubActionsSpObjectId string

@description('Resource tags.')
param tags object = {}

var repositoryWriterRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '2a1e307c-b015-4ebd-883e-5b7698a07328')


// Restrict all four Writer data actions to product-api.
var githubWriterCondition = '''
(
  (
    !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'})
    AND
    !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})
    AND
    !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/write'})
    AND
    !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/write'})
  )
  OR
  (
    @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringEqualsIgnoreCase 'product-api'
  )
)
'''


// Create an Azure Container Registry
resource registry 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
  name: acrName
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
    roleAssignmentMode: 'AbacRepositoryPermissions'
    policies:{
        azureADAuthenticationAsArmPolicy: {
            status: 'enabled'
        }
    }
  }
  tags: tags
}

// Assign the "Container Registry Repository Writer" role to the GitHub Actions CI/CD Service Principal for the ACR
resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(acrName, githubActionsSpObjectId, repositoryWriterRoleDefinitionId)
  scope: registry
  properties: {
    roleDefinitionId: repositoryWriterRoleDefinitionId
    principalId: githubActionsSpObjectId
    principalType: 'ServicePrincipal'
    description: 'Grant GitHub Actions to push and pull images only in product-api repository.'
    condition: githubWriterCondition
    conditionVersion: '2.0'
  }
}

output acrId string = registry.id
output acrName string = registry.name
output acrLoginServer string = registry.properties.loginServer
output githubActionsSpRoleAssignmentId string = acrRoleAssignment.id
