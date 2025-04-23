const config = {
  botId: process.env.BOT_ID,
  backendAppId: process.env.BACKEND_APP_ID,
  botPassword: process.env.BOT_PASSWORD,
  azureFunctionUrl: process.env.AZURE_FUNCTION_URL,
  blobBaseUrl: process.env.BLOB_BASE_URL,
  connectionName: process.env.OAUTH_CONNECTION_NAME,
  tenantId: process.env.SSO_TENANT_ID,
  expectedAudience: process.env.SSO_EXPECTED_AUDIENCE
};

export default config;
