resource "azurerm_linux_web_app" "cwyd_consumer" {
  name                          = format("app-%s-cwyd", local.application_context)
  resource_group_name           = data.azurerm_resource_group.landing_zone.name
  location                      = data.azurerm_resource_group.landing_zone.location
  service_plan_id               = azurerm_service_plan.cwyd.id
  public_network_access_enabled = !var.enable_private_endpoints || var.enable_teams_app
  virtual_network_subnet_id     = var.enable_private_endpoints ? azurerm_subnet.cwyd_consumer[0].id : null
  tags                          = var.tags

  site_config {
    container_registry_use_managed_identity = true
    ip_restriction_default_action           = "Allow"
    scm_ip_restriction_default_action       = "Allow"
  }

  app_settings = {
    "DEBUG"                                        = false
    "WEBAPP_DEBUG"                                 = false
    "AUTH_ENABLED"                                 = false # Web App uses Microsoft Entra ID Auth
    "AZURE_AUTH_TYPE"                              = var.auth_type
    "AZURE_OPENAI_RESOURCE"                        = azurerm_cognitive_account.openai.name # before .id
    "AZURE_OPENAI_MODEL"                           = var.azure_openai_gpt_model.display_name
    "AZURE_OPENAI_KEY"                             = var.auth_type == "keys" ? azurerm_cognitive_account.openai.primary_access_key : null
    "AZURE_OPENAI_MODEL_NAME"                      = var.azure_openai_gpt_model.name
    "AZURE_OPENAI_TEMPERATURE"                     = var.azure_openai_temperature
    "AZURE_OPENAI_TOP_P"                           = var.azure_openai_top_p
    "AZURE_OPENAI_MAX_TOKENS"                      = var.azure_openai_max_tokens
    "AZURE_OPENAI_STOP_SEQUENCE"                   = var.azure_openai_stop_sequence
    "AZURE_OPENAI_SYSTEM_MESSAGE"                  = var.azure_openai_system_message
    "AZURE_OPENAI_PREVIEW_API_VERSION"             = var.azure_openai_api_version
    "AZURE_OPENAI_STREAM"                          = var.azure_openai_stream
    "AZURE_OPENAI_ENDPOINT"                        = azurerm_cognitive_account.openai.endpoint
    "AZURE_OPENAI_EMBEDDING_NAME"                  = var.azure_openai_embedding_model.name
    "AZURE_OPENAI_EMBEDDING_ENDPOINT"              = azurerm_cognitive_account.openai.endpoint
    "AZURE_OPENAI_EMBEDDING_KEY"                   = var.auth_type == "keys" ? azurerm_cognitive_account.openai.primary_access_key : null
    "UI_TITLE"                                     = var.ui_title
    "UI_LOGO"                                      = var.ui_logo
    "UI_CHAT_LOGO"                                 = var.ui_chat_logo
    "UI_CHAT_TITLE"                                = var.ui_chat_title
    "UI_CHAT_DESCRIPTION"                          = var.ui_chat_description
    "UI_FAVICON"                                   = var.ui_favicon
    "UI_SHOW_SHARE_BUTTON"                         = var.ui_show_share_button
    "AZURE_COSMOSDB_ACCOUNT"                       = azurerm_cosmosdb_account.cosmos.name
    "AZURE_COSMOSDB_DATABASE"                      = var.cosmos_database_name
    "AZURE_COSMOSDB_CONVERSATIONS_CONTAINER"       = var.cosmos_collection_name
    "AZURE_COSMOSDB_ACCOUNT_KEY"                   = azurerm_cosmosdb_account.cosmos.primary_key
    "AZURE_COSMOSDB_ENABLE_FEEDBACK"               = var.cosmos_enable_feedback
    "DATASOURCE_TYPE"                              = var.datasource_type
    "SCM_DO_BUILD_DURING_DEPLOYMENT"               = true
    "SEARCH_TOP_K"                                 = var.azure_search_top_k
    "SEARCH_STRICTNESS"                            = var.azure_search_strictness
    "SEARCH_ENABLE_IN_DOMAIN"                      = var.azure_search_enable_in_domain
    "AZURE_SEARCH_SERVICE"                         = azurerm_search_service.cwyd.name
    "AZURE_SEARCH_INDEX"                           = format("%s-index", local.application_context)
    "AZURE_SEARCH_KEY"                             = var.auth_type == "keys" ? azurerm_search_service.cwyd.primary_key : null
    "AZURE_SEARCH_SEMANTIC_SEARCH_CONFIG"          = var.azure_search_semantic_search_config
    "AZURE_SEARCH_USE_SEMANTIC_SEARCH"             = var.azure_search_use_semantic_search
    "AZURE_SEARCH_INDEX_IS_PRECHUNKED"             = var.azure_search_index_is_prechunked
    "AZURE_SEARCH_TOP_K"                           = var.azure_search_top_k
    "AZURE_SEARCH_ENABLE_IN_DOMAIN"                = var.azure_search_enable_in_domain
    "AZURE_SEARCH_CONTENT_COLUMNS"                 = var.azure_search_content_columns
    "AZURE_SEARCH_FILENAME_COLUMN"                 = var.azure_search_filename_column
    "AZURE_SEARCH_TITLE_COLUMN"                    = var.azure_search_title_column
    "AZURE_SEARCH_URL_COLUMN"                      = var.azure_search_url_column
    "AZURE_SEARCH_VECTOR_COLUMNS"                  = var.azure_search_vector_columns
    "AZURE_SEARCH_QUERY_TYPE"                      = var.azure_search_query_type
    "AZURE_SEARCH_PERMITTED_GROUPS_COLUMN"         = var.azure_search_permitted_groups_column
    "AZURE_SEARCH_STRICTNESS"                      = var.azure_search_strictness
    "AZURE_COSMOSDB_MONGO_VCORE_CONNECTION_STRING" = ""
    "AZURE_COSMOSDB_MONGO_VCORE_DATABASE"          = ""
    "AZURE_COSMOSDB_MONGO_VCORE_CONTAINER"         = ""
    "AZURE_COSMOSDB_MONGO_VCORE_INDEX"             = ""
    "AZURE_COSMOSDB_MONGO_VCORE_TOP_K"             = ""
    "AZURE_COSMOSDB_MONGO_VCORE_STRICTNESS"        = ""
    "AZURE_COSMOSDB_MONGO_VCORE_ENABLE_IN_DOMAIN"  = ""
    "AZURE_COSMOSDB_MONGO_VCORE_CONTENT_COLUMNS"   = ""
    "AZURE_COSMOSDB_MONGO_VCORE_FILENAME_COLUMN"   = ""
    "AZURE_COSMOSDB_MONGO_VCORE_TITLE_COLUMN"      = ""
    "AZURE_COSMOSDB_MONGO_VCORE_URL_COLUMN"        = ""
    "AZURE_COSMOSDB_MONGO_VCORE_VECTOR_COLUMNS"    = ""
    "ELASTICSEARCH_ENDPOINT"                       = ""
    "ELASTICSEARCH_ENCODED_API_KEY"                = ""
    "ELASTICSEARCH_INDEX"                          = ""
    "ELASTICSEARCH_QUERY_TYPE"                     = ""
    "ELASTICSEARCH_TOP_K"                          = ""
    "ELASTICSEARCH_ENABLE_IN_DOMAIN"               = ""
    "ELASTICSEARCH_CONTENT_COLUMNS"                = ""
    "ELASTICSEARCH_FILENAME_COLUMN"                = ""
    "ELASTICSEARCH_TITLE_COLUMN"                   = ""
    "ELASTICSEARCH_URL_COLUMN"                     = ""
    "ELASTICSEARCH_VECTOR_COLUMNS"                 = ""
    "ELASTICSEARCH_STRICTNESS"                     = ""
    "ELASTICSEARCH_EMBEDDING_MODEL_ID"             = ""
    "PINECONE_ENVIRONMENT"                         = ""
    "PINECONE_API_KEY"                             = ""
    "PINECONE_INDEX_NAME"                          = ""
    "PINECONE_TOP_K"                               = ""
    "PINECONE_STRICTNESS"                          = ""
    "PINECONE_ENABLE_IN_DOMAIN"                    = ""
    "PINECONE_CONTENT_COLUMNS"                     = ""
    "PINECONE_FILENAME_COLUMN"                     = ""
    "PINECONE_TITLE_COLUMN"                        = ""
    "PINECONE_URL_COLUMN"                          = ""
    "PINECONE_VECTOR_COLUMNS"                      = ""
    "AZURE_MLINDEX_NAME"                           = ""
    "AZURE_MLINDEX_VERSION"                        = ""
    "AZURE_ML_PROJECT_RESOURCE_ID"                 = ""
    "AZURE_MLINDEX_TOP_K"                          = ""
    "AZURE_MLINDEX_STRICTNESS"                     = ""
    "AZURE_MLINDEX_ENABLE_IN_DOMAIN"               = ""
    "AZURE_MLINDEX_CONTENT_COLUMNS"                = ""
    "AZURE_MLINDEX_FILENAME_COLUMN"                = ""
    "AZURE_MLINDEX_TITLE_COLUMN"                   = ""
    "AZURE_MLINDEX_URL_COLUMN"                     = ""
    "AZURE_MLINDEX_VECTOR_COLUMNS"                 = ""
    "AZURE_MLINDEX_QUERY_TYPE"                     = ""
    "USE_PROMPTFLOW"                               = false
    "PROMPTFLOW_ENDPOINT"                          = ""
    "PROMPTFLOW_API_KEY"                           = ""
    "PROMPTFLOW_RESPONSE_TIMEOUT"                  = "120"
    "PROMPTFLOW_REQUEST_FIELD_NAME"                = "question"
    "PROMPTFLOW_RESPONSE_FIELD_NAME"               = "answer"
    "APPINSIGHTS_CONNECTION_STRING"                = azurerm_application_insights.cwyd.connection_string
    "AZURE_BLOB_ACCOUNT_NAME"                      = azurerm_storage_account.cwyd.name
    "AZURE_BLOB_ACCOUNT_KEY"                       = azurerm_storage_account.cwyd.primary_access_key
    "AZURE_BLOB_CONTAINER_NAME"                    = local.blob_container_name
    "AZURE_FORM_RECOGNIZER_ENDPOINT"               = "" # azurerm_cognitive_account.form_recognizer.endpoint
    "AZURE_FORM_RECOGNIZER_KEY"                    = "" # azurerm_cognitive_account.form_recognizer.primary_access_key
    "WEBSITE_AUTH_AAD_ALLOWED_TENANTS"             = data.azurerm_client_config.current.tenant_id
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE"              = true
    "WEBSITE_RUN_FROM_PACKAGE"                     = "1"
  }

  identity {
    type = "SystemAssigned"
  }

  auth_settings_v2 {
    auth_enabled             = true
    default_provider         = "azureactivedirectory"
    excluded_paths           = []
    forward_proxy_convention = "NoProxy"
    http_route_api_prefix    = "/.auth"
    require_authentication   = true
    require_https            = true
    runtime_version          = "~1"
    unauthenticated_action   = "RedirectToLoginPage"

    active_directory_v2 {
      allowed_applications = []
      allowed_audiences = [
        format("api://%s",
          var.app_reg_consumer_client_id
        ),
      ]
      allowed_groups                  = []
      allowed_identities              = []
      client_id                       = var.app_reg_consumer_client_id
      client_secret_setting_name      = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
      jwt_allowed_client_applications = []
      jwt_allowed_groups              = []
      login_parameters                = {}
      tenant_auth_endpoint = format("https://sts.windows.net/%s/v2.0",
        data.azurerm_client_config.current.tenant_id
      )
      www_authentication_disabled = false
    }

    login {
      allowed_external_redirect_urls    = []
      cookie_expiration_convention      = "FixedTime"
      cookie_expiration_time            = "08:00:00"
      logout_endpoint                   = "/.auth/logout"
      nonce_expiration_time             = "00:05:00"
      preserve_url_fragments_for_logins = false
      token_refresh_extension_time      = 72
      token_store_enabled               = true
      validate_nonce                    = true
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings["AZURE_OPENAI_STOP_SEQUENCE"],
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"]
    ]
  }
}

resource "azurerm_private_endpoint" "webapp" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = format("pep-%s-webapp", local.application_context)
  location            = data.azurerm_resource_group.landing_zone.location
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  subnet_id           = azurerm_subnet.cywd[0].id
  tags                = var.tags

  private_service_connection {
    name                           = format("psc-%s-webapp", local.application_context)
    private_connection_resource_id = azurerm_linux_web_app.cwyd_consumer.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
}

resource "azurerm_role_assignment" "cwyd_consumer_cognitive_services_openai_user" {
  count = var.auth_type == "rbac" ? 1 : 0

  scope                = data.azurerm_resource_group.landing_zone.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_linux_web_app.cwyd_consumer.identity[0].principal_id
}

resource "azurerm_role_assignment" "cwyd_consumer_search_index_data_reader" {
  count = var.auth_type == "rbac" ? 1 : 0

  scope                = data.azurerm_resource_group.landing_zone.id
  role_definition_name = "Search Index Data Reader"
  principal_id         = azurerm_linux_web_app.cwyd_consumer.identity[0].principal_id
}

resource "azurerm_role_assignment" "cwyd_consumer_storage_blob_data_reader" {
  count = var.auth_type == "rbac" ? 1 : 0

  scope                = data.azurerm_resource_group.landing_zone.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_linux_web_app.cwyd_consumer.identity[0].principal_id
}

data "azurerm_cosmosdb_sql_role_definition" "cwyd_consumer_cosmos_db_builtin_data_contributor" {
  count = var.auth_type == "rbac" ? 1 : 0

  resource_group_name = data.azurerm_resource_group.landing_zone.name
  account_name        = format("cosmos-%s", local.application_context)
  role_definition_id  = "00000000-0000-0000-0000-000000000002"
}

resource "azurerm_cosmosdb_sql_role_assignment" "cwyd_consumer_cosmos_db_builtin_data_contributor" {
  count = var.auth_type == "rbac" ? 1 : 0

  resource_group_name = data.azurerm_resource_group.landing_zone.name
  account_name        = format("cosmos-%s", local.application_context)
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.cwyd_consumer_cosmos_db_builtin_data_contributor[0].id
  principal_id        = azurerm_linux_web_app.cwyd_consumer.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.cosmos.id
}

resource "azurerm_role_assignment" "cwyd_consumer_search_index_data_contributor" {
  count = var.auth_type == "rbac" ? 1 : 0

  scope                = azurerm_search_service.cwyd.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_linux_web_app.cwyd_consumer.identity[0].principal_id

  depends_on = [azurerm_linux_web_app.cwyd_consumer]
}

resource "azurerm_role_assignment" "cwyd_consumer_arc_pull" {
  scope                = var.is_acr_required ? azurerm_container_registry.cwyd[0].id : data.azurerm_container_registry.cwyd[0].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.cwyd_consumer.identity[0].principal_id

  depends_on = [azurerm_linux_web_app.cwyd_consumer]
}

resource "azurerm_dns_txt_record" "cwyd_consumer_domain_verification" {
  count = var.enable_custom_domain ? 1 : 0

  name                = lower(format("asuid.%s", var.chatbot_url_prefix))
  zone_name           = data.azurerm_dns_zone.subdomain[0].name
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  ttl                 = 300
  tags                = var.tags

  record {
    value = azurerm_linux_web_app.cwyd_consumer.custom_domain_verification_id
  }
}

resource "azurerm_dns_cname_record" "cwyd_consumer_cname_record" {
  count = var.enable_custom_domain ? 1 : 0

  name                = lower(format("%s", var.chatbot_url_prefix))
  zone_name           = data.azurerm_dns_zone.subdomain[0].name
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  ttl                 = 300
  record              = azurerm_linux_web_app.cwyd_consumer.default_hostname
  tags                = var.tags
}

resource "time_sleep" "wait" {
  count = var.enable_custom_domain ? 1 : 0

  depends_on      = [azurerm_dns_txt_record.cwyd_consumer_domain_verification, azurerm_dns_cname_record.cwyd_consumer_cname_record]
  create_duration = "30s"
}

resource "azurerm_app_service_custom_hostname_binding" "cwyd_consumer" {
  count = var.enable_custom_domain ? 1 : 0

  hostname = lower(format("%s.%s.azure.%s",
    var.chatbot_url_prefix,
    local.subdomain,
    var.base_dns_company_domain
  ))
  app_service_name    = azurerm_linux_web_app.cwyd_consumer.name
  resource_group_name = data.azurerm_resource_group.landing_zone.name

  depends_on = [time_sleep.wait]
}

resource "azurerm_app_service_managed_certificate" "cwyd_consumer" {
  count = var.enable_custom_domain ? 1 : 0

  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.cwyd_consumer[0].id
  tags                       = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_app_service_certificate_binding" "cwyd_consumer" {
  count = var.enable_custom_domain ? 1 : 0

  hostname_binding_id = azurerm_app_service_custom_hostname_binding.cwyd_consumer[0].id
  certificate_id      = azurerm_app_service_managed_certificate.cwyd_consumer[0].id
  ssl_state           = "SniEnabled"
}
