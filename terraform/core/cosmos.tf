resource "azurerm_cosmosdb_account" "cosmos" {
  name                          = format("cosmos-%s", local.application_context)
  location                      = data.azurerm_resource_group.landing_zone.location
  resource_group_name           = data.azurerm_resource_group.landing_zone.name
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  public_network_access_enabled = !var.enable_private_endpoints

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = data.azurerm_resource_group.landing_zone.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "cosmos" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = format("pep-%s-cosmos", local.application_context)
  location            = data.azurerm_resource_group.landing_zone.location
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  subnet_id           = azurerm_subnet.cywd[0].id
  tags                = var.tags

  private_service_connection {
    name                           = format("psc-%s-cosmos", local.application_context)
    private_connection_resource_id = azurerm_cosmosdb_account.cosmos.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }

  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
}

resource "azurerm_cosmosdb_sql_database" "database" {
  name                = var.cosmos_database_name
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                = var.cosmos_collection_name
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.database.name
  partition_key_paths = ["/userId"]
}
