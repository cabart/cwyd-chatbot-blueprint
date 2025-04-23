# Prereq Module

The *prereq* and *core* modules separate responsibilities between the *Cloud Center of Excellence* ([CCoE](https://learn.microsoft.com/de-de/azure/cloud-adoption-framework/organize/cloud-center-of-excellence)) and the application team utilizing the CWYD blueprint.

The separation of Azure infrastructure into two modules addresses the different permissions typically held by the *CCoE* and the application team. Azure services requiring higher permissions are deployed as part of the *prereq* module. If a *CCoE* exists, the landing zone resource group and *prereq* module are deployed by them. The *core* module is then deployed by the application team.

This blueprint follows the [Azure landing zone](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/) concept and requires pre-deployed Azure services, which are described in the *Requirements* section.

| Module | Deployed by[1] | Description |
| - | - | - |
| Required Azure resources | CCoE | The required Azure resources, such as the resource group (landing zone) and optional virtual network and DNS infrastructure, are usually deployed and managed by the *CCoE*. If this is not the case, there is a [bootstrap project](../example/bootstrap/) that provides instructions on deploying these resources via Terraform. However, a fully integrated virtual network and DNS setup may require more than the provided resource examples. |
| *prereq* | CCoE | The required permissions listed below are usually not granted to application teams. Therefore, the *CCoE* typically deploys the *prereq* module. After deployment, the landing zone resource group, including the *prereq* services, is handed over to the application team. |
| *core* | Application team | The required permissions align with the [Azure landing zone role concept](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/identity-access-landing-zones#built-in-roles). |

[1] This is a recommendation based on the [Cloud Adoption Framework (CAF)](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/) and the [Azure landing zone concept](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/).

## Requirements

The *prereq* module has specific requirements. As mentioned in the introduction, some Entra ID / subscription permissions and Azure services are needed.

### Permissions

To deploy the required Azure resources and the *prereq* module, the following permissions are required:

| Permission | Scope[2] | Description |
| - | - | - |
| Application Administrator | Entra ID | Required to create App Registrations and Enterprise Applications (service principals). See [Entra ID built-in role definition](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference#application-administrator). |
| Owner | Landing Zone | Required to create Azure services and apply RBAC permissions. See [Azure RBAC built-in role definition](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/privileged#owner). |
| Contributor | DNS | Required to create DNS records in the base DNS zone if the DNS zone for a custom domain is enabled. See [Azure RBAC built-in role definition](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/privileged#contributor). |

[2] The *Landing Zone* scope implies RBAC permissions at the subscription level, as multiple resource groups must be created. For the *core* module, permissions on the landing zone resource group `rgr-mycwyd-chn-dev` are sufficient.

### Azure Services

Azure services must be created in advance of deploying the *prereq* and *core* modules. This can be done using the [bootstrap project](../example/bootstrap/) or manually via the Azure Portal.

**Terraform exmaple (example/bootstrap/main.tf)**
```bash
terraform {
  required_version = "1.9.0"
  required_providers {
    azurerm = {
      version = "4.16.0"
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  subscription_id = "" # TODO: Add the subscription id
  features {}
}

# TODO: Add required resources from below
```

### (Required) Resource Group (Landing Zone)

The resource group represents the landing zone.

The naming pattern of the resource group is `rgr-[application_name]-[location_alias]-[stage_alias]`. In the provided [example](../example/mycwyd/), the resource group's name is `rgr-mycwyd-chn-dev`.

| Variable | Description |
| - | - |
| application_name | An alphanumeric name for the application with a minimum length of 2 and a maximum length of 7. |
| location_alias | A three-letter alias for an Azure location. Supported values are *chn* for Switzerland North, *chw* for Switzerland West, *eun* for North Europe, *euw* for West Europe, *usw* for West US, *usw2* for West US 2, *usc* for Central US, *use* for East US, *use2* for East US 2, *usn* for North Central US, *frc* for France Central, *frs* for France South, *sdc* for Sweden Central, and *spc* for Spain Central. |
| stage_alias | An alias for the application stage. Supported values are *dev*, *test*, *int*, *qa*, *prod*, *nonprod*, *sbox*, and *mbt*. |

**Terraform example (example/bootstrap/main.tf)**
```bash
resource "azurerm_resource_group" "landing_zone" {
  name = format("rgr-%s-%s-%s",
    "mycwyd", # application_name
    "chn",    # location_alias for Switzerland North
    "dev"     # stage_alias for development environment
  )
  location = "Switzerland North"
}
```

### (Optional) Virtual Network

If the blueprint requires network integration via private endpoints, a virtual network must be defined and [peered](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) with the required [Azure Private Endpoint private DNS zones](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns). If network integration is enabled in the *core* module, the [DeployIfNotExist policy to create DNS records](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/private-link-and-dns-integration-at-scale) must be in place, or a manual process must be supported.

The naming pattern of the virtual network is `vnet-[application_name]-[location_alias]-[stage_alias]-private`. In the provided [example](../example/mycwyd/), the virtual network's name is `vnet-mycwyd-chn-dev-private`.

| Variable | Description |
| - | - |
| application_name | (see above) |
| location_alias | (see above) |
| stage_alias | (see above) |

**Terraform example (example/bootstrap/main.tf)**
```bash
resource "azurerm_virtual_network" "landing_zone" {
  name = format("vnet-%s-%s-%s-private",
    "mycwyd", # application_name
    "chn",    # location_alias for Switzerland North
    "dev"     # stage_alias for development environment
  )
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  address_space       = ["10.0.0.0/27"]
}
```

### (Optional) DNS Zone for Custom Domains

If the blueprint requires a custom domain for Azure App Services, a base DNS zone must be created in advance. If not required, disable the corresponding Terraform variables in the *prereq* and *core* modules. The naming pattern for the base DNS zone is `azure.[company_domain]`. Using custom domains requires a proper DNS setup within your Azure tenant.

| Variable | Description |
| - | - |
| company_domain | Use your company domain or a DNS name managed by you. |

**Terraform example (example/bootstrap/main.tf)**
```bash
resource "azurerm_resource_group" "base_dns" {
  name = format("rgr-dnszones-%s-prod",
    "chn", # location_alias for Switzerland North
  )
  location = "Switzerland North"
}

resource "azurerm_dns_zone" "base_dns" {
  name = format("azure.%s",
    "chatwithme.ch" # company_domain
  )
  resource_group_name = azurerm_resource_group.base_dns.name
}
```

## Deployment

After obtaining the required permissions and deploying at least the landing zone resource group via the [bootstrap project](../example/bootstrap/), the next step is configuring the *prereq* module.

### Creating the Parent Module

The *prereq* module is a child module. A Terraform parent module must be created. An example is provided [here](../example/mycwyd/main.tf).

The *prereq* module requires two Terraform AzureRM providers. The first provider refers to the landing zone subscription, while the second refers to the subscription where the base DNS zone is deployed. Even if both are in the same subscription (but different resource groups), both providers must be explicitly configured.

The [Terraform examples](../example/mycwyd/) use a local Terraform state file configuration.

**Terraform example (example/mycwyd/main.tf)**
```bash
terraform {
  required_version = "1.9.0"
  required_providers {
    azurerm = {
      version = "4.16.0"
      source  = "hashicorp/azurerm"
    }
    azuread = {
      version = "3.0.2"
      source  = "hashicorp/azuread"
    }
  }
}

provider "azurerm" {
  subscription_id = "" # TODO: Add the subscription id
  features {}
}

provider "azurerm" {
  alias           = "perimeter"
  subscription_id = "" # TODO: Add the subscription id
  features {}
}

provider "azuread" {}
```

### Module Configuration

The default configuration does not support virtual network integration, custom domains, or Microsoft 365 Teams integration. For documentation purposes, variables with default values equal to example values are also defined in the Terraform example. To check default values, refer to [variable.tf](./variables.tf).

| Variable | Description | Example Value |
| - | - | - |
| application_name | An alphanumeric name for the application with a minimum length of 2 and a maximum length of 7. This value, in combination with `location_alias`, `stage_alias`, and `parent_index`, must be globally unique. | `mycwyd` |
| location_alias | A three-letter alias for an Azure location. Supported values are *chn* for Switzerland North, *chw* for Switzerland West, *eun* for North Europe, *euw* for West Europe, *usw* for West US, *usw2* for West US 2, *usc* for Central US, *use* for East US, *use2* for East US 2, *usn* for North Central US, *frc* for France Central, *frs* for France South, *sdc* for Sweden Central, and *spc* for Spain Central. | `chn` |
| stage_alias | An alias for the application stage. Supported values are *dev*, *test*, *int*, *qa*, *prod*, *nonprod*, *sbox*, and *mbt*. | `dev` |
| parent_index | An index used to make the application name unique during deployments of multiple versions. This will be part of the application name. | `""` |
| tags | An object of resource tags applied to every Azure service. | `{}` |
| landing_zone_resource_group_name | The name of the Landing Zone resource group. | `rg-mycwyd-chn-dev` |
| enable_custom_domain | Defines whether a subdomain DNS zone is created and custom domains are configured. | `false` |
| base_dns_company_domain | The company domain used to look up the base DNS zone. This variable is required when `enable_custom_domain` is enabled. | `""` |
| base_dns_resource_group_name | The resource group name containing the base DNS zone. This variable is required when `enable_custom_domain` is enabled. | `""` |
| chatbot_url_prefix | The URL prefix for the chatbot, defaults to `chat`. | `chat` |
| app_reg_entraid_group_consumer | A list of Entra ID group names that are permitted access to the consumer application registration. | `[]` |
| sp_ado_service_connection_ccoe_name | The name of the service principal used for the Azure DevOps Service Connection by the *CCoE*. If an Azure DevOps Service Connection is used, the corresponding service principal is defined as an owner on deployed App Registrations. | `""` |
| sp_ado_service_connection_applicationteam_name | The name of the service principal used for the Azure DevOps Service Connection by the application team. If an Azure DevOps Service Connection is used, the corresponding service principal is defined as an owner on deployed App Registrations. | `""` |
| service_principal_owners | A list of UPNs that will be set as owners on deployed App Registrations (service principals). | `[]` |
| enable_teams_app | Defines whether Teams integration should be deployed. | `false` |

**Terraform example (example/mycwyd/prereq.tf)**
```bash
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

  # Blueprint settings
  chatbot_url_prefix                             = "chat"
  app_reg_entraid_group_consumer                 = []
  sp_ado_service_connection_ccoe_name            = ""
  sp_ado_service_connection_applicationteam_name = ""
  service_principal_owners                       = []
  enable_teams_app                               = false
}
```

**Terraform example (example/mycwyd/output.tf)**
```bash
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
```

### Terraform Deployment

Before deploying the *prereq* module, ensure that at least the landing zone resource group is deployed and that the required permissions mentioned above have been granted to the deployment user.

As mentioned, the examples use a local Terraform state file configuration. Ensure that the required Terraform version specified in [main.tf](../example/mycwyd/main.tf) is installed.

To deploy, open a terminal and navigate to the folder where the parent module is created. Start by initializing Terraform:
```bash
terraform init
```

Log in to the Azure tenant where the blueprint will be deployed:
```bash
az login
```

Create a plan to validate the resources that Terraform will create:
```bash
terraform plan
```

If the Terraform plan looks correct, proceed with the deployment. Don’t forget to approve the plan:
```bash
terraform apply
```

## Special Configurations

### Custom Domain

If network and DNS integration is required, adjust the bootstrap project or use the network and DNS infrastructure provided by your *CCoE*.

**Terraform example (example/mycwyd/prereq.tf)**
```bash
module "cwyd_prereq" {
  source = "../../prereq"

  providers = {
    azurerm.application = azurerm
    azurerm.perimeter   = azurerm.perimeter
  }

  (...)

  # DNS settings
  enable_custom_domain         = true
  base_dns_company_domain      = "chatwithme.ch"
  base_dns_resource_group_name = "rgr-dnszones-chn-prod"

  (...)
}
```

### Teams Integration
```bash
module "cwyd_prereq" {
  source = "../../prereq"

  providers = {
    azurerm.application = azurerm
    azurerm.perimeter   = azurerm.perimeter
  }

  (...)
  enable_teams_app = true
}
```

## Next Steps

Validate the deployed resources in Azure and proceed to the [*core* README](../core/README.md).
