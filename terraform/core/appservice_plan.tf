resource "azurerm_service_plan" "cwyd" {
  name                = format("asp-%s", local.application_context)
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  location            = data.azurerm_resource_group.landing_zone.location
  sku_name            = var.service_plan_sku
  os_type             = "Linux"
  tags                = var.tags
}
