# Write these values to key vault so we can easily consume them from Python code to ingest data

resource "azurerm_key_vault_secret" "ingest_params" {
  for_each = {
    "ingest-location"                     = data.azurerm_resource_group.landing_zone.location
    "ingest-subscription-id"              = data.azurerm_client_config.current.subscription_id
    "ingest-resource-group"               = data.azurerm_resource_group.landing_zone.name
    "ingest-chunk-size"                   = "1024"
    "ingest-token-overlap"                = "128"
    "ingest-language"                     = "en"
    "ingest-vector-config-name"           = "default"
    "azure-tenant-id"                     = data.azurerm_client_config.current.tenant_id
    "azure-openai-resource"               = azurerm_cognitive_account.openai.name
    "azure-openai-model"                  = var.azure_openai_gpt_model.display_name
    "azure-openai-key"                    = azurerm_cognitive_account.openai.primary_access_key # var.auth_type == "keys" ? azurerm_cognitive_account.openai.primary_access_key : null
    "azure-openai-model-name"             = var.azure_openai_gpt_model.name
    "azure-openai-endpoint"               = azurerm_cognitive_account.openai.endpoint
    "azure-openai-embedding-name"         = var.azure_openai_embedding_model.name
    "azure-openai-embedding-endpoint"     = azurerm_cognitive_account.openai.endpoint
    "azure-openai-embedding-key"          = azurerm_cognitive_account.openai.primary_access_key # var.auth_type == "keys" ? azurerm_cognitive_account.openai.primary_access_key : null
    "azure-search-service"                = azurerm_search_service.cwyd.name
    "azure-search-index"                  = format("%s-index", local.application_context)
    "azure-search-key"                    = azurerm_search_service.cwyd.primary_key # var.auth_type == "keys" ? azurerm_search_service.cwyd.primary_key : null
    "azure-search-semantic-search-config" = var.azure_search_semantic_search_config
    "azure-blob-account-name"             = azurerm_storage_account.cwyd.name
    "azure-blob-account-key"              = azurerm_storage_account.cwyd.primary_access_key
    "azure-blob-container-name"           = local.blob_container_name
    "azure-form-recognizer-endpoint"      = azurerm_cognitive_account.form_recognizer.endpoint
    "azure-form-recognizer-key"           = azurerm_cognitive_account.form_recognizer.primary_access_key
  }

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.cwyd.id
}