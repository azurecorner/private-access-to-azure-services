az account set --subscription {subscriptionId}
$STORAGEACCT ='engineeringdocslogcorner'
 #5. store the primary key for your storage in a variable
 $rg = 'SERVICE-ENDPOINT-RG'
 $STORAGEKEY=$(az storage account keys list `
 --resource-group $rg `
 --account-name $STORAGEACCT `
 --query [0].value -o tsv )

 Write-Host $STORAGEKEY
