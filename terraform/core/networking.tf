resource "azurerm_subnet" "cywd" {
  count = var.enable_private_endpoints ? 1 : 0

  name                 = format("snet-%s-private", local.application_context)
  virtual_network_name = data.azurerm_virtual_network.vnet[0].name
  resource_group_name  = data.azurerm_resource_group.landing_zone.name
  address_prefixes     = var.subnet_private_address_prefixes
}

resource "azurerm_subnet" "cwyd_consumer" {
  count = var.enable_private_endpoints ? 1 : 0

  name                 = format("snet-%s-delegation", local.application_context)
  virtual_network_name = data.azurerm_virtual_network.vnet[0].name
  resource_group_name  = data.azurerm_resource_group.landing_zone.name
  address_prefixes     = var.subnet_delegated_address_prefixes

  delegation {
    name = "delegation-serverFarms"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
