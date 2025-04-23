resource "azurerm_search_service" "cwyd" {
  name                          = format("srch-%s", local.application_context)
  resource_group_name           = data.azurerm_resource_group.landing_zone.name
  location                      = data.azurerm_resource_group.landing_zone.location
  sku                           = var.azure_cognitive_search_sku
  semantic_search_sku           = "standard"
  local_authentication_enabled  = true      # Special configuration to allow keys and RBAC to be active. This is used by the ingestion pipeline
  authentication_failure_mode   = "http403" # Special configuration to allow keys and RBAC to be active. This is used by the ingestion pipeline
  public_network_access_enabled = !var.enable_private_endpoints
  network_rule_bypass_option    = "AzureServices"
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags["ProjectType"],
    ]
  }
}

resource "azurerm_private_endpoint" "search_service" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = format("pep-%s-search", local.application_context)
  location            = data.azurerm_resource_group.landing_zone.location
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  subnet_id           = azurerm_subnet.cywd[0].id
  tags                = var.tags

  private_service_connection {
    name                           = format("psc-%s-search", local.application_context)
    private_connection_resource_id = azurerm_search_service.cwyd.id
    is_manual_connection           = false
    subresource_names              = ["searchService"]
  }

  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
}
