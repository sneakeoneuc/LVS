#ADDITIONAL PLAN VALIDATION
#There's no way to throw an error in Terraform.

locals {
  #These have to match.  The variables are used to setup the AzureRM provider, and the data cannot be used to set them.
  assert_correct_subscription_id = data.azurerm_subscription.current.subscription_id == var.subscription_id ? null : file("ERROR: Terraform is not targeting the correct subscription.  Set the default subscription using az account set")
  assert_correct_tenent_id       = data.azurerm_subscription.current.tenant_id == var.tenant_id ? null : file("ERROR: Terraform is not logged into the correct tenant.")
}