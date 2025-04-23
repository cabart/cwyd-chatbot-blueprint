resource "azurerm_key_vault" "cwyd" {
  name                          = format("kv%scwyd", local.application_context_short)
  location                      = data.azurerm_resource_group.landing_zone.location
  resource_group_name           = data.azurerm_resource_group.landing_zone.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization     = true
  purge_protection_enabled      = false
  sku_name                      = "standard"
  public_network_access_enabled = !var.enable_private_endpoints
  tags                          = var.tags
}

resource "azurerm_private_endpoint" "key_vault" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = format("pep-%s-keyvault", local.application_context)
  location            = data.azurerm_resource_group.landing_zone.location
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  subnet_id           = azurerm_subnet.cywd[0].id
  tags                = var.tags

  private_service_connection {
    name                           = format("psc-%s-keyvault", local.application_context)
    private_connection_resource_id = azurerm_key_vault.cwyd.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
}
