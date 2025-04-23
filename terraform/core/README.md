# Core Module

The *core* module requires the *prereq* module to be deployed in advance. For more information about the *prereq* module, refer to the [*prereq* README](../prereq/README.md).

## Requirements

The *core* module has specific requirements regarding permissions and Azure services.

### Permissions

To deploy the required Azure resources and the *prereq* module, the following permissions are required:

| Permission | Scope | Description |
| - | - | - |
| Contributor | Landing Zone | Required to deploy the *core* module within the Landing Zone resource group. See [Azure RBAC built-in role definition](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/privileged#contributor). |
| Key Vault Administrator | Landing Zone | Required to store secrets in Azure Key Vault. See [Azure RBAC built-in role definition](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/security#key-vault-administrator). |

### Azure Services

All Azure services documented and defined in the *prereq* module must be deployed in advance.

## Features

The blueprint provides two additional features that can be enabled via the Terraform variables `enable_private_endpoints` and `enable_custom_domain`.

### Private Networking

Private networking requires the network infrastructure from the *prereq* module and DNS integration to handle private endpoint DNS records. When this feature is enabled, all [1] Azure services using private endpoints will have public endpoints disabled.

[1] Azure Application Insights and Azure Bot require additional services and firewall rules provided by the CCoE. Therefore, these two Azure services do not support private networking in this implementation.

### Custom Domain

The custom domain feature allows meaningful domain names to be used for App Services. This feature requires DNS integration to handle DNS resolution.

## Deployment

After obtaining the required permissions and preparing the Landing Zone resource group through the deployment of the *prereq* module, the next step is configuring the *core* module.

### Extending the Parent Module

The *core* module is a child module. In this guide, it extends the *prereq* parent module. An example is provided [here](../example/mycwyd/core.tf).

The Terraform examples use a local Terraform state file configuration.

### Module Configuration

The default configuration does not support virtual network integration, custom domains, or Microsoft 365 Teams integration. For documentation purposes, variables with default values equal to example values are also defined in the Terraform example. To check default values, refer to [variables.tf](./variables.tf).

| Variable | Description | Example Value |
| - | - | - | 
| application_name | Defines an alphanumeric name for the application with a minimum length of 2 and a maximum length of 7. This value, in combination with `location_alias`, `stage_alias`, and `parent_index`, must be globally unique. | `mycwyd` |
| location_alias | Defines the three-letter alias for an Azure location. Supported values are *chn* for Switzerland North, *chw* for Switzerland West, *eun* for North Europe, *euw* for West Europe, *usw* for West US, *usw2* for West US 2, *usc* for Central US, *use* for East US, *use2* for East US 2, *usn* for North Central US, *frc* for France Central, *frs* for France South, *sdc* for Sweden Central, and *spc* for Spain Central. | `chn` |
| stage_alias | Defines the alias for the application stage. Supported values are *dev*, *test*, *int*, *qa*, *prod*, *nonprod*, *sbox*, and *mbt*. | `dev` |
| parent_index | Defines the index used to make the application name unique during deployments of multiple versions. This will be part of the application name. | `""` |
| tags | Defines a list of resource tags applied to every Azure service. | `{}` |
| landing_zone_resource_group_name | Defines the name of the Landing Zone resource group. | `rgr-mycwyd-chn-dev` |
| enable_custom_domain | Defines whether a subdomain DNS zone is created and custom domains are configured. | `false` |
| base_dns_company_domain | Defines the company name used to look up the base DNS zone. This variable is required when `enable_custom_domain` is enabled. | `""` |
| enable_private_endpoints | Defines whether the services are network-integrated via private endpoints. | `false` |
| openai_private_dns_zone_id | Defines the ID of the OpenAI private DNS zone for private endpoint records. This must be configured when private endpoints are enabled. | `""` |
| subnet_private_address_prefixes | Defines the address prefixes of the subnet used for private endpoints. | `[]` |
| subnet_delegated_address_prefixes | Defines the address prefixes of the subnet used for web app VNet integration. | `[]` |
| is_acr_required | Defines whether a new Azure Container Registry is created. | `true` |
| acr_name | Defines the name of an existing Azure Container Registry and implies its usage instead of creating a new one. | `""` |
| app_reg_consumer_client_id | Defines the client ID of the consumer app registration for the consumer web app. This is used for authentication via Entra ID. | (UUID created by *prereq* module deployment) |
| auth_type | Defines the authorization type: `rbac` or `keys`. | `keys` |
| chatbot_url_prefix | Defines the URL prefix for the chatbot. | `chat` |
| cognitive_services_location | Defines the Azure location name for cognitive services. | `Switzerland North` |
| cognitive_services_location_alias | Defines the three-letter alias for an Azure location. Supported values are *chn* for Switzerland North, *chw* for Switzerland West, *eun* for North Europe, *euw* for West Europe, *usw* for West US, *usw2* for West US 2, *usc* for Central US, *use* for East US, *use2* for East US 2, *usn* for North Central US, *frc* for France Central, *frs* for France South, *sdc* for Sweden Central, and *spc* for Spain Central. | `chn` |
| service_plan_sku | Defines the app service plan SKU. | `B3` |
| datasource_type | Defines the data source for the chatbot. | `AzureCognitiveSearch` |
| azure_cognitive_search_sku | Defines the search service SKU. | `standard` |
| enable_teams_app | Defines whether Teams integration should be deployed. | `false` |
| app_reg_teams_client_id | Defines the client ID of the Teams app registration. This is used for authentication via Entra ID. | `""` |
| service_plan_sku_teams | Defines the pricing tier for the App Service plan for Teams. | `""` |
| azure_bot_sku_teams | Defines the pricing tier for Azure Bot for Teams. | `""` |
| azure_bot_teams_tenant | Defines the tenant ID for Teams app service configuration. If not set, the current tenant ID is used. | `""` |
| azure_openai_gpt_model | Defines the Azure OpenAI GPT Model display name, deployment name, and version. | (See [variable.tf](./variables.tf)) |
| azure_openai_temperature | Defines the Azure OpenAI temperature. | `0` |
| azure_openai_top_p | Defines the Azure OpenAI Top P. | `1` |
| azure_openai_max_tokens | Defines the maximum number of tokens used by Azure OpenAI. | `4000` |
| azure_openai_stop_sequence | Defines the stop sequence for Azure OpenAI. | `\n` |
| azure_openai_system_message | Defines the Azure OpenAI system message. | `You are an AI assistant that helps people find information.` |
| azure_openai_api_version | Defines the Azure OpenAI API version. | `2024-02-15-preview` |
| azure_openai_stream | Defines whether the Azure AI responses are streamed. | `true` |
| azure_openai_embedding_model | Defines the Azure OpenAI Embedding Model display name, deployment name, and version. | (See [variable.tf](./variables.tf)) |
| azure_search_use_semantic_search | Defines whether semantic search is used. | `true` |
| azure_search_semantic_search_config | Defines the semantic search configuration. | `default` |
| azure_search_index_is_prechunked | Defines whether the index is pre-chunked. | `false` |
| azure_search_top_k | Defines the value of the Top K results. | `12` |
| azure_search_enable_in_domain | Defines whether the domain is enabled. | `true` |
| azure_search_content_columns | Defines the name of the content columns. | `content` |
| azure_search_filename_column | Defines the name of the filename column. | `filepath` |
| azure_search_title_column | Defines the name of the title column. | `title` |
| azure_search_url_column | Defines the name of the URL column. | `filepath` |
| azure_search_strictness | Defines the strictness level for Azure search. | `3` |
| azure_search_vector_columns | Defines the name of the vector columns. | `contentVector` |
| azure_search_query_type | Defines the query type. | `vectorSimpleHybrid` |
| azure_search_permitted_groups_column | Defines the name of the permitted groups column. | `""` |
| ui_title | Defines the UI title for the Generative AI Bot. | `Generative AI Bot` |
| ui_logo | Defines the path for the UI logo. | `""` |
| ui_chat_logo | Defines the path for the UI chat logo in the main chat window. | `""` |
| ui_chat_title | Defines the UI chat title in the main chat window. | `How can I help today?` |
| ui_chat_description | Defines the UI chat description in the main chat window. | `This chatbot is configured to answer your questions.` |
| ui_favicon | Defines the path for the UI browser icon. | `/favicon.ico` |
| ui_show_share_button | Defines whether the share button in the top right corner is displayed. | `true` |
| cosmos_database_name | Defines the name of the database. | `db_conversation_history` |
| cosmos_collection_name | Defines the name of the collection. | `conversations` |
| cosmos_enable_feedback | Defines whether feedback in Cosmos DB is enabled. | `true` |

**Terraform example (example/mycwyd/core.tf)**
```bash
module "cwyd_core" {
  source = "../../core"

  application_name                 = "mycwyd"
  location_alias                   = "chn"
  stage_alias                      = "dev"
  parent_index                     = ""
  tags                             = local.tags
  landing_zone_resource_group_name = "rgr-mycwyd-chn-dev"

  # DNS settings
  enable_custom_domain    = false
  base_dns_company_domain = ""

  # Network settings
  enable_private_endpoints              = false
  resource_group_name_private_dns_zones = ""
  subnet_private_address_prefixes       = []
  subnet_delegated_address_prefixes     = []

  # Azure ARC settings
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
  azure_cognitive_search_sku        = "standard2"

  # Teams App settings
  enable_teams_app        = false
  app_reg_teams_client_id = ""
  service_plan_sku_teams  = ""
  azure_bot_sku_teams     = ""

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
```

**Terraform example (example/mycwyd/output.tf)**
```bash
(...)

# Core

output "core_acr_name" {
  value = module.cwyd_core.acr_name
}

output "core_acr_resource_group_name" {
  value = module.cwyd_core.acr_resource_group_name
}
```

### Terraform Deployment

Before deploying the *core* module, ensure that at least the Landing Zone resource group and *prereq* module are deployed. Verify that the deployment user has the required permissions mentioned above.

As mentioned, the examples use a local Terraform state file configuration. Ensure that the required Terraform version in [main.tf](../example/mycwyd/main.tf) is installed.

To deploy, open a terminal and navigate to the folder where the parent module is created. Start by initializing Terraform:
```bash
terraform init
```

Log in to the Azure tenant where the blueprint will be deployed:
```bash
az login
```

Create a plan to validate the resources created by Terraform:
```bash
terraform plan
```

If the Terraform plan looks correct, proceed with the deployment. Don’t forget to approve the plan:
```bash
terraform apply
```

### Manual Steps

#### OAuth Connection Settings

After deploying the Azure Bot service via Terraform, the OAuth connection settings must be configured manually.

1. Open the [Azure Portal](https://portal.azure.com) and navigate to **Entra ID**.
2. Search for the service principal `app-ldc-mycwyd-chn-dev-teamsapp` and note the *Application (client) ID* from the *Overview*.
3. Note the *Application ID URI*: `api://bot-id-[client_id]`.
4. Go to **Manage** → **Expose an API** and note the *scope*: `api://bot-id-[client_id]/access_as_user`.
5. [Create a secret](https://learn.microsoft.com/en-us/purview/create-service-principal-azure#adding-a-secret-to-the-client-credentials) and save the secret value.
6. Navigate to the Landing Zone resource group `rgr-mycwyd-chn-dev` and select the Azure Bot service `bot-mycwyd-chn-dev-teams`.
7. Select **Settings** → **Configuration** and click on **Add OAuth Connection Settings**.
8. Enter the following values:
   - **Name**: `OAuthSettings`
   - **Service Provider**: `Azure Active Directory v2`
   - **Client ID**: (from step 2)
   - **Client Secret**: (from step 5)
   - **Application ID URI**: (from step 3)
   - **Tenant ID**: `Common`
   - **Scopes**: `User.Read api://bot-id-[client_id]/access_as_user`
9. Save the configuration.

![OAuth Settings](https://raw.githubusercontent.com/OfficeDev/Microsoft-Teams-Samples/main/samples/bot-conversation-sso-quickstart/js/sso_media/AzureBotConnectionString.png)

(Source: [Microsoft-Teams-Samples - Step 3](https://github.com/OfficeDev/Microsoft-Teams-Samples/blob/main/samples/bot-conversation-sso-quickstart/BotSSOSetup.md))

#### App Role Assignment

The final step assigns the `Chatter` permission (created in the *prereq* module) to the system-assigned identity of the Azure App Service Teams `app-appid-region-test-teams` (created in the *prereq* module) for the scope of the application registration `app-ldc-appid-region-test-authconsumer` (created in the *prereq* module). 

Execute the following script with a user who has the `Application Administrator` role or is an owner of the application registration `app-ldc-appid-region-test-authconsumer`:

```ps1
$SystemAssignedIdentityNameOfTeamsAppService = "app-appid-region-dev-teams"
$AuthConsumerAppRegistrationName             = "app-ldc-appid-region-dev-authconsumer"
$PermissionName                              = "Chatter"

$SystemAssignedIdentity = (Get-AzureADServicePrincipal -Filter "displayName eq '$SystemAssignedIdentityNameOfTeamsAppService'")
Start-Sleep -Seconds 10
$GraphServicePrincipal = Get-AzureADServicePrincipal -Filter "displayName eq '$AuthConsumerAppRegistrationName'"
$AppRole = $GraphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $PermissionName -and $_.AllowedMemberTypes -contains "Application"}

New-AzureAdServiceAppRoleAssignment -ObjectId $SystemAssignedIdentity.ObjectId -PrincipalId $SystemAssignedIdentity.ObjectId -ResourceId $GraphServicePrincipal.ObjectId -Id $AppRole.Id
```

## Special Configurations

### Custom Domain

If network and DNS integration is required, adjust the bootstrap project or use the infrastructure provided by your *CCoE*. The configuration of the *prereq* module will change for DNS integration. Configuration changes related to network integration are only required in the *core* module.

**Terraform example (mycwyd/core.tf)**

```bash
module "cwyd_core" {
  source = "../../core"

  (...)

  # DNS settings
  enable_custom_domain    = true
  base_dns_company_domain = "chatwithme.ch" # Add your domain supported in Azure

  (...)
```

### Private Networking

```bash
module "cwyd_core" {
  source = "../../core"

  (...)

  # Network settings
  enable_private_endpoints              = true
  resource_group_name_private_dns_zones = "rgr-dnszones-chn-prod"
  subnet_private_address_prefixes       = ["10.0.0.0/28"]
  subnet_delegated_address_prefixes     = ["10.0.0.16/28"]

  (...)
```

### Teams Integration

```bash
module "cwyd_core" {
  source = "../../core"

  (...)

  # Teams App settings
  enable_teams_app        = true
  app_reg_teams_client_id = "" # Add client_id of app-ldc-mycwyd-chn-dev-teamsapp
  service_plan_sku_teams  = "B1"
  azure_bot_sku_teams     = "F0"

  (...)
```

## Next Steps

Validate the deployed resources in Azure. If everything is in place and the manual steps have been executed, proceed to the [*cywd-apps* README](../../cwyd-apps/README.md).