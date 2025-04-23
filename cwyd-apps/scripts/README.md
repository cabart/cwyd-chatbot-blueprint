# Data Ingestion

## Overview
The ingestion script takes documents from a storage account container and ingests in into the Azure search resource.
All properties used by the script are defined in a Key Vault.

The code for the ingestion script can be found in `scripts/data_prepraration.py`.

## Setup Key Vault with all Required Properties
The infrastructure setup creates a Key Vault called `kvcwydchn{stage}cwyd`. Make sure that you have defined all required properties:

- azure-blob-account-key
- azure-blob-account-name
- azure-blob-container-name
- azure-form-recognizer-endpoint
- azure-form-recognizer-key
- azure-openai-embedding-endpoint
- azure-openai-embedding-key
- azure-openai-embedding-name
- azure-openai-endpoint
- azure-openai-key
- azure-openai-model
- azure-openai-model-name
- azure-openai-resource
- azure-search-index
- azure-search-key
- azure-search-semantic-search-config
- azure-search-service
- azure-tenant-id
- ingest-chunk-size
- ingest-language
- ingest-location
- ingest-resource-group
- ingest-subscription-id
- ingest-token-overlap
- ingest-vector-config-name

## Run Ingestion

### Azure DevOps Pipeline
Create a new pipeline in Azure DevOps with `pipelines/ingestData.yml` and select the repository where the code is located.

Create the following pipeline variables:

| Variable | Content  | Description |
| - | - | - |
| cwydKeyVault | Name of the keyvault containing all the settings from above. | Azure Key Vault |
| serviceConnection | Name of service connection defined in Azure DevOps | Azure Resource Manager |

### Locally
- Install all Python dependencies `pip install requirements-dev.txt requirements.txt`
- Install Azure CLI `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`
- Login to Azure tenant: `az login --tenant tenantid`

```bash
 CWYD_KEY_VAULT=keyvaultname python scripts/data_preparation.py
```
