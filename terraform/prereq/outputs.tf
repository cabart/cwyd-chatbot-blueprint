# output "subdomain_name" {
#   value = azurerm_dns_zone.subdomain.id
# }

# output "subdomain_id" {
#   value = lower(format("%s.%s", local.subdomain, data.azurerm_dns_zone.base.name))
# }

output "app_reg_consumer_display_name" {
  value = azuread_application_registration.auth_consumer.display_name
}

output "app_reg_consumer_client_id" {
  value = azuread_application_registration.auth_consumer.client_id
}

output "app_reg_teams_display_name" {
  value = var.enable_teams_app ? azuread_application_registration.teams_integration[0].display_name : ""
}

output "app_reg_teams_client_id" {
  value = var.enable_teams_app ? azuread_application_registration.teams_integration[0].client_id : ""
}
