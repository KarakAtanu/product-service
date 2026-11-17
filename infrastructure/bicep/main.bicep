//Creates resource group and orchestrates deployment of resources in the resource group

targetScope = 'subscription'

@description('Name of the resource group.')
param resourceGroupName string

@description('Azure region for resource deployment.')
param location string = 'centralindia'

@description('Azure Container Registry name.')
param acrName string

@description('Tags to associate with the resources.')
param tags object = {
  environment: 'Development'
  project: 'productApi'
  managedBy: 'Bicep'
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module acrModule 'modules/acr.bicep' = {
  name: 'acrDeployment'
  scope: resourceGroup
  params: {
    registryName: acrName
    location: location
    tags: tags
  }
}

output resourceGroupId string = resourceGroup.id
output acrId string = acrModule.outputs.registryId
output acrLoginServer string = acrModule.outputs.registryLoginServer