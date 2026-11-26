targetScope = 'subscription'

@description('Resource group name.')
param resourceGroupName string

@description('Azure region for all resources.')
param location string

@description('Globally unique Azure Container Registry name.')
param acrName string

@description('Log Analytics workspace name.')
param logAnalyticsName string

@description('Container Apps Environment name.')
param containerAppsEnvironmentName string

@description('User Assigned Managed Identity name.')
param managedIdentityName string

@description('GitHub Actions OIDC subject for the development environment.')
param githubSubject string

@description('Object ID of the GitHub Actions Service Principal.')
param githubActionsSpObjectId string

@description('Allowed deployment environments.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

// @description('GitHub Actions OIDC subject for the development environment.')
// param githubSubject string

@description('Additional resource tags.')
param tags object = {}

var commonTags = union(tags, {
  Environment: environment
  Project: 'ProductAPI'
  ManagedBy: 'Bicep'
})



// Create a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: commonTags
}

// Configure GitHub Actions workload identity.
module githubIdentityLinksModule 'modules/github-identity-links.bicep' = {
  name: 'githubIdentityLinksDeployment'
  scope: resourceGroup
  params: {
    appUniqueName: 'productServiceGithubCicdDev'
    githubSubject: githubSubject
  }
}


// Deploy the ACR module
module acrModule 'modules/acr.bicep' = {
  name: 'acrDeployment'
  scope: resourceGroup
  params: {
    acrName: acrName
    githubActionsSpObjectId: githubActionsSpObjectId
    tags: commonTags
  }
}

// Deploy the Container Platform module
module containerPlatformModule 'modules/container-platform.bicep' = {
  name: 'containerPlatformDeployment'
  scope: resourceGroup
  params: {
    logAnalyticsName: logAnalyticsName
    containerAppsEnvironmentName: containerAppsEnvironmentName
    managedIdentityName: managedIdentityName
    acrName: acrModule.outputs.acrName
    tags: commonTags
  }
}


output resourceGroupId string = resourceGroup.id
output acrId string = acrModule.outputs.acrId
output acrLoginServer string = acrModule.outputs.acrLoginServer
output logAnalyticsWorkspaceId string = containerPlatformModule.outputs.logAnalyticsWorkspaceId
output containerAppsEnvironmentId string = containerPlatformModule.outputs.containerAppsEnvironmentId
output managedIdentityResourceId string = containerPlatformModule.outputs.managedIdentityResourceId
output managedIdentityPrincipalId string = containerPlatformModule.outputs.managedIdentityPrincipalId
output managedIdentityClientId string = containerPlatformModule.outputs.managedIdentityClientId