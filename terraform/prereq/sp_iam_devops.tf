resource "azurerm_role_assignment" "keyvault_admin" {
  count = var.sp_ado_service_connection_applicationteam_name == "" ? 0 : 1

  scope                = data.azurerm_resource_group.landing_zone.id
  role_definition_name = data.azurerm_role_definition.keyvault_admin.name
  principal_id         = data.azuread_service_principal.ado_service_connection_applicationteam[0].object_id
}
