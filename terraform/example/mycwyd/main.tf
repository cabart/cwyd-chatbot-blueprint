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
    azapi = {
      version = "1.15.0"
      source  = "azure/azapi"
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

locals {
  tags = {}
}
