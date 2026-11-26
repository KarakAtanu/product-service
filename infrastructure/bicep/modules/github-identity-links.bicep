
targetScope = 'resourceGroup'

extension microsoftGraphV1

@description('Application Registration unique name.')
param appUniqueName string
@description('GitHub Actions OIDC issuer.')
param githubIssuer string = 'https://token.actions.githubusercontent.com'

@description('GitHub Actions OIDC audience.')
param githubAudience string = 'api://AzureADTokenExchange'

@description('GitHub Actions OIDC subject.')
param githubSubject string

@description('Federated credential name.')
param federatedCredentialName string = 'github-development'

@description('Description of the federated credential.')
param federatedCredentialDescription string = 'Trust GitHub Actions from the development environment.'

// Reference the existing App Registration.
resource cicdApplication 'Microsoft.Graph/applications@v1.0' existing = {
  uniqueName: appUniqueName

  // GitHub Actions Federated Identity Credential.
  resource githubFederatedCredential 'federatedIdentityCredentials@v1.0' = {
    name: '${appUniqueName}/${federatedCredentialName}'
    audiences: [
      githubAudience
    ]
    issuer: githubIssuer
    subject: githubSubject
    description: federatedCredentialDescription
  }
}

// Create the Enterprise Application / Service Principal.
resource cicdServicePrincipal 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: cicdApplication.appId
}
