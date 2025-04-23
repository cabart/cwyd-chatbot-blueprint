resource "azurerm_container_registry" "cwyd" {
  count                         = var.is_acr_required ? 1 : 0
  name                          = format("acr%s", local.application_context_short)
  resource_group_name           = data.azurerm_resource_group.landing_zone.name
  location                      = data.azurerm_resource_group.landing_zone.location
  sku                           = var.enable_private_endpoints ? "Premium" : "Standard"
  public_network_access_enabled = true # !var.enable_private_endpoints # has to be enabled to be accessed via pipeline
  admin_enabled                 = true
  tags                          = var.tags
}

data "azurerm_container_registry" "cwyd" {
  count               = var.is_acr_required ? 0 : 1
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.landing_zone.name
}

resource "azurerm_private_endpoint" "acr" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = format("pep-%s-acr", local.application_context)
  location            = data.azurerm_resource_group.landing_zone.location
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  subnet_id           = azurerm_subnet.cywd[0].id
  tags                = var.tags

  private_service_connection {
    name                           = format("psc-%s-acr", local.application_context)
    private_connection_resource_id = var.is_acr_required ? azurerm_container_registry.cwyd[0].id : data.azurerm_container_registry.cwyd[0].id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
}
