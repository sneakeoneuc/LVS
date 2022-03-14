######################################################################################
####  Long View CentOS CIS L1  Build Script ####################################
####  Virtual Machine (VM)  ##########################################################
######################################################################################

#DATA PARTS

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

# Create a resource group if it doesn’t exist
data "azurerm_resource_group" "resourcegroup" {
  name = var.resource_group_name
}

#data "azurerm_availability_set" "example" {
#  name                = "tf-appsecuritygroup"
#  resource_group_name = "my-resource-group"
#}

data "azurerm_key_vault" "eqkeyvault" {
  name                = var.PW_key_vault_name
  resource_group_name = var.PW_key_vault_resource_group
}

data "azurerm_subnet" "eqsubnet" {
  name                 = var.vnet_Subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

# Create network interface
resource "azurerm_network_interface" "eqnic" {
  name                = "${var.vm_name}-NIC"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.resourcegroup.name
  ip_configuration {
    name                          = "${var.resource_group_name}-NicConfiguration"
    subnet_id                     = data.azurerm_subnet.eqsubnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {}
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "main" {
  name                            = var.vm_name
  size                            = var.vm_size
  location                        = var.location
  resource_group_name             = var.resource_group_name
  network_interface_ids           = [azurerm_network_interface.eqnic.id]
  computer_name                   = var.vm_name
  admin_username                  = var.admin_username
  admin_password                  = local.passwordToUse
  disable_password_authentication = false
  provision_vm_agent              = true
  #enable_automatic_updates = true  #Unsupported by Terraform in Linux.
  # timezone                 = "Eastern Standard Time"  #Unsupported by Terraform in Linux.

  #Add to AV Set if availability_set_id is blank.
  availability_set_id = var.availability_set_id != "" ? var.availability_set_id : null

  identity {
    type = "SystemAssigned"
  }

  /* For testing outside EQ Bank.
  plan {
    publisher = var.publisher
    product   = var.offer
    name      = var.sku
  }
  */

  #dynamic blocks only support for_each, not count.
  dynamic "plan" {
    for_each = var.use_dynamic_plan ? [0] : []
    content {
      publisher = var.publisher
      product   = var.offer
      name      = var.sku
    }
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.mpversion
  }

  os_disk {
    name                 = "${var.vm_name}-OSDISK"
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_managed_disk_type
    disk_size_gb         = var.os_disk_disk_size_gb
  }

  tags = var.vm_tags
}


################################################################
#EOF
