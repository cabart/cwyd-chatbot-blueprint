resource "azapi_resource" "rai_policy" {
  type      = "Microsoft.CognitiveServices/accounts/raiPolicies@2023-10-01-preview"
  name      = format("rai-%s", local.application_context_cognitive_services)
  parent_id = azurerm_cognitive_account.openai.id

  schema_validation_enabled = false

  body = jsonencode({
    properties = {
      mode           = "Default",
      basePolicyName = "Microsoft.Default",
      contentFilters = [
        { name = "Hate", blocking = true, enabled = true, allowedContentLevel = "High", source = "Prompt" },
        { name = "Sexual", blocking = true, enabled = true, allowedContentLevel = "High", source = "Prompt" },
        { name = "Selfharm", blocking = true, enabled = true, allowedContentLevel = "High", source = "Prompt" },
        { name = "Violence", blocking = true, enabled = true, allowedContentLevel = "High", source = "Prompt" },
        { name = "Hate", blocking = true, enabled = true, allowedContentLevel = "High", source = "Completion" },
        { name = "Sexual", blocking = true, enabled = true, allowedContentLevel = "High", source = "Completion" },
        { name = "Selfharm", blocking = true, enabled = true, allowedContentLevel = "High", source = "Completion" },
        { name = "Violence", blocking = true, enabled = true, allowedContentLevel = "High", source = "Completion" },
        { name = "Jailbreak", blocking = true, enabled = true, source = "Prompt" },
        { name = "Protected Material Text", blocking = false, enabled = false, source = "Completion" },
        { name = "Protected Material Code", blocking = false, enabled = false, source = "Completion" }
      ]
    }
  })
  depends_on = [
    azurerm_cognitive_account.openai
  ]
}
