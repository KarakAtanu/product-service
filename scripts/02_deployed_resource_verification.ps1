# Parameters for the script
$RESOURCE_GROUP_NAME = 'rg-product-api-dev-cin-001'
$LOCATION = 'centralindia'


# Verify the resource group
az group show --name $RESOURCE_GROUP_NAME --output json

# Verify ACR deployment
az acr show `
--name 'acrproductapidev001' `
--resource-group $RESOURCE_GROUP_NAME `
--query "{name:name, location:location, sku:sku.name, loginServer:loginServer, AdminEnabled:adminUserEnabled, AccessMode: roleAssignmentMode}" `
--output json

# Verify Container App Environment deployment
az containerapp env show `
--name 'cae-product-api-dev-cin-001' `
--resource-group $RESOURCE_GROUP_NAME `
--query "{name:name, location:location, Properties: properties}" `
--output json

# Verify managed identity deployment
az identity show `
--name 'id-product-api-dev-cin-001' `
--resource-group $RESOURCE_GROUP_NAME `
--query "{name:name, location:location, principalId:principalId, clientId:clientId}" `
--output json

# Verify role assignment for ACR pull permission
$ACR_ID = az acr show `
--name 'acrproductapidev001' `
--resource-group $RESOURCE_GROUP_NAME `
--query id `
--output tsv

$MI_PRINCIPAL_ID = az identity show `
--name 'id-product-api-dev-cin-001' `
--resource-group $RESOURCE_GROUP_NAME `
--query principalId `
--output tsv

az role assignment list `
--assignee $MI_PRINCIPAL_ID `
--all `
--query "[].{Role:roleDefinitionName, Scope:scope, Condition:condition, ConditionVersion:conditionVersion}" `
--output json