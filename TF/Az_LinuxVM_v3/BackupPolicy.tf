# This resource is defined to fix the timeout problem in the creation of 'azurerm_recovery_services_protected_vm.*' resources
#suggested from here: https://stackoverflow.com/questions/66443651/how-to-resolve-timeout-error-in-azurerm-backup-protected-vm/66453492#66453492
#Adds delay between VM creation and azurerm_backup_protected_vm creation.
resource "null_resource" "delay" {
  count = var.backup_vault_enabled ? 1 : 0
  provisioner "local-exec" {
    #Delay 120 seconds
    command = "ping 127.0.0.1 -n 180 > nul"
  }

  depends_on = [
    azurerm_linux_virtual_machine.main
  ]
}

data "azurerm_backup_policy_vm" "protection_policy" {
  count               = var.backup_vault_enabled ? 1 : 0
  name                = var.backup_vault_policy_name
  resource_group_name = var.backup_vault_resource_group
  recovery_vault_name = var.backup_vault_name
}


resource "azurerm_backup_protected_vm" "protection_assignment" {
  count               = var.backup_vault_enabled ? 1 : 0
  resource_group_name = var.backup_vault_resource_group
  recovery_vault_name = var.backup_vault_name
  source_vm_id        = azurerm_linux_virtual_machine.main.id
  backup_policy_id    = data.azurerm_backup_policy_vm.protection_policy[count.index].id

  depends_on = [null_resource.delay]

}
