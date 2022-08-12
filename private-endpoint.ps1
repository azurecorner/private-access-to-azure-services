$rg = 'SERVICE-ENDPOINT-RG'
$nsg ='ERP-SERVERS-NSG'
$location ='westeurope'

az group create --location $location --name $rg 
# Create NSG  ERP-SERVERS-NSG
az network nsg create --name $nsg  --resource-group $rg --location $location

#2.  create an outbound rule to allow access to Storage, in the Cloud Shell
az network nsg rule create `
 --resource-group $rg `
 --nsg-name $nsg `
 --name Allow_Storage `
 --priority 190 `
 --direction Outbound `
 --source-address-prefixes "VirtualNetwork" `
 --source-port-ranges '*' `
 --destination-address-prefixes "Storage" `
 --destination-port-ranges '*' `
 --access Allow `
 --protocol '*' `
 --description "Allow access to Azure Storage"

 #3. create an outbound rule to deny all internet access, in the Cloud Shell

 az network nsg rule create `
 --resource-group $rg `
 --nsg-name $nsg `
 --name Deny_Internet `
 --priority 200 `
 --direction Outbound `
 --source-address-prefixes "VirtualNetwork" `
 --source-port-ranges '*' `
 --destination-address-prefixes "Internet" `
 --destination-port-ranges '*' `
 --access Deny `
 --protocol '*' `
 --description "Deny access to Internet."

 #4. create a storage account for engineering documents
 $RANDOM  ='logcorner'
 $STORAGEACCT=$(az storage account create `
 --resource-group $rg `
 --name engineeringdocs$RANDOM `
 --sku Standard_LRS )

 $STORAGEACCT ='engineeringdocslogcorner'
 #5. store the primary key for your storage in a variable

 $STORAGEKEY=$(az storage account keys list `
 --resource-group $rg `
 --account-name $STORAGEACCT `
 --query [0].value -o tsv )
#6. create an Azure file share called erp-data-share
az storage share create `
 --account-name $STORAGEACCT `
 --account-key $STORAGEKEY `
 --name "erp-data-share"

#7.  assign the Microsoft.Storage endpoint to the subnet
# create ERP-servers VNET and Databases subnet
az network vnet subnet update `
 --vnet-name ERP-servers `
 --resource-group $rg `
 --name Databases `
 --service-endpoints Microsoft.Storage