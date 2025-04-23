resource "azurerm_log_analytics_workspace" "cwyd" {
  name                = format("log-%s", local.application_context)
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  location            = data.azurerm_resource_group.landing_zone.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "cwyd" {
  name                = format("appi-%s", local.application_context)
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  location            = data.azurerm_resource_group.landing_zone.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.cwyd.id
  tags                = merge(var.tags, { format("hidden-link:appi-%s", local.application_context) = "Resource" })
}

resource "azurerm_monitor_action_group" "cwyd" {
  name                = "Application Insights Smart Detection" # Predefined name
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  short_name          = "SmartDetect"
  tags                = var.tags

  arm_role_receiver {
    name                    = "Monitoring Contributor"
    role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
    use_common_alert_schema = true
  }

  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_smart_detector_alert_rule" "cwyd" {
  name                = format("alert-%s", local.application_context)
  resource_group_name = data.azurerm_resource_group.landing_zone.name
  severity            = "Sev3"
  scope_resource_ids  = [azurerm_application_insights.cwyd.id]
  frequency           = "PT1M"
  detector_type       = "FailureAnomaliesDetector"
  description         = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."
  tags                = var.tags

  action_group {
    ids = [azurerm_monitor_action_group.cwyd.id]
  }
}
