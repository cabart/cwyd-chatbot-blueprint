module "cwyd_core" {
  source = "../../core"

  application_name                 = "mycwyd"
  location_alias                   = "chn"
  stage_alias                      = "dev"
  parent_index                     = ""
  tags                             = local.tags
  landing_zone_resource_group_name = "rgr-mycwyd-chn-dev"

  #   DNS settings
  enable_custom_domain    = false
  base_dns_company_domain = ""
  #   enable_custom_domain    = true
  #   base_dns_company_domain = "chatwithme.ch"

  # Network settings
  enable_private_endpoints          = false
  openai_private_dns_zone_id        = ""
  subnet_private_address_prefixes   = []
  subnet_delegated_address_prefixes = []
  #   enable_private_endpoints              = true
  #   resource_group_name_private_dns_zones = "rgr-dnszones-chn-prod"
  #   subnet_private_address_prefixes       = ["10.0.0.0/28"]
  #   subnet_delegated_address_prefixes     = ["10.0.0.16/28"]

  # Azure Container Registry settings
  is_acr_required = true
  acr_name        = ""

  # Blueprint settings
  app_reg_consumer_client_id        = "" # Add client_id of app-ldc-mycwyd-chn-dev-authconsumer
  auth_type                         = "keys"
  chatbot_url_prefix                = "chat"
  cognitive_services_location       = "Switzerland North"
  cognitive_services_location_alias = "chn"
  service_plan_sku                  = "B3"
  datasource_type                   = "AzureCognitiveSearch"
  azure_cognitive_search_sku        = "standard"

  # Teams App settings
  enable_teams_app        = false
  app_reg_teams_client_id = ""
  service_plan_sku_teams  = ""
  azure_bot_sku_teams     = ""
  #   enable_teams_app        = true
  #   app_reg_teams_client_id = "" # Add client_id of app-ldc-mycwyd-chn-dev-teamsapp
  #   service_plan_sku_teams  = "B1"
  #   azure_bot_sku_teams     = "F0"

  # Cognivitive Services settings
  azure_openai_gpt_model = {
    display_name                        = "gpt-35-turbo-16k"
    name                                = "gpt-35-turbo-16k"
    version                             = "0613"
    quota_token_per_minutes_in_thousand = 100
    sku_type                            = "Standard"
  }
  azure_openai_temperature    = 0
  azure_openai_top_p          = 1
  azure_openai_max_tokens     = 4000
  azure_openai_stop_sequence  = "\n"
  azure_openai_system_message = "You are an AI assistant that helps people find information."
  azure_openai_api_version    = "2024-02-15-preview"
  azure_openai_stream         = true
  azure_openai_embedding_model = {
    display_name                        = "text-embedding-ada-002"
    name                                = "text-embedding-ada-002"
    version                             = "2"
    quota_token_per_minutes_in_thousand = 100
    sku_type                            = "Standard"
  }

  # Azure Search settings
  azure_search_use_semantic_search     = true
  azure_search_semantic_search_config  = "default"
  azure_search_index_is_prechunked     = false
  azure_search_top_k                   = 12
  azure_search_enable_in_domain        = true
  azure_search_content_columns         = "content"
  azure_search_filename_column         = "filepath"
  azure_search_title_column            = "title"
  azure_search_url_column              = "filepath"
  azure_search_strictness              = 3
  azure_search_vector_columns          = "contentVector"
  azure_search_query_type              = "vectorSimpleHybrid"
  azure_search_permitted_groups_column = ""

  # UI Configuration
  ui_title             = "Generative AI Bot"
  ui_logo              = ""
  ui_chat_logo         = ""
  ui_chat_title        = "How can I help today?"
  ui_chat_description  = "This chatbot is configured to answer your questions"
  ui_favicon           = "/favicon.ico"
  ui_show_share_button = false

  # Cosmos DB
  cosmos_database_name   = "db_conversation_history"
  cosmos_collection_name = "conversations"
  cosmos_enable_feedback = true
}
