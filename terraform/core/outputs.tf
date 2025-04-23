output "acr_name" {
  value = var.is_acr_required ? azurerm_container_registry.cwyd[0].name : data.azurerm_container_registry.cwyd[0].name
}

output "acr_resource_group_name" {
  value = var.is_acr_required ? azurerm_container_registry.cwyd[0].resource_group_name : data.azurerm_container_registry.cwyd[0].resource_group_name
}
