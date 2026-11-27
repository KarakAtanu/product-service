$LOCATION = "centralindia"
$DEPLOYMENT_NAME = "product-api-foundation-dev"
$TEMPLATE_FILE = "infrastructure/bicep/main.bicep"
$PARAMETER_FILE = "infrastructure/bicep/parameters/dev.bicepparam"

# Preview the deployment plan - With Microsoft Graph extension, you can use the `what-if` operation to preview the changes that will be made by the deployment.
<#
az deployment sub what-if `
  --name $DEPLOYMENT_NAME `
  --location $LOCATION `
  --template-file $TEMPLATE_FILE `
  --parameters $PARAMETER_FILE
  #>


# Deploy the resources

az deployment sub create `
  --name $DEPLOYMENT_NAME `
  --location $LOCATION `
  --template-file $TEMPLATE_FILE `
  --parameters $PARAMETER_FILE
