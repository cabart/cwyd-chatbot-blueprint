# Prereq

output "prereq_app_reg_consumer_display_name" {
  value = module.cwyd_prereq.app_reg_consumer_display_name
}

output "prereq_app_reg_consumer_client_id" {
  value = module.cwyd_prereq.app_reg_consumer_client_id
}

output "prereq_app_reg_teams_display_name" {
  value = module.cwyd_prereq.app_reg_teams_display_name
}

output "prereq_app_reg_teams_client_id" {
  value = module.cwyd_prereq.app_reg_teams_client_id
}

# Core

output "core_acr_name" {
  value = module.cwyd_core.acr_name
}

output "core_acr_resource_group_name" {
  value = module.cwyd_core.acr_resource_group_name
}
