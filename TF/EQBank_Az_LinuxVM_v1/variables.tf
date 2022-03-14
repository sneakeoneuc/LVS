variable "tenant_id" {
  type        = string
  description = "Tenant ID"
  default     = "9b0ad93b-3d88-4102-a9ae-5782b6f0a134"
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID"
  default     = "f36f2006-db98-4aab-ba10-c40685705d65"
}

/*********************************************************
*** VM Details
*********************************************************/

variable "vm_name" {
  type        = string
  description = "The name of the virtual machine to be created."
}

variable "resource_group_name" {
  type        = string
  description = "The Resource Group for the virtual machine."
  default     = "AZRG-CNC-EQB-DEV-TERRAFORM"
}

variable "location" {
  type    = string
  default = "Canada Central"
}

variable "admin_username" {
  type        = string
  description = "Default login account name."
  default     = "adminuser"
}

variable "admin_password" {
  type        = string
  description = "The admin password for the VM.  If the admin PW is blank, randomly generte one.  store_admin_password_in_KV can be used to store it in an Azure Key Vault."
  default     = ""
  sensitive   = true
}

variable "vm_size" {
  type        = string
  description = "Azure VM size. example 'Standard_DS2_v2'."
  default     = "Standard_D2s_v3"
}

variable "vm_tags" {
  type        = map(any)
  description = "The tags that will be applied to the Virtual Machine"
  default = {
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
}


variable "availability_set_id" {
  type        = string
  description = "The availibility set is created outside of this process.  If this string is empty, then VM will not use AV Set.  Otherwise, it should be the AV Set ID."
  default     = ""
}

/*********************************************************
*** OS Image details.
*********************************************************/

# VARIABLE DECLARATION for OS image
variable "publisher" {
  type    = string
  default = "center-for-internet-security-inc"
}
variable "offer" {
  type    = string
  default = "cis-centos-7-v2-1-1-l1" #Use this for CentOS 7 L1
  #default = "cis-ubuntu-linux-1604-v1-0-0-l1"   #Use this for Ubuntu
}
variable "sku" {
  type    = string
  default = "cis-centos7-l1"
}

variable "mpversion" {
  type    = string
  default = "3.0.4"
  #current versions available - Jan 2021
  #default = "3.0.4"   # = CentOS 7.8.2003
  #default = "3.0.5"   # = CentOS 7.8.2003
  #default = "3.0.6"   # = CentOS 7.9.2009
  #default = "3.0.7"   # = CentOS 7.9.2009
  #default = "latest"  # = 3.0.6 = CentOS 7.9.2009


}

variable "use_dynamic_plan" {
  type        = bool
  default     = false
  description = "If true, the image details (publisher, offer, etc.) will be used in by a plan block which describes a Marketplace Image."
}


/*********************************************************
*** OS Disk variables
*********************************************************/

variable "os_disk_caching" {
  type    = string
  default = "ReadWrite"
}

variable "os_disk_managed_disk_type" {
  type    = string
  default = "Premium_LRS"
}

variable "os_disk_disk_size_gb" {
  type    = string
  default = "100"
}

/*********************************************************
*** Data Disk variables
*********************************************************/
variable "data_disk_details" {
  type        = map(object({ disk_size_gb = number, managed_disk_type = string, lunID = number }))
  description = "A map of disks to add.  MAKE SURE THE LUNID IS UNIQUE or the process will fail.  An empty array (e.g. []) will not add disks."
  default     = {} #Empty array = 0 disks added.
}
/*Sample - 2 disks
  default = [
    {
      disk_size_gb      = 100,
      managed_disk_type = "StandardSSD_LRS"
      lunID             = 10
    },
    {
      disk_size_gb      = 100,
      managed_disk_type = "StandardSSD_LRS"
      lunID             = 11
    }
  ]*/

/* SAMPLES
    Sample of 0 disks.
    default = []   
    }

    Sample of 2 disks.
      default = [
        {
          disk_size_gb      = 100,
          managed_disk_type = "StandardSSD_LRS"
          lunID             = 10
        },
        {
          disk_size_gb      = 100,
          managed_disk_type = "StandardSSD_LRS"
          lunID             = 11
        }
      ]
  */





/*********************************************************
*** Networking information to attch VM to.
*********************************************************/

variable "vnet_resource_group_name" {
  type        = string
  description = "VNET Resource Group Name"
  default     = "AZRG-EQB-NETWORK-DEV"
}

variable "vnet_name" {
  type        = string
  description = "Name for the VNET"
  default     = "AZ-CNC-EQB-DEV-VNT"
}

variable "vnet_Subnet_name" {
  type        = string
  description = "Subnet Name for the Vnet"
  default     = "AZ-CNC-EQB-DEV-NONPCF-SBN"
}

/*********************************************************
*** Key Vault for VM Password
*********************************************************/

variable "store_admin_password_in_KV" {
  type        = bool
  description = "True value stores the password in a Key Vault for safe keeping.  If the admin_password is blank, then a random password will be generated and may need to be stored for use."
  default     = false
}

variable "PW_key_vault_name" {
  type    = string
  default = "AZRG-CNC-EQB-TRF-VAULT"
}

variable "PW_key_vault_resource_group" {
  type    = string
  default = "AZRG-CNC-EQB-DEV-TERRAFORM"
}

/*********************************************************
*** Key Vault for Disk Encryption
*********************************************************/

variable "Encrpyt_all_VM_Disks" {
  type        = bool
  description = "Set to true to encrpyt all the disks."
  default     = true
}

variable "Disk_Encryt_key_vault_name" {
  type    = string
  default = "AZRG-CNC-EQB-TRF-VAULT"
}

variable "Disk_Encryt_key_vault_resource_group" {
  type    = string
  default = "AZRG-CNC-EQB-DEV-TERRAFORM"
}

/*********************************************************
*** Backup Vault to assign backup policy to.
*********************************************************/

variable "backup_vault_enabled" {
  type        = bool
  description = "VM will be added to the backup policy specified in backup_vault_name - backup_vault_policy_name if true."
  default     = true
}

variable "backup_vault_name" {
  type        = string
  description = "The backup policy is assigned in this TF."
  default     = "RG-BACKUP-DR-PROD"
}

variable "backup_vault_resource_group" {
  type        = string
  description = "Resource Group of the Backup Vault referenced in backup_vault_name."
  default     = "RS-BACKUP-CAE-PROD"
}

variable "backup_vault_policy_name" {
  type        = string
  description = "Resource Group of the Backup Vault referenced in backup_vault_name."
  default     = "DefaultPolicy"
}