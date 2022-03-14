locals {
  #sample: /subscriptions/57215661-2f9e-482f-9334-c092e02651ec/resourceGroups/RG-CORENETWORK-PROD-01/providers/Microsoft.Network/virtualNetworks/vnet-cor1-westus2-01/subnets/snet-Apps-cor1-westus2-01
  vNetParts                = split("/", var.subnet_id)
  vnet_resource_group_name = local.vNetParts[4]
  vnet_name                = local.vNetParts[8]
  vnet_Subnet_name         = local.vNetParts[10]
}

#DATA PARTS

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

# Create a resource group if it doesn’t exist
data "azurerm_resource_group" "resourcegroup" {
  name = var.resource_group_name
}

data "azurerm_subnet" "net" {
  name                 = local.vnet_Subnet_name
  virtual_network_name = local.vnet_name
  resource_group_name  = local.vnet_resource_group_name
}

data "azurerm_virtual_network" "net" {
  name                = local.vnet_name
  resource_group_name = local.vnet_resource_group_name
}


################################################################
#EOF
