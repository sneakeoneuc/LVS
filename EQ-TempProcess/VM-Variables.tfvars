tenant_id = "5806bd64-fde5-449f-9a07-655a9b15ae50"
subscription_id = "57215661-2f9e-482f-9334-c092e02651ec"
#admin_username = "adminUsername"

vnet_resource_group_name = "RG-CORENETWORK-PROD-01"
vnet_name = "vnet-cor1-westus2-01"
vnet_Subnet_name = "snet-Apps-cor1-westus2-01"

#vm_name = "vmEQCOS701"
resource_group_name = "RG-CORECOMPUTE-PROD-01"
location = "westus2"
vm_size = "Standard_D4_v4"
availability_set_id = ""

#Admin settings
store_admin_password_in_KV = true
PW_key_vault_name = "kv-CMPLVSDE-01"
PW_key_vault_resource_group = "RG-SECURE-01"

#Disk encryption settings
Encrpyt_all_VM_Disks = true
Disk_Encryt_key_vault_name = "kv-CMPLVSDE-01"
Disk_Encryt_key_vault_resource_group = "RG-SECURE-01"

#Backup
backup_vault_enabled = true
backup_vault_name = "bv-RecoveryServices-01"
backup_vault_resource_group = "RG-BACKUP-PROD-01"
backup_vault_policy_name = "vm-recovery-vault-policy"
#wad_version = 

#Disks
data_disk_details = {
    disk1 = {
      disk_size_gb      = 100,
      managed_disk_type = "StandardSSD_LRS"
      lunID             = 10
    },
      disk2 = {
      disk_size_gb      = 100,
      managed_disk_type = "StandardSSD_LRS"
      lunID             = 11
    }
}

# VARIABLE DECLARATION for OS image
publisher = "MicrosoftWindowsServer" 
offer = "WindowsServer"
sku = "2016-Datacenter-smalldisk"
mpversion = "latest"

# These are the tags to be applied to the VM.
vm_tags= {
    LVSMAN                  = "Enabled"
    LVSMON                  = "Yes"
    "ASSET CLASSIFICATION"  = "Semi-Critical"
    "APPLIED APPLICATION"   = "Jumpbox"
    ROLE                    = "JumpBox for Enterprise Data Governance"
    OWNER                   = "DBA"
    "Asset Category"        = "Internal Asset"
    "Information Type"      = "Internal"
    "Information Operation" = "Pass Through"
    env                     = "non-pcf"
  }