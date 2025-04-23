resource "random_uuid" "access_as_user" {
  count = var.enable_teams_app ? 1 : 0
}

resource "azuread_application_registration" "teams_integration" {
  count = var.enable_teams_app ? 1 : 0

  display_name                           = lower("app-ldc-${local.application_context}-teamsApp")
  group_membership_claims                = ["ApplicationGroup"]
  sign_in_audience                       = "AzureADMultipleOrgs"
  notes                                  = "Managed by Terraform"
  requested_access_token_version         = 2
  implicit_access_token_issuance_enabled = true
  implicit_id_token_issuance_enabled     = true
}

resource "azuread_application_owner" "teams_integration" {
  for_each = var.enable_teams_app ? toset(local.service_principal_owners_filtered) : []

  application_id  = azuread_application_registration.teams_integration[0].id
  owner_object_id = each.key
}

resource "azuread_application_fallback_public_client" "teams_integration" {
  count = var.enable_teams_app ? 1 : 0

  application_id = azuread_application_registration.teams_integration[0].id
  enabled        = true
}

resource "azuread_application_redirect_uris" "teams_integration" {
  count = var.enable_teams_app ? 1 : 0

  application_id = azuread_application_registration.teams_integration[0].id
  type           = "Web"
  redirect_uris  = ["https://token.botframework.com/.auth/web/redirect"]
}

resource "random_uuid" "teams_integration_teams_chatter" {}

resource "azuread_application_app_role" "teams_integration" {
  count = var.enable_teams_app ? 1 : 0

  application_id       = azuread_application_registration.teams_integration[0].id
  role_id              = random_uuid.teams_integration_teams_chatter.result
  allowed_member_types = ["User"]
  description          = "TeamsChatter can interact with the cwyd teams bot."
  display_name         = "TeamsChatter"
  value                = "TeamsChatter"
}

resource "azuread_application_identifier_uri" "teams_integration" {
  count = var.enable_teams_app ? 1 : 0

  application_id = azuread_application_registration.teams_integration[0].id
  identifier_uri = format("api://botid-%s", azuread_application_registration.teams_integration[0].client_id)
}

resource "azuread_application_permission_scope" "teams_integration" {
  count = var.enable_teams_app ? 1 : 0

  application_id = azuread_application_registration.teams_integration[0].id
  scope_id       = random_uuid.access_as_user[0].id
  value          = "access_as_user"

  admin_consent_description  = "Allows Teams to call the app’s web APIs as the current user."
  admin_consent_display_name = "Teams can access the user’s profile"
  user_consent_description   = "Enable Teams to call this app’s APIs with the same rights that you have"
  user_consent_display_name  = "Teams can access your user profile and make requests on your behalf"
}

resource "azuread_application_pre_authorized" "teams_mobile_desktop_application" {
  count = var.enable_teams_app ? 1 : 0

  application_id       = azuread_application_registration.teams_integration[0].id
  authorized_client_id = "1fec8e78-bce4-4aaf-ab1b-5451cc387264" # Teams mobile/desktop application

  permission_ids = [
    azuread_application_permission_scope.teams_integration[0].scope_id
  ]
}

resource "azuread_application_pre_authorized" "teams_web_application" {
  count = var.enable_teams_app ? 1 : 0

  application_id       = azuread_application_registration.teams_integration[0].id
  authorized_client_id = "5e3ce6c0-2b1f-4285-8d4b-75ee78787346" # Teams web application 

  permission_ids = [
    azuread_application_permission_scope.teams_integration[0].scope_id
  ]
}

resource "azuread_application_api_access" "teams_integration" {
  count = var.enable_teams_app ? 1 : 0

  application_id = azuread_application_registration.teams_integration[0].id
  api_client_id  = azuread_application_registration.teams_integration[0].client_id

  scope_ids = [
    azuread_application_permission_scope.teams_integration[0].scope_id, # access_as_user
  ]
}

resource "azuread_application_api_access" "microsoft_graph" {
  count = var.enable_teams_app ? 1 : 0

  application_id = azuread_application_registration.teams_integration[0].id
  api_client_id  = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

  scope_ids = [
    "37f7f235-527c-4136-accd-4a02d197296e", # openid
    "14dad69e-099b-42c9-810b-d002981feec1", # profile
    "e1fe6dd8-ba31-4d61-89e7-88639da4683d"  # User.Read
  ]
}

resource "azuread_application_optional_claims" "teams_integration" {
  count = var.enable_teams_app ? 1 : 0

  application_id = azuread_application_registration.teams_integration[0].id

  access_token {
    name                  = "groups"
    essential             = false
    additional_properties = ["emit_as_roles"]
  }

  id_token {
    name                  = "groups"
    essential             = false
    additional_properties = ["emit_as_roles"]
  }

  saml2_token {
    name                  = "groups"
    essential             = false
    additional_properties = ["emit_as_roles"]
  }
}

resource "azuread_service_principal" "teams_integration" {
  count = var.enable_teams_app ? 1 : 0

  client_id                    = azuread_application_registration.teams_integration[0].client_id
  app_role_assignment_required = true
  owners                       = local.service_principal_owners

  feature_tags {
    hide                  = true
    enterprise            = false
    custom_single_sign_on = false
    gallery               = false
  }
}
