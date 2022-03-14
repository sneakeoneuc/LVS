######################################################################################
####  Long View Windows 2019 CIS L2  Build Script ####################################
####  Virtual Machine (VM)  ##########################################################
######################################################################################





# Configure the Microsoft Azure Backend
# Get-AzSubscription
tenant_id = "8ce6cd64-f1d8-43f8-a8be-9de82f375ee9"
subscription_id = "c82c18dc-6080-4480-992b-f6544b5789af"

#SET THESE
admin_username = "adminuseraccount"
admin_password = ""  

#Run in Cloud Shell to get subnet ID - https://portal.azure.com/#cloudshell/ 
#Get-AzVirtualNetwork -Name "VNETNAME -ResourceGroupName "VNET-RG" | grep SUBNETNAME 
subnet_id = "/subscriptions/c82c18dc-6080-4480-992b-f6544b5789af/resourceGroups/az-azsmoke-rg-prod/providers/Microsoft.Network/virtualNetworks/az-azsmoke-vnet-prod/subnets/az-azsmoke-vnet-prod-sbn"

vm_name = "azvm143it01"  #set VM name
resource_group_name = "az-azsmoke-rg-prod"
location = "canadacentral"
vm_size = "Standard_D2s_v3"
availability_set_id = "" #Will Require availability id string

#Admin settings
store_admin_password_in_KV = true
PW_key_vault_name = "MyKeyVault143it"
PW_key_vault_resource_group = "MyKeyVaultRG"

#Disk encryption settings
Encrpyt_all_VM_Disks = true
Disk_Encryt_key_vault_name = "MyKeyVault143it"
Disk_Encryt_key_vault_resource_group = "MyKeyVaultRG"

#Backup
backup_vault_enabled = true
backup_vault_name = "RS-BACKUP-EAST-NONPROD"
backup_vault_resource_group = "RG-BACKUP-NONPROD"
backup_vault_policy_name = "DefaultPolicy"
#wad_version = 

#Disks – comment out data_disk_details block if none is required (or delete)
#NOTE:: NON-PROD subscription has an Azure Policy enforcing Premium Disks

os_disk_managed_disk_type = "Standard_LRS"
#os_disk_disk_size_gb= 127  #change size -  default is 127GB - remove first comment

#data_disk_details = {
#   disk1 = {
#     disk_size_gb      = 10,
#      managed_disk_type = "Premium_LRS"
#      lunID             = 1
#    }
    #,      #uncomment section if additional data disks required. Increase LUNID +1
     # disk2 = {
     # disk_size_gb      = 250,
     # managed_disk_type = "Premium_LRS"
     # lunID             = 2
    #}
#}

use_dynamic_plan=true

# VARIABLE DECLARATION for OS image
#publisher = "center-for-internet-security-inc" 
#offer = "cis-windows-server-2019-v1-0-0-l2"
#sku = "cis-ws2019-l2"
#mpversion = "latest"  
image_URN = "center-for-internet-security-inc:cis-windows-server-2019-v1-0-0-l2:cis-ws2019-l2:latest"


# These are the tags to be applied to the VM.
#NOTE::: original script in REPO and DOC refer to thi as 'vm_tags' - update to 'tags_customer_sub'
#Example below - get details from Request Form

tags_customer_sub= {
    LVSMAN                  = "Enabled"
    LVSMON                  = "Yes"
    "ASSET CLASSIFICATION"  = "Non-Critical"
    "APPLIED APPLICATION"   = "ApplicationName"
    ROLE                    = "Application - function"
    OWNER                   = "Owner"
    "Asset Category"        = "Internal Asset"
    "Information Type"      = "Internal"
    "Information Operation" = "Pass Through"
    env                     = "non-pcf"
  } 
