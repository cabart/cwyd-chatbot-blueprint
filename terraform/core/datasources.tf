data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "landing_zone" {
  name = var.landing_zone_resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = format("vnet-%s-private", local.application_context)
  resource_group_name = data.azurerm_resource_group.landing_zone.name
}

data "azurerm_dns_zone" "subdomain" {
  count = var.enable_custom_domain ? 1 : 0

  name = lower(format("%s.azure.%s",
    local.subdomain,
    var.base_dns_company_domain
  ))
  resource_group_name = data.azurerm_resource_group.landing_zone.name
}
