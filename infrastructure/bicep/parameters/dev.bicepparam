using '../main.bicep'

param resourceGroupName = 'rg-product-api-dev-cin-001'

param location = 'centralindia'

param acrName = 'acrproductapidev001'

param logAnalyticsName = 'log-product-api-dev-cin-001'

param containerAppsEnvironmentName = 'cae-product-api-dev-cin-001'

param managedIdentityName = 'id-product-api-dev-cin-001'

param environment = 'dev'

param githubSubject = 'repo:KarakAtanu@31691400/product-service@1453663592:environment:development'

param githubActionsSpObjectId = 'e997b6fd-1f8c-4db9-8b01-446414ef9a00'

param tags = {
  Owner: 'Engineering'
  Workload: 'ProductAPI'
  CostCenter: 'Development'
}
