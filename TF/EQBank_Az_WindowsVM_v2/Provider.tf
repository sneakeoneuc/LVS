# Configure the Microsoft Azure Backend
#Partial backend configuration - https://www.terraform.io/docs/language/settings/backends/configuration.html#partial-configuration
terraform {
  backend "azurerm" {
    #    resource_group_name  = "AZRG-CNC-EQB-DEV-TERRAFORM"
    #    storage_account_name = "eqbterraformstate"
    #    container_name       = "tfstate"
    #    key                  = "prod.terraform.tfstate"
    #    use_msi              = true
    #    subscription_id      = "f36f2006-db98-4aab-ba10-c40685705d65"
    #    tenant_id            = "9b0ad93b-3d88-4102-a9ae-5782b6f0a134"
  }
}

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