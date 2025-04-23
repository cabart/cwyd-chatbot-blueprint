module "cwyd_prereq" {
  source = "../../prereq"

  providers = {
    azurerm.application = azurerm
    azurerm.perimeter   = azurerm.perimeter
  }

  # Project settings
  application_name                 = "mycwyd"
  location_alias                   = "chn"
  stage_alias                      = "dev"
  parent_index                     = ""
  tags                             = local.tags
  landing_zone_resource_group_name = "rgr-mycwyd-chn-dev"

  # DNS settings
  enable_custom_domain         = false
  base_dns_company_domain      = ""
  base_dns_resource_group_name = ""
  #   enable_custom_domain         = true
  #   base_dns_company_domain      = "chatwithme.ch"
  #   base_dns_resource_group_name = "rgr-dnszones-chn-prod"

  # Blueprint settings
  chatbot_url_prefix                             = "chat"
  app_reg_entraid_group_consumer                 = []
  sp_ado_service_connection_ccoe_name            = ""
  sp_ado_service_connection_applicationteam_name = ""
  service_principal_owners                       = []
  enable_teams_app                               = false
}
