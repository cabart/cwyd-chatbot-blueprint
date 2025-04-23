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

locals {
  tags = {}
}

resource "azurerm_resource_group" "landing_zone" {
  name = format("rgr-%s-%s-%s",
    "mycwyd", # application_name
    "chn",    # location_alias for Switzerland North
    "dev"     # stage_alias for development environment
  )
  location = "Switzerland North"
  tags     = local.tags
}

resource "azurerm_virtual_network" "landing_zone" {
  name = format("vnet-%s-%s-%s-private",
    "mycwyd", # application_name
    "chn",    # location_alias for Switzerland North
    "dev"     # stage_alias for development environment
  )
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  address_space       = ["10.0.0.0/27"]
  tags                = local.tags
}

resource "azurerm_resource_group" "base_dns" {
  name = format("rgr-dnszones-%s-prod",
    "chn", # location_alias for Switzerland North
  )
  location = "Switzerland North"
  tags     = local.tags
}

resource "azurerm_dns_zone" "base_dns" {
  name = format("azure.%s",
    "chatwithme.ch" # company_domain
  )
  resource_group_name = azurerm_resource_group.base_dns.name
  tags                = local.tags
}
