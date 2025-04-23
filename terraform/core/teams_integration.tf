resource "azurerm_service_plan" "teams" {
  count = var.enable_teams_app ? 1 : 0

  name                = format("asp-%s-teams", local.application_context)
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  location            = data.azurerm_resource_group.landing_zone.location
  sku_name            = var.service_plan_sku_teams
  os_type             = "Windows"
  tags                = var.tags
}

resource "azurerm_windows_web_app" "teams" {
  count = var.enable_teams_app ? 1 : 0

  name                          = format("app-%s-teams", local.application_context)
  resource_group_name           = data.azurerm_resource_group.landing_zone.name
  location                      = data.azurerm_resource_group.landing_zone.location
  service_plan_id               = azurerm_service_plan.teams[0].id
  client_affinity_enabled       = true
  https_only                    = true
  public_network_access_enabled = true # Required for Azure Bot to access Web App
  tags                          = var.tags

  site_config {
    container_registry_use_managed_identity = true
    ftps_state                              = "FtpsOnly"
    application_stack {
      current_stack = "node"
      node_version  = "~18"
    }
  }

  app_settings = {
    "AZURE_FUNCTION_URL" = var.enable_custom_domain ? lower(format("https://%s.%s.azure.%s/conversation",
      var.chatbot_url_prefix,
      local.subdomain,
      var.base_dns_company_domain
    )) : lower(format("https://%s.azurewebsites.net/conversation", azurerm_linux_web_app.cwyd_consumer.name))
    "BACKEND_APP_ID" = var.app_reg_consumer_client_id
    "BLOB_BASE_URL" = var.enable_custom_domain ? lower(format("https://%s.%s.azure.%s/getblob",
      var.chatbot_url_prefix,
      local.subdomain,
      var.base_dns_company_domain
    )) : lower(format("%sgetblob", azurerm_storage_account.cwyd.primary_blob_endpoint))
    "BOT_ID"                    = var.app_reg_teams_client_id
    "OAUTH_CONNECTION_NAME"     = "OAuthSettings"
    "RUNNING_ON_AZURE"          = "1"
    "SSO_EXPECTED_AUDIENCE"     = var.app_reg_teams_client_id
    "SSO_TENANT_ID"             = var.azure_bot_teams_tenant == "" ? data.azurerm_client_config.current.tenant_id : var.azure_bot_teams_tenant
    "WEBSITE_RUN_FROM_PACKAGE"  = "1"
    "WEBSITE_DISABLE_ZIP_CACHE" = "1"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings["BOT_PASSWORD"]
    ]
  }
}

# resource "azurerm_private_endpoint" "teams_webapp" {
#   count = var.enable_private_endpoints && var.enable_teams_app ? 1 : 0

#   name                = format("pep-%s-teams-webapp", local.application_context)
#   location            = data.azurerm_resource_group.landing_zone.location
#   resource_group_name = data.azurerm_resource_group.landing_zone.name
#   subnet_id           = azurerm_subnet.cywd[0].id
#   tags                = var.tags

#   private_service_connection {
#     name                           = format("psc-%s-teams-webapp", local.application_context)
#     private_connection_resource_id = azurerm_windows_web_app.teams[0].id
#     is_manual_connection           = false
#     subresource_names              = ["sites"]
#   }

#   lifecycle {
#     ignore_changes = [
#       private_dns_zone_group
#     ]
#   }
# }

resource "azurerm_bot_service_azure_bot" "teams" {
  count = var.enable_teams_app ? 1 : 0

  name                = format("bot-%s-teams", local.application_context)
  display_name        = "Chat with your data assistant"
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  location            = "global"
  microsoft_app_id    = var.app_reg_teams_client_id
  sku                 = var.azure_bot_sku_teams
  tags                = var.tags
  # public_network_access_enabled = !var.enable_private_endpoints
  # https://learn.microsoft.com/en-us/azure/architecture/example-scenario/teams/securing-bot-teams-channel?WT.mc_id=Portal-Microsoft_Azure_BotService
  public_network_access_enabled = true
  endpoint                      = lower(format("https://%s.azurewebsites.net/api/messages", azurerm_windows_web_app.teams[0].name))
}

# resource "azurerm_private_endpoint" "teams_bot" {
#   count = var.enable_private_endpoints && var.enable_teams_app ? 1 : 0

#   name = format("pep-%s-teams-bot",
#     var.application_context
#   )
#   location            = data.azurerm_resource_group.landing_zone.location
#   resource_group_name = data.azurerm_resource_group.landing_zone.name
#   subnet_id           = azurerm_subnet.cywd[0].id
#   tags                = var.tags

#   private_service_connection {
#     name = format("psc-%s-teams-bot",
#       var.application_context
#     )
#     private_connection_resource_id = azurerm_bot_service_azure_bot.teams[0].id
#     is_manual_connection           = false
#     subresource_names              = ["Bot"]
#   }

#   lifecycle {
#     ignore_changes = [
#       private_dns_zone_group
#     ]
#   }
# }

resource "azurerm_bot_channel_ms_teams" "teams" {
  count = var.enable_teams_app ? 1 : 0

  bot_name            = azurerm_bot_service_azure_bot.teams[0].name
  location            = azurerm_bot_service_azure_bot.teams[0].location
  resource_group_name = data.azurerm_resource_group.landing_zone.name
}
