# Project settings

variable "application_name" {
  type        = string
  description = "Defines an alphanumeric name for the application with a minimum length of 2 and a maximum length of 7. This value, in combination with location_alias, stage_alias, and parent_index, must be globally unique."
  validation {
    condition     = length(var.application_name) > 1 && length(var.application_name) < 8
    error_message = "Application name must be between 2 and 7 characters"
  }
}

variable "location_alias" {
  type        = string
  description = "Defines the three-letter alias for an Azure location. Supported values are chn for Switzerland North, chw for Switzerland West, eun for North Europe, euw for West Europe, usw for West US, usw2 for West US 2, usc for Central US, use for East US, use2 for East US 2, usn for North Central US, frc for France Central, frs for France South, sdc for Sweden Central, and spc for Spain Central."
}

variable "stage_alias" {
  type        = string
  description = "Defines the alias for the application stage. Supported values are dev, test, int, qa, prod, nonprod, sbox, and mbt."
}

variable "parent_index" {
  type        = string
  description = "Defines the index used to make the application name unique during deployments of multiple versions. This will be part of the application name."
}

variable "tags" {
  type        = map(string)
  description = "Defines a list of resource tags applied to every Azure service."
}

variable "landing_zone_resource_group_name" {
  type        = string
  description = "Defines the name of the Landing Zone resource group."
}

# DNS settings

variable "enable_custom_domain" {
  type        = bool
  description = "Defines whether a subdomain DNS zone is created and custom domains are configured."
  default     = true
}

variable "base_dns_company_domain" {
  type        = string
  description = "Defines the company name used to look up the base DNS zone. This variable is required when enable_custom_domain is enabled."
  default     = ""
}

# Networking settings

variable "enable_private_endpoints" {
  type        = bool
  description = "Defines whether the services are network-integrated via private endpoints."
  default     = false
}

variable "openai_private_dns_zone_id" {
  type        = string
  description = "Defines the ID of the OpenAI private DNS zone for private endpoint records. This must be configured when private endpoints are enabled."
  default     = ""
}

variable "subnet_private_address_prefixes" {
  type        = list(string)
  description = "Defines the address prefixes of the subnet used for private endpoints."
  default     = []
}

variable "subnet_delegated_address_prefixes" {
  type        = list(string)
  description = "Defines the address prefixes of the subnet used for web app VNet integration."
  default     = []
}

# Azure Container Registry settings

variable "is_acr_required" {
  type        = bool
  description = "Defines whether a new Azure Container Registry is created."
  default     = false
}

variable "acr_name" {
  type        = string
  description = "Defines the name of an existing Azure Container Registry and implies its usage instead of creating a new one."
  default     = ""
}

# Blueprint settings

variable "app_reg_consumer_client_id" {
  type        = string
  description = "Defines the client ID of the consumer app registration for the consumer web app. This is used for authentication via Entra ID."
}

variable "auth_type" {
  type        = string
  description = "Defines the authorization type: rbac or keys."
  default     = "keys"
  validation {
    condition     = (var.auth_type == "keys") || (var.auth_type == "rbac")
    error_message = "Auth_type must be 'keys' or 'rbac'."
  }
}

variable "chatbot_url_prefix" {
  type        = string
  description = "Defines the URL prefix for the chatbot."
  default     = "chat"
}

variable "cognitive_services_location" {
  type        = string
  description = "Defines the Azure location name for cognitive services."
}

variable "cognitive_services_location_alias" {
  type        = string
  description = "Defines the three-letter alias for an Azure location. Supported values are chn for Switzerland North, chw for Switzerland West, eun for North Europe, euw for West Europe, usw for West US, usw2 for West US 2, usc for Central US, use for East US, use2 for East US 2, usn for North Central US, frc for France Central, frs for France South, sdc for Sweden Central, and spc for Spain Central."
}

variable "service_plan_sku" {
  type        = string
  description = "Defines the app service plan SKU."
  default     = "B3"
}

variable "datasource_type" {
  type        = string
  description = "Defines the data source for the chatbot."
  default     = "AzureCognitiveSearch"
}

variable "azure_cognitive_search_sku" {
  type        = string
  description = "Defines the search service SKU."
  default     = "standard"
  validation {
    condition = (
      var.azure_cognitive_search_sku == "free" ||
      var.azure_cognitive_search_sku == "basic" ||
      var.azure_cognitive_search_sku == "standard" ||
      var.azure_cognitive_search_sku == "standard2" ||
      var.azure_cognitive_search_sku == "standard3"
    )
    error_message = "Azure_cognitive_search_sku must be one of free, basic, standard, standard2, standard3."
  }
}

# Teams App settings

variable "enable_teams_app" {
  description = "Defines whether Teams integration should be deployed."
  type        = bool
  default     = false
}

variable "app_reg_teams_client_id" {
  type        = string
  description = "Defines the client ID of the Teams app registration. This is used for authentication via Entra ID."
}

variable "service_plan_sku_teams" {
  type        = string
  description = "Defines the pricing tier for the App Service plan for Teams."
  default     = "B1"
}

variable "azure_bot_sku_teams" {
  type        = string
  description = "Defines the pricing tier for Azure Bot for Teams."
  default     = "F0"
}

variable "azure_bot_teams_tenant" {
  type        = string
  description = "Defines the tenant ID for Teams app service configuration. If not set, the current tenant ID is used."
  default     = ""
}

# Cognivitive Services settings

variable "azure_openai_gpt_model" {
  type = object({
    display_name                        = string
    name                                = string
    version                             = string
    quota_token_per_minutes_in_thousand = number
    sku_type                            = string
  })
  description = "Defines the Azure OpenAI GPT Model display name, deployment name, and version."
  default = {
    display_name                        = "gpt-35-turbo-16k"
    name                                = "gpt-35-turbo-16k"
    version                             = "0613"
    quota_token_per_minutes_in_thousand = 1
    sku_type                            = "Standard"
  }
  validation {
    condition     = (var.azure_openai_gpt_model.display_name != "")
    error_message = "Azure OpenAI GPT Model display name must be set."
  }
}

variable "azure_openai_temperature" {
  type        = number
  description = "Defines the Azure OpenAI temperature."
  default     = 0
}

variable "azure_openai_top_p" {
  type        = number
  description = "Defines the Azure OpenAI Top P."
  default     = 1
}

variable "azure_openai_max_tokens" {
  type        = number
  description = "Defines the maximum number of tokens used by Azure OpenAI."
  default     = 4000
}

variable "azure_openai_stop_sequence" {
  type        = string
  description = "Defines the stop sequence for Azure OpenAI."
  default     = "\n"
}

variable "azure_openai_system_message" {
  type        = string
  description = "Defines the Azure OpenAI system message."
  default     = "You are an AI assistant that helps people find information."
}

variable "azure_openai_api_version" {
  type        = string
  description = "Defines the Azure OpenAI API version."
  default     = "2024-02-15-preview"
}

variable "azure_openai_stream" {
  type        = bool
  description = "Defines whether the Azure AI responses are streamed."
  default     = true
}

variable "azure_openai_embedding_model" {
  type = object({
    display_name                        = string
    name                                = string
    version                             = string
    quota_token_per_minutes_in_thousand = number
    sku_type                            = string
  })
  description = "Defines the Azure OpenAI Embedding Model display name, deployment name, and version."
  default = {
    display_name                        = "text-embedding-ada-002"
    name                                = "text-embedding-ada-002"
    version                             = "2"
    quota_token_per_minutes_in_thousand = 1
    sku_type                            = "Standard"
  }
  validation {
    condition     = (var.azure_openai_embedding_model.display_name != "")
    error_message = "Azure OpenAI Embedding Model display name must be set."
  }
}

# Azure Search settings

variable "azure_search_use_semantic_search" {
  type        = bool
  description = "Defines whether semantic search is used."
  default     = true
}

variable "azure_search_semantic_search_config" {
  type        = string
  description = "Defines the semantic search configuration."
  default     = "default"
}

variable "azure_search_index_is_prechunked" {
  type        = bool
  description = "Defines whether the index is pre-chunked."
  default     = false
}

variable "azure_search_top_k" {
  type        = number
  description = "Defines the value of the Top K results."
  default     = 12
}

variable "azure_search_enable_in_domain" {
  type        = bool
  description = "Defines whether the domain is enabled."
  default     = true
}

variable "azure_search_content_columns" {
  type        = string
  description = "Defines the name of the content columns."
  default     = "content"
}

variable "azure_search_filename_column" {
  type        = string
  description = "Defines the name of the filename column."
  default     = "filepath"
}

variable "azure_search_title_column" {
  type        = string
  description = "Defines the name of the title column."
  default     = "title"
}

variable "azure_search_url_column" {
  type        = string
  description = "Defines the name of the URL column."
  default     = "filepath"
}

variable "azure_search_strictness" {
  type        = number
  description = "Defines the strictness level for Azure search."
  default     = 3
}

variable "azure_search_vector_columns" {
  type        = string
  description = "Defines the name of the vector columns."
  default     = "contentVector"
}

variable "azure_search_query_type" {
  type        = string
  description = "Defines the query type."
  default     = "vectorSimpleHybrid"
}

variable "azure_search_permitted_groups_column" {
  type        = string
  description = "Defines the name of the permitted groups column."
  default     = ""
}

# UI settings

variable "ui_title" {
  type        = string
  description = "Defines the UI title for the Generative AI Bot."
  default     = "Generative AI Bot"

}

variable "ui_logo" {
  type        = string
  description = "Defines the path for the UI logo."
  default     = ""
}

variable "ui_chat_logo" {
  type        = string
  description = "Defines the path for the UI chat logo in the main chat window."
  default     = ""
}

variable "ui_chat_title" {
  type        = string
  description = "Defines the UI chat title in the main chat window."
  default     = "How can I help today?"
}

variable "ui_chat_description" {
  type        = string
  description = "Defines the UI chat description in the main chat window."
  default     = "This chatbot is configured to answer your questions"
}

variable "ui_favicon" {
  type        = string
  description = "Defines the path for the UI browser icon."
  default     = "/favicon.ico"
}

variable "ui_show_share_button" {
  type        = bool
  description = "Defines whether the share button in the top right corner is displayed."
  default     = true
}

# Cosmos DB settings

variable "cosmos_database_name" {
  type        = string
  description = "Defines the name of the database."
  default     = "db_conversation_history"
}

variable "cosmos_collection_name" {
  type        = string
  description = "Defines the name of the collection."
  default     = "conversations"
}

variable "cosmos_enable_feedback" {
  type        = bool
  description = "Defines whether feedback in Cosmos DB is enabled."
  default     = true
}
