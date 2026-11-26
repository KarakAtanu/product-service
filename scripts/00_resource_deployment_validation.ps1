# Validate the bicep files for azure resource deployment.
# This script will build the bicep files and check for any errors in the deployment.

$location = 'centralindia'

az bicep build `
--file ./infrastructure/bicep/main.bicep


az bicep build-params `
--file ./infrastructure/bicep/parameters/dev.bicepparam