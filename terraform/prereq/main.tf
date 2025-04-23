terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      version               = ">= 4.16.0"
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.application, azurerm.perimeter]
    }
    azuread = {
      version = ">= 3.0.2"
      source  = "hashicorp/azuread"
    }
  }
}

locals {
  subdomain                = var.stage_alias == "prod" ? var.application_name : "${var.application_name}-${var.stage_alias}"
  application_context_lz   = format("%s-%s-%s", var.application_name, var.location_alias, var.stage_alias) # parent_index is not part of this application context to allow applications to use it without interfering with resource group, vnet, service principal etc.
  application_context      = format("%s%s-%s-%s", var.application_name, var.parent_index, var.location_alias, var.stage_alias)
  azuread_application_tags = [for k, v in var.tags : "${k}: ${v}"]
  service_principal_owners = concat(
    var.service_principal_owners == [] ? [] : data.azuread_users.service_principal_owners.object_ids,
    var.sp_ado_service_connection_ccoe_name == "" ? [] : [data.azuread_service_principal.ado_service_connection_ccoe[0].object_id],
    var.sp_ado_service_connection_applicationteam_name == "" ? [] : [data.azuread_service_principal.ado_service_connection_applicationteam[0].object_id]
  )
  service_principal_owners_filtered = [for item in local.service_principal_owners : item if item != data.azuread_client_config.current.client_id] # remove SP used to create azuread_application_registration
}
