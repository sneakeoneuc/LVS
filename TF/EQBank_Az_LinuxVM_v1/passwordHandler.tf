locals {
  #If the password is blank, then use the random pssword.
  passwordToUse = var.admin_password != "" ? var.admin_password : random_password.password.result
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "password" {
  name         = azurerm_linux_virtual_machine.main.name
  value        = local.passwordToUse #random_password.password.result
  key_vault_id = data.azurerm_key_vault.eqkeyvault.id
}