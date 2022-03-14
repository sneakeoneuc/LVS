variable "tenant_id" {
  type        = string
  description = "Tenant ID"
  #sample     = "5806bd64-fde5-449f-9a07-655a9b15ae50"
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID"
  #sample  default   = "57215661-2f9e-482f-9334-c092e02651ec"
}

/*********************************************************
*** VM Details
*********************************************************/

variable "vm_name" {
  type        = string
  description = "The name of the virtual machine to be created."
  #sample  default   = "vm-01"
}

variable "resource_group_name" {
  type        = string
  description = "The Resource Group for the virtual machine."
  #Sample  default   = "AZRG-CNC-EQB-DEV-TERRAFORM"
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
  description = "Azure VM size. example 'Standard_DS2s_v2'."
  #Sample default  = "Standard_D2s_v3"
}

variable "availability_set_id" {
  type        = string
  description = "The availibility set is created outside of this process.  If this string is empty, then VM will not use AV Set.  Otherwise, it should be the AV Set ID."
  default     = ""
  #sample     = "/subscriptions/57215661-2f9e-482f-9334-c092e02651ec/resourceGroups/RG-CORECOMPUTE-PROD-01/providers/Microsoft.Compute/availabilitySets/av-set-02"
}

/*********************************************************
*** Variables related to TAGS
*********************************************************/

variable "tags_customer_sub" {
  type        = map(any)
  description = "These tags can be set in SubID.auto.tfvars.json.  They will apply to all Azure Resources built in a subscription matching the subID."
  default     = {}
}

#TODO: Make sure this value is set. It doesn't look like it is.  
variable "SRId" {
  type        = string
  description = "This is the Order ID of the DWPa Service Request to build the Azure Resource."
  default     = ""
}

/*********************************************************
*** OS Image details.
*********************************************************/

variable "image_URN" {
  type        = string
  description = "Azure Image Publisher, Offer, SKU, and Version in one string separate by a colon (:).  I.e 'Publisher:Offer:Sku:Version'.  Further information here - https://docs.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage"
  #default = "center-for-internet-security-inc:cis-centos-7-v2-1-1-l1:cis-centos7-l1:3.0.4"
  #sample default = "OpenLogic:CentOS:7.5:latest"
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
  type        = string
  description = "The type of disk cahcing enabled on the OS disk."
  default     = "ReadWrite"
}

variable "os_disk_managed_disk_type" {
  type        = string
  description = "The type of disk to use for the OS disk."
  default     = "StandardSSD_LRS"
}

variable "os_disk_disk_size_gb" {
  type        = string
  description = "The size of the OS disk."
  default     = "127"
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

variable "subnet_id" {
  type = string
  #default     = ""
  description = "Subnet ID of the subnet to join the VM to."
  #sample: /subscriptions/57215661-2f9e-482f-9334-c092e02651ec/resourceGroups/RG-CORENETWORK-PROD-01/providers/Microsoft.Network/virtualNetworks/vnet-cor1-westus2-01/subnets/snet-Apps-cor1-westus2-01
}

# variable "vnet_resource_group_name" {
#   type        = string
#   description = "VNET Resource Group Name"
#   default     = "AZRG-EQB-NETWORK-DEV"
# }

# variable "vnet_name" {
#   type        = string
#   description = "Name for the VNET"
#   default     = "AZ-CNC-EQB-DEV-VNT"
# }

# variable "vnet_Subnet_name" {
#   type        = string
#   description = "Subnet Name for the Vnet"
#   default     = "AZ-CNC-EQB-DEV-NONPCF-SBN"
# }

/*********************************************************
*** Key Vault for VM Password
*********************************************************/

variable "store_admin_password_in_KV" {
  type        = bool
  description = "True value stores the password in a Key Vault for safe keeping.  If the admin_password is blank, then a random password will be generated and may need to be stored for use."
  default     = false
}

variable "PW_key_vault_name" {
  type        = string
  description = "The name of the Key Vault where the password will be stored."
  default     = ""
}

variable "PW_key_vault_resource_group" {
  type        = string
  description = "The name of the Resource Group that holds the Key Vault to be used for password storage."
  default     = ""
}

/*********************************************************
*** Key Vault for Disk Encryption
*********************************************************/

variable "Encrpyt_all_VM_Disks" {
  type        = bool
  description = "Set to true to encrpyt all the disks."
  default     = false
}

variable "Disk_Encryt_key_vault_name" {
  type        = string
  description = "The name of the Key Vault to use for Disk Encryption."
  default     = ""
}

variable "Disk_Encryt_key_vault_resource_group" {
  type        = string
  description = "The name of the Resource Group that contains the  Key Vault to be used for Disk Encryption."
  default     = ""
}

/*********************************************************
*** Backup Vault to assign backup policy to.
*********************************************************/

variable "backup_vault_enabled" {
  type        = bool
  description = "VM will be added to the backup policy specified in backup_vault_name - backup_vault_policy_name if true."
  default     = false
}

variable "backup_vault_name" {
  type        = string
  description = "The backup policy is assigned in this TF."
  default     = ""
}

variable "backup_vault_resource_group" {
  type        = string
  description = "Resource Group of the Backup Vault referenced in backup_vault_name."
  default     = ""
}

variable "backup_vault_policy_name" {
  type        = string
  description = "Resource Group of the Backup Vault referenced in backup_vault_name."
  default     = "" #DefaultPolicy
}
