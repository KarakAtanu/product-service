
targetScope = 'resourceGroup'

@description('Azure Container Registry Name.')
@minLength(5)
@maxLength(50)
param registryName string

@description('Azure location.')
param location string

@description('Resource Tags.')
param tags object = {}

resource acr 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: registryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
  tags: tags
}

output registryId string = acr.id
output registryLoginServer string = acr.properties.loginServer