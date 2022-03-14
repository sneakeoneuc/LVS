#Adding disks this way supports disk_encryption_set_id
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk

module "AddDisks" {
  for_each            = var.data_disk_details
  source              = "./modules/addDisks_v1"
  disk_name           = "${var.vm_name}-disk${each.value["lunID"]}"
  location            = data.azurerm_virtual_network.net.location
  resource_group_name = var.resource_group_name
  virtual_machine_id  = azurerm_linux_virtual_machine.main.id
  disk_size_gb        = each.value["disk_size_gb"]
  managed_disk_type   = each.value["managed_disk_type"]
  lunID               = each.value["lunID"]
  caching             = "ReadWrite"
  #disk_encryption_set_id = var.Encrpyt_all_VM_Disks ? azurerm_disk_encryption_set.disks[0].id : ""

}