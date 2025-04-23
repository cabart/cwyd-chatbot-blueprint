# Project settings

variable "application_name" {
  type        = string
  description = "An alphanumeric name for the application with a minimum length of 2 and a maximum length of 7. This value, in combination with location_alias, stage_alias, and parent_index, must be globally unique."
  validation {
    condition     = length(var.application_name) > 1 && length(var.application_name) < 8
    error_message = "Application name must be between 2 and 7 characters."
  }
}

variable "location_alias" {
  type        = string
  description = "A three-letter alias for an Azure location. Supported values are chn for Switzerland North, chw for Switzerland West, eun for North Europe, euw for West Europe, usw for West US, usw2 for West US 2, usc for Central US, use for East US, use2 for East US 2, usn for North Central US, frc for France Central, frs for France South, sdc for Sweden Central, and spc for Spain Central."
}

variable "stage_alias" {
  type        = string
  description = "An alias for the application stage. Supported values are dev, test, int, qa, prod, nonprod, sbox, and mbt."
}

variable "parent_index" {
  type        = string
  description = "An index used to make the application name unique during deployments of multiple versions. This will be part of the application name."
}

variable "tags" {
  type        = map(string)
  description = "An object of resource tags applied to every Azure service."
  default     = {}
}

variable "landing_zone_resource_group_name" {
  type        = string
  description = "The name of the Landing Zone resource group."
}

# DNS settings

variable "enable_custom_domain" {
  type        = bool
  description = "Defines whether a subdomain DNS zone is created and custom domains are configured."
  default     = true
}

variable "base_dns_company_domain" {
  type        = string
  description = "The company domain used to look up the base DNS zone. This variable is required when enable_custom_domain is enabled."
  default     = ""
}

variable "base_dns_resource_group_name" {
  type        = string
  description = "The resource group name containing the base DNS zone. This variable is required when enable_custom_domain is enabled."
  default     = ""
}

# Blueprint settings

variable "chatbot_url_prefix" {
  type        = string
  description = "The URL prefix for the chatbot, defaults to chat."
  default     = "chat"
}

variable "app_reg_entraid_group_consumer" {
  type        = list(string)
  description = "A list of Entra ID group names that are permitted access to the consumer application registration."
  default     = []
}

variable "sp_ado_service_connection_ccoe_name" {
  type        = string
  description = "The name of the service principal used for the Azure DevOps Service Connection by the CCoE. If an Azure DevOps Service Connection is used, the corresponding service principal is defined as an owner on deployed App Registrations."
  default     = ""
}

variable "sp_ado_service_connection_applicationteam_name" {
  type        = string
  description = "The name of the service principal used for the Azure DevOps Service Connection by the application team. If an Azure DevOps Service Connection is used, the corresponding service principal is defined as an owner on deployed App Registrations."
  default     = ""
}

variable "service_principal_owners" {
  type        = list(string)
  description = "A list of UPNs that will be set as owners on deployed App Registrations (service principals)."
  default     = []
}

variable "enable_teams_app" {
  type        = bool
  description = "Defines whether Teams integration should be deployed."
  default     = false
}
