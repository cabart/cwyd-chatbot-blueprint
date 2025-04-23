data "azurerm_dns_zone" "base" {
  provider = azurerm.perimeter
  count    = var.enable_custom_domain ? 1 : 0

  name = format("azure.%s",
    var.base_dns_company_domain
  )
  resource_group_name = var.base_dns_resource_group_name
}

resource "azurerm_dns_zone" "subdomain" {
  provider = azurerm.application
  count    = var.enable_custom_domain ? 1 : 0

  name                = lower(format("%s.%s", local.subdomain, data.azurerm_dns_zone.base[0].name))
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  tags                = var.tags
}

resource "azurerm_dns_ns_record" "subdomain" {
  provider = azurerm.perimeter
  count    = var.enable_custom_domain ? 1 : 0

  name                = lower(local.subdomain)
  zone_name           = data.azurerm_dns_zone.base[0].name
  resource_group_name = data.azurerm_dns_zone.base[0].resource_group_name
  ttl                 = 300
  records             = azurerm_dns_zone.subdomain[0].name_servers
  tags                = var.tags
}
