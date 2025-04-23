data "azuread_client_config" "current" {}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

data "azuread_service_principal" "ado_service_connection_ccoe" {
  count = var.sp_ado_service_connection_ccoe_name == "" ? 0 : 1

  display_name = var.sp_ado_service_connection_ccoe_name
}

data "azuread_service_principal" "ado_service_connection_applicationteam" {
  count = var.sp_ado_service_connection_applicationteam_name == "" ? 0 : 1

  display_name = var.sp_ado_service_connection_applicationteam_name
}

data "azuread_users" "service_principal_owners" {
  user_principal_names = var.service_principal_owners
}

data "azurerm_subscription" "perimeter" {
  provider = azurerm.perimeter
}

data "azurerm_role_definition" "keyvault_admin" {
  name = "Key Vault Administrator"
}

data "azurerm_resource_group" "landing_zone" {
  name = var.landing_zone_resource_group_name
}
