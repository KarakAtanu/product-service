
targetScope = 'resourceGroup'

extension microsoftGraphV1

@description('Display name of the CI/CD application.')
param appDisplayName string = 'app-product-github-cicd-dev'

@description('Immutable unique name for the Entra application.')
param appUniqueName string = 'productServiceGithubCicdDev'

// Microsoft Entra App Registration
resource cicdApplication 'Microsoft.Graph/applications@v1.0' = {
  displayName: appDisplayName
  uniqueName: appUniqueName
  description: 'Workload identity for GitHub Actions CI/CD deployment of Product API.'
  signInAudience: 'AzureADMyOrg'
}
