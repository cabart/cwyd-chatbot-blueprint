terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      version = ">= 4.16.0"
      source  = "hashicorp/azurerm"
    }
    azuread = {
      version = ">= 3.0.2"
      source  = "hashicorp/azuread"
    }
    azapi = {
      version = ">= 1.8.0"
      source  = "azure/azapi"
    }
  }
}

locals {
  subdomain = var.stage_alias == "prod" ? var.application_name : "${var.application_name}-${var.stage_alias}"
  application_context_lz = format("%s-%s-%s",
    var.application_name,
    var.location_alias,
    var.stage_alias
  ) # parent_index is not part of this application context to allow applications to use it without interfering with resource group, vnet, service principal etc.
  application_context = format("%s%s-%s-%s",
    var.application_name,
    var.parent_index,
    var.location_alias,
    var.stage_alias
  )
  application_context_cognitive_services = format("%s%s-%s-%s",
    var.application_name,
    var.parent_index,
    var.cognitive_services_location_alias,
    var.stage_alias
  )
  application_context_short = lower(replace(local.application_context, "-", ""))
  blob_container_name       = format("fileupload-%s-index", local.application_context)
}
