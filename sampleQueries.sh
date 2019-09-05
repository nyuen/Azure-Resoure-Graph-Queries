#!/bin/bash

# Counting resource on Azure
az graph query -q "count"

#List VMs using a Standard_DS2_v2 size
az graph query -q 'where properties.hardwareProfile.vmSize == "Standard_DS2_v2" | project name, location'

#Count resources by region
az graph query -q 'summarize count() by location'

#Counting VMs by OS Type
az graph query -q "where type =~ 'Microsoft.Compute/virtualMachines' | extend os = properties.storageProfile.osDisk.osType | summarize count() by tostring(os)"

#Find subscription with PublicIps
az graph query -q "where type contains 'publicIPAddresses' and isnotempty(properties.ipAddress) | summarize count () by subscriptionId"

#List resources with a specific tag
az graph query -q "where tags.environment=~'internal' | project name"

#Get VMSS capacity and size
az graph query -q "where type=~ 'microsoft.compute/virtualmachinescalesets' | where name contains 'contoso' | project subscriptionId, name, location, resourceGroup, Capacity = toint(sku.capacity), Tier = sku.name | order by Capacity desc"

#Search VMs by RegEx
az graph query -q "where type =~ 'microsoft.compute/virtualmachines' and name matches regex @'^Contoso(.*)[0-9]+$' | project name | order by name asc"

#VMs connected to premium disk
az graph query -q "where type =~ 'Microsoft.Compute/virtualmachines' and properties.hardwareProfile.vmSize == 'Standard_B2s' | extend disk = properties.storageProfile.osDisk.managedDisk | where disk.storageAccountType == 'Premium_LRS' | project disk.id"

#VMs with a Data disk greater or equal to 128Gb
az graph query -q 'where type == "microsoft.compute/virtualmachines" | where location == "eastus" | where properties.storageProfile.osDisk.diskSizeGB >= 32 | where array_length(properties.storageProfile.dataDisks) >= 1 | mvexpand disk=properties.storageProfile.dataDisks | where disk.diskSizeGB >= 128 | summarize make_list(disk.diskSizeGB) by name, location"'

#Find rogue email addresses in Azure Alert Groups
az graph query -q 'where type =~ "Microsoft.Insights/ActionGroups" | mvexpand emailInfo=properties.emailReceivers | extend email=emailInfo.emailAddress | extend domain=split(email,"@")[1] | where domain == "test.com" | summarize makelist(email) by tostring(ActionGroup=properties.groupShortName)' -o jsonc


