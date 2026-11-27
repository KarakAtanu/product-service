# This script is used to validate the deployed resources in Azure. 
# It checks if the resources are created successfully and are in the expected state.

# Set the location and deployment name
$LOCATION = "centralindia"
$DEPLOYMENT_NAME = "product-api-foundation-dev"
$RESOURCE_GROUP = "rg-product-api-dev-cin-001"
$ACR_NAME = "acrproductapidev001"
$LOG_ANALYTICS_WORKSPACE_NAME = "log-product-api-dev-cin-001"
$CONTAINER_APPS_ENVIRONMENT_NAME = "cae-product-api-dev-cin-001"
$MANAGED_IDENTITY_NAME = "id-product-api-dev-cin-001"

# List out resources in resource group
write-host "Listing resources in resource group: $RESOURCE_GROUP"
az resource list `
--resource-group $RESOURCE_GROUP `
--output table

# Verify ACR 
write-host "==================================================="
write-host "Verifying ACR: $ACR_NAME"
az acr show `
--name $ACR_NAME `
--resource-group $RESOURCE_GROUP `
--query "{name: name, loginServer: loginServer, provisioningState: provisioningState, SKU: sku, AdminUserEnabled: adminUserEnabled, RoleAssignmentMode: roleAssignmentMode}" `
--output json

# Verify Managed Identity
write-host "==================================================="
write-host "Verifying Managed Identity: $MANAGED_IDENTITY_NAME"
az identity show `
--name $MANAGED_IDENTITY_NAME `
--resource-group $RESOURCE_GROUP `
--query "{name: name, principalId: principalId, clientId: clientId, tenantId: tenantId, provisioningState: provisioningState}" `
--output json

# Verify Container Apps Environment
write-host "==================================================="
write-host "Verifying Container Apps Environment: $CONTAINER_APPS_ENVIRONMENT_NAME"
az containerapp env show `
--name $CONTAINER_APPS_ENVIRONMENT_NAME `
--resource-group $RESOURCE_GROUP `
--query "{name: name, location: location, provisioningState: provisioningState, staticIp: staticIp, internalLoadBalancerEnabled:  properties.vnetConfiguration.internal}" `
--output json

# Verify Log Analytics Workspace
write-host "==================================================="
write-host "Verifying Log Analytics Workspace: $LOG_ANALYTICS_WORKSPACE_NAME"
az monitor log-analytics workspace show `
--workspace-name $LOG_ANALYTICS_WORKSPACE_NAME `
--resource-group $RESOURCE_GROUP `
--query "{name: name, location: location, provisioningState: provisioningState, customerId: customerId}" `
--output json

# Verify ACR role assignments
write-host "==================================================="
write-host "Verifying ACR role assignments for: $ACR_NAME"

$ACR_ID = az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "id" -o tsv

az role assignment list `
--scope $ACR_ID `
--query "[].{RoleDefinitionName: roleDefinitionName, PrincipalId: principalId, PrincipalType: principalType, Condition: condition, ConditionVersion: conditionVersion}" `
--output json
