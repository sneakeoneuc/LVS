# Configure the Microsoft Azure Provider
provider "azurerm" {
  #version = "~>2"
  #use_msi = true

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }

}
