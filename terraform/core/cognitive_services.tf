resource "azurerm_cognitive_account" "openai" {
  name                          = format("oai-%s-openai", local.application_context_cognitive_services)
  custom_subdomain_name         = format("oai-%s", local.application_context_cognitive_services)
  resource_group_name           = data.azurerm_resource_group.landing_zone.name
  location                      = var.cognitive_services_location
  kind                          = "OpenAI"
  sku_name                      = "S0"
  dynamic_throttling_enabled    = false
  fqdns                         = []
  public_network_access_enabled = !var.enable_private_endpoints
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "openai_search_index_data_reader" {
  # count = var.auth_type == "rbac" ? 1 : 0

  scope                = azurerm_search_service.cwyd.id
  role_definition_name = "Search Index Data Reader"
  principal_id         = azurerm_cognitive_account.openai.identity[0].principal_id

  depends_on = [azurerm_cognitive_account.openai]
}

resource "azurerm_role_assignment" "openai_search_index_data_contributor" {
  # count = var.auth_type == "rbac" ? 1 : 0

  scope                = azurerm_search_service.cwyd.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_cognitive_account.openai.identity[0].principal_id

  depends_on = [azurerm_cognitive_account.openai]
}

resource "azurerm_role_assignment" "openai_search_service_contributor" {
  # count = var.auth_type == "rbac" ? 1 : 0

  scope                = azurerm_search_service.cwyd.id
  role_definition_name = "Search Service Contributor"
  principal_id         = azurerm_cognitive_account.openai.identity[0].principal_id

  depends_on = [azurerm_cognitive_account.openai]
}

resource "azurerm_private_endpoint" "openai" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = format("pep-%s-openai", local.application_context)
  location            = data.azurerm_resource_group.landing_zone.location
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  subnet_id           = azurerm_subnet.cywd[0].id
  tags                = var.tags

  private_service_connection {
    name                           = format("psc-%s-openai", local.application_context)
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "openAi-privateDnsZone-via-Terraform"
    private_dns_zone_ids = [var.openai_private_dns_zone_id]
  }
}

resource "azurerm_cognitive_account" "content_safety" {
  name = format("cs-%s-ContentSafety", local.application_context)
  custom_subdomain_name = format("cs-%s",
    local.application_context_cognitive_services
  )
  resource_group_name           = data.azurerm_resource_group.landing_zone.name
  location                      = var.cognitive_services_location
  kind                          = "ContentSafety"
  sku_name                      = "S0"
  dynamic_throttling_enabled    = false
  fqdns                         = []
  public_network_access_enabled = !var.enable_private_endpoints
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "content_safety" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = format("pep-%s-contentsafety", local.application_context)
  location            = data.azurerm_resource_group.landing_zone.location
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  subnet_id           = azurerm_subnet.cywd[0].id
  tags                = var.tags

  private_service_connection {
    name                           = format("psc-%s-contentsafety", local.application_context)
    private_connection_resource_id = azurerm_cognitive_account.content_safety.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
}

resource "azurerm_cognitive_account" "form_recognizer" {
  name                          = format("di-%s-FormRecognizer", local.application_context)
  custom_subdomain_name         = format("di-%s", local.application_context_cognitive_services)
  resource_group_name           = data.azurerm_resource_group.landing_zone.name
  location                      = data.azurerm_resource_group.landing_zone.location
  kind                          = "FormRecognizer"
  sku_name                      = "S0"
  dynamic_throttling_enabled    = false
  fqdns                         = []
  public_network_access_enabled = !var.enable_private_endpoints
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "form_recognizer" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = format("pep-%s-formrecognizer", local.application_context)
  location            = data.azurerm_resource_group.landing_zone.location
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  subnet_id           = azurerm_subnet.cywd[0].id
  tags                = var.tags

  private_service_connection {
    name                           = format("psc-%s-formrecognizer", local.application_context)
    private_connection_resource_id = azurerm_cognitive_account.form_recognizer.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
}

resource "azurerm_cognitive_deployment" "openai_gpt" {
  name                       = var.azure_openai_gpt_model.display_name
  cognitive_account_id       = azurerm_cognitive_account.openai.id
  dynamic_throttling_enabled = false
  rai_policy_name            = format("rai-%s", local.application_context_cognitive_services)

  model {
    format  = "OpenAI"
    name    = var.azure_openai_gpt_model.name
    version = var.azure_openai_gpt_model.version
  }

  sku {
    name     = "Standard"
    capacity = var.azure_openai_gpt_model.quota_token_per_minutes_in_thousand
  }

  depends_on = [
    azapi_resource.rai_policy
  ]
}

resource "azurerm_cognitive_deployment" "openai_embedding" {
  name                       = var.azure_openai_embedding_model.display_name
  cognitive_account_id       = azurerm_cognitive_account.openai.id
  dynamic_throttling_enabled = true
  rai_policy_name            = "Microsoft.DefaultV2"

  model {
    format  = "OpenAI"
    name    = var.azure_openai_embedding_model.name
    version = var.azure_openai_embedding_model.version
  }

  sku {
    name     = "Standard"
    capacity = var.azure_openai_embedding_model.quota_token_per_minutes_in_thousand
  }

  depends_on = [
    azapi_resource.rai_policy
  ]
}
