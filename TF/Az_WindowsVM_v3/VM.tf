locals {
  imageParts      = split(":", var.image_URN)
  image_publisher = local.imageParts[0]
  image_offer     = local.imageParts[1]
  image_sku       = local.imageParts[2]
  image_version   = local.imageParts[3]
}


# Create network interface
resource "azurerm_network_interface" "nic" {

  name                = "${var.vm_name}-NIC"
  location            = data.azurerm_virtual_network.net.location
  resource_group_name = data.azurerm_resource_group.resourcegroup.name
  ip_configuration {
    name                          = "${var.resource_group_name}-NicConfiguration"
    subnet_id                     = data.azurerm_subnet.net.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {}
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "main" {
  name                     = var.vm_name
  size                     = var.vm_size
  location                 = data.azurerm_virtual_network.net.location
  resource_group_name      = var.resource_group_name
  network_interface_ids    = [azurerm_network_interface.nic.id]
  computer_name            = var.vm_name
  admin_username           = var.admin_username
  admin_password           = local.passwordToUse
  provision_vm_agent       = true
  enable_automatic_updates = true
  # timezone                 = "Eastern Standard Time"

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
      publisher = local.image_publisher
      product   = local.image_offer
      name      = local.image_sku
    }
  }

  source_image_reference {
    publisher = local.image_publisher
    offer     = local.image_offer
    sku       = local.image_sku
    version   = local.image_version
  }

  os_disk {
    name                 = "${var.vm_name}-OSDISK"
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_managed_disk_type
    disk_size_gb         = var.os_disk_disk_size_gb
  }

  tags = module.tags.full_tag_list

}

################################################################
#EOF