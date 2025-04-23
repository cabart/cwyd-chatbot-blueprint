resource "azurerm_storage_account" "cwyd" {
  name                             = format("st%scwyd", local.application_context_short)
  resource_group_name              = data.azurerm_resource_group.landing_zone.name
  location                         = data.azurerm_resource_group.landing_zone.location
  account_tier                     = "Standard"
  account_replication_type         = "GRS"
  https_traffic_only_enabled       = true
  allow_nested_items_to_be_public  = false
  min_tls_version                  = "TLS1_2"
  cross_tenant_replication_enabled = false
  public_network_access_enabled    = !var.enable_private_endpoints
  tags                             = var.tags

  lifecycle {
    ignore_changes = [
      tags["ProjectType"],
    ]
  }

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "POST", "PUT", "OPTIONS"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 200
    }
  }
}

resource "azurerm_private_endpoint" "storage" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = format("pep-%s-storage", local.application_context)
  location            = data.azurerm_resource_group.landing_zone.location
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  subnet_id           = azurerm_subnet.cywd[0].id
  tags                = var.tags

  private_service_connection {
    name                           = format("psc-%s-storage", local.application_context)
    private_connection_resource_id = azurerm_storage_account.cwyd.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
}

resource "azurerm_storage_container" "cwyd" {
  name                  = local.blob_container_name
  storage_account_id    = azurerm_storage_account.cwyd.id
  container_access_type = "private"
}
