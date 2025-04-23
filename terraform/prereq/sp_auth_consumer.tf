data "azuread_groups" "auth_consumer" {
  display_names = var.app_reg_entraid_group_consumer
}

resource "azuread_application_registration" "auth_consumer" {
  display_name                           = lower(format("app-ldc-%s-authConsumer", local.application_context))
  group_membership_claims                = ["None"]
  sign_in_audience                       = "AzureADMyOrg"
  notes                                  = "Managed by Terraform"
  requested_access_token_version         = 1
  implicit_access_token_issuance_enabled = false
  implicit_id_token_issuance_enabled     = true
}

resource "azuread_application_owner" "auth_consumer" {
  for_each = toset(local.service_principal_owners_filtered)

  application_id  = azuread_application_registration.auth_consumer.id
  owner_object_id = each.key
}

resource "azuread_application_fallback_public_client" "auth_consumer" {
  application_id = azuread_application_registration.auth_consumer.id
  enabled        = false
}

resource "azuread_application_redirect_uris" "auth_consumer" {
  count = var.enable_custom_domain ? 1 : 0
  
  application_id = azuread_application_registration.auth_consumer.id
  type           = "Web"
  redirect_uris = [
    lower(format("https://%s.%s.%s/.auth/login/aad/callback", var.chatbot_url_prefix, local.subdomain, data.azurerm_dns_zone.base[0].name))
  ]
}

resource "random_uuid" "auth_consumer_chatter" {}

resource "azuread_application_app_role" "auth_consumer" {
  application_id       = azuread_application_registration.auth_consumer.id
  role_id              = random_uuid.auth_consumer_chatter.result
  allowed_member_types = ["Application"]
  description          = "Chatter Applications have access to sending chat messages."
  display_name         = "Chatter"
  value                = "Chatter"
}

resource "azuread_application_identifier_uri" "auth_consumer" {
  application_id = azuread_application_registration.auth_consumer.id
  identifier_uri = format("api://%s", azuread_application_registration.auth_consumer.client_id)
}

resource "azuread_application_api_access" "auth_consumer_graph" {
  application_id = azuread_application_registration.auth_consumer.id
  api_client_id  = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

  scope_ids = [
    "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
  ]
}

# resource "azuread_application_api_access" "auth_consumer" {
#   application_id = azuread_application_registration.auth_consumer.id
#   api_client_id  = azuread_application_registration.auth_consumer.client_id

#   role_ids = [
#     azuread_application_app_role.auth_consumer.role_id
#   ]

#   scope_ids = [
#     "0aedde49-1324-4c04-aefa-a219e3cd1aeb"
#   ]
# }

resource "azuread_service_principal" "auth_consumer" {
  client_id                    = azuread_application_registration.auth_consumer.client_id
  app_role_assignment_required = true
  owners                       = local.service_principal_owners

  feature_tags {
    hide                  = true
    enterprise            = false
    custom_single_sign_on = false
    gallery               = false
  }
}

resource "azuread_app_role_assignment" "auth_consumer" {
  for_each            = toset(data.azuread_groups.auth_consumer.object_ids)
  app_role_id         = "00000000-0000-0000-0000-000000000000"
  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.auth_consumer.object_id
}
