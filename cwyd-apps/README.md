# Webapp Deployment and Development

To deploy the blueprint you need to run the respective deployment pipeline. For development you can run it on your machine with `start.sh`. Or you can also the Docker contrainer.

## Deployment
Overview:
* You need a working [infrastructure setup](../terraform/prereq/README.md) on Azure
* Create and Run the App Pipeline to build and deploy the apps

### Pipeline Setup
Create a new pipeline in Azure DevOps and select the repository where the code is located.

Create the following pipeline variables:

| Variable Name | Content | Description |
| - | - | - |
| resourceGroup | Resource group name where the resources being deployed reside | Azure Resource Group |
| serviceConnection | Name of service connection defined in Azure DevOps | Azure Resource Manager |
| dockerRegistryServiceConnection | Name of the Docker service connection defined in Azure DevOps | Docker Registry Service Connection |
| registryName | Name of the Docker registry, URL like (without http://) | Azure Container Registry Name |
| webAppName | Name of the web app service | Web App Name |
| teamsAppName | Name of the Teams app service | Web App Name                       |


### Pipeline Run
Run the BuildAndDeploy stage of the pipeline to build and deploy all apps.

If you want to build or deploy a specific app, you can select the app and the stage you want to run.

Further parameters:
- you can specify the branch you want to build and deploy
- you can define a prefix of the container images that are build for the apps (`imageNamePrefix`) 
- you can define the tag of the container images that are build for the apps (`tag`)

## Development

### Local Setup and Development
1. Copy `.env.sample` to a new file called `.env` and configure the settings as described in the [Environment variables](#environment-variables) section.

    **Open AI variables**

    These variables are required:
    - `AZURE_OPENAI_RESOURCE`
    - `AZURE_OPENAI_MODEL`
    - `AZURE_OPENAI_KEY`

    These variables are optional:
    - `AZURE_OPENAI_TEMPERATURE`
    - `AZURE_OPENAI_TOP_P`
    - `AZURE_OPENAI_MAX_TOKENS`
    - `AZURE_OPENAI_STOP_SEQUENCE`
    - `AZURE_OPENAI_SYSTEM_MESSAGE`

    **AI Search variables**
    
    Required:
    - `AZURE_SEARCH_SERVICE`
    - `AZURE_SEARCH_INDEX`
    - `AZURE_SEARCH_KEY`

    These variables are optional:
    - `AZURE_SEARCH_USE_SEMANTIC_SEARCH`
    - `AZURE_SEARCH_SEMANTIC_SEARCH_CONFIG`
    - `AZURE_SEARCH_INDEX_TOP_K`
    - `AZURE_SEARCH_ENABLE_IN_DOMAIN`
    - `AZURE_SEARCH_CONTENT_COLUMNS`
    - `AZURE_SEARCH_FILENAME_COLUMN`
    - `AZURE_SEARCH_TITLE_COLUMN`
    - `AZURE_SEARCH_URL_COLUMN`
    - `AZURE_SEARCH_VECTOR_COLUMNS`
    - `AZURE_SEARCH_QUERY_TYPE`
    - `AZURE_SEARCH_PERMITTED_GROUPS_COLUMN`
    - `AZURE_SEARCH_STRICTNESS`
    - `AZURE_OPENAI_EMBEDDING_NAME`

    **Chat history variables**
    - `AZURE_COSMOSDB_ACCOUNT`
    - `AZURE_COSMOSDB_DATABASE`
    - `AZURE_COSMOSDB_CONVERSATIONS_CONTAINER`
    - `AZURE_COSMOSDB_ACCOUNT_KEY`

    **Message feedback**
    - `AZURE_COSMOSDB_ENABLE_FEEDBACK=True`

2. If you want to use RBAC Authentication instead of keys, do not set the `*_KEY` variables. Login to Azure from your command line `az login --tenant $tenantid`. This will allow the app to access Azure resources on your behalf.
3. Start the app with `start.sh`. This will build the frontend, install backend dependencies, and then start the app. Or, just run the backend in debug mode using the VSCode debug configuration in `.vscode/launch.json`.
4. You can see the local running app at http://127.0.0.1:50505.

### Local Development with Docker
You can develop the apps locally by running them in a local Docker container.

1. Add values for the required environment variables in the `.env` file in `cwyd-apps`. Copy `.env.sample` to `.env` and fill in the values.
2. Adjust the Docker image to copy the `.env` file into the container in the `Dockerfile` of the app (p.e. `docker/WebApp.Dockerfile`).
3. Build the Docker image on your machine:
```bash
docker build . -f .\docker\WebApp.Dockerfile --progress plain -t webapp:1
```

4. Run the Docker container:
```bash
docker run -it bash -p 127.0.0.1:80:80 webapp:1
```

5. Access the app in your browser at `http://localhost/` 
6. Do not forget to comment the line that copies the `.env` file into the container in the `Dockerfile` before you commit your changes.

## Common Customizations

You can customize some elements of the UI through [environment variables](#environment-variables).

- `UI_TITLE`
- `UI_LOGO`
- `UI_CHAT_TITLE`
- `UI_CHAT_LOGO`
- `UI_CHAT_DESCRIPTION`
- `UI_FAVICON`
- `UI_SHOW_SHARE_BUTTON`

You can customize the frontend freely by changing the source code (`frontend/src`).

Running `start.sh` will also rebuild the frontend.

## Scalability
You can configure the number of threads and workers in `gunicorn.conf.py`. After making a change, redeploy your app using the pipeline.

See the [Oryx documentation](https://github.com/microsoft/Oryx/blob/main/doc/configuration.md) for more details on these settings.

### Debugging your Deployed App
Set the environment variable `WEBAPP_DEBUG` to `true`.
On Azure you can set the respective app setting via the portal.
To see the logs in log streaming in the portal, you need to enable logging on disk on the App Service in the portal.
Now, you should be able to see logs from your app by viewing "Log stream" under Monitoring.

## Environment Variables Overview

| App Setting | Value | Description |
| - | - | - |
| AZURE_SEARCH_SERVICE | | The name of your Azure AI Search resource |
| AZURE_SEARCH_INDEX | | The name of your Azure AI Search Index |
| AZURE_SEARCH_KEY | | An admin key for your Azure AI Search resource |
| AZURE_SEARCH_USE_SEMANTIC_SEARCH | `false` | Whether or not to use semantic search |
| AZURE_SEARCH_QUERY_TYPE | `simple` | Query type: simple, semantic, vector, vectorSimpleHybrid, or vectorSemanticHybrid. Takes precedence over `AZURE_SEARCH_USE_SEMANTIC_SEARCH` |
| AZURE_SEARCH_SEMANTIC_SEARCH_CONFIG | | The name of the semantic search configuration to use if using semantic search. |
| AZURE_SEARCH_TOP_K | `5` | The number of documents to retrieve from Azure AI Search. |
| AZURE_SEARCH_ENABLE_IN_DOMAIN | `true` | Limits responses to only queries relating to your data. |
| AZURE_SEARCH_CONTENT_COLUMNS | | List of fields in your Azure AI Search index that contains the text content of your documents to use when formulating a bot response. Represent these as a string joined with `\|`, e.g. `product_description\|product_manual` |
| AZURE_SEARCH_FILENAME_COLUMN | | Field from your Azure AI Search index that gives a unique idenitfier of the source of your data to display in the UI. |
| AZURE_SEARCH_TITLE_COLUMN | | Field from your Azure AI Search index that gives a relevant title or header for your data content to display in the UI. |
| AZURE_SEARCH_URL_COLUMN | | Field from your Azure AI Search index that contains a URL for the document, e.g. an Azure Blob Storage URI. This value is not currently used. |
| AZURE_SEARCH_VECTOR_COLUMNS | | List of fields in your Azure AI Search index that contain vector embeddings of your documents to use when formulating a bot response. Represent these as a string joined with `\|`, e.g. `product_description\|product_manual` |
| AZURE_SEARCH_PERMITTED_GROUPS_COLUMN | | Field from your Azure AI Search index that contains AAD group IDs that determine document-level access control. |
| AZURE_SEARCH_STRICTNESS | `3` | Integer from 1 to 5 specifying the strictness for the model limiting responses to your data. |
| AZURE_OPENAI_RESOURCE | | the name of your Azure OpenAI resource |
| AZURE_OPENAI_MODEL | | The name of your model deployment |
| AZURE_OPENAI_ENDPOINT | | The endpoint of your Azure OpenAI resource. |
| AZURE_OPENAI_MODEL_NAME | `gpt-35-turbo-16k` | The name of the model |
| AZURE_OPENAI_KEY | | One of the API keys of your Azure OpenAI resource |
| AZURE_OPENAI_TEMPERATURE | `0`| What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. A value of 0 is recommended when using your data. |
| AZURE_OPENAI_TOP_P | `1.0` | An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. We recommend setting this to 1.0 when using your data. |
| AZURE_OPENAI_MAX_TOKENS | `1000` | The maximum number of tokens allowed for the generated answer. |
|AZURE_OPENAI_STOP_SEQUENCE | | Up to 4 sequences where the API will stop generating further tokens. Represent these as a string joined with `\|`, e.g. `stop1\|stop2\|stop3` |
| AZURE_OPENAI_SYSTEM_MESSAGE | `You are an AI assistant that helps people find information.`| A brief description of the role and tone the model should use |
| AZURE_OPENAI_PREVIEW_API_VERSION | `2024-02-15-preview` | API version when using Azure OpenAI on your data |
| AZURE_OPENAI_STREAM | `true` | Whether or not to use streaming for the response |
| AZURE_OPENAI_EMBEDDING_NAME | | The name of your embedding model deployment if using vector search. |
| UI_TITLE | `Contoso` | Chat title (left-top) and page title (HTML) |
| UI_LOGO | | Logo (left-top). Defaults to Contoso logo. Configure the URL to your logo image to modify. |
| UI_CHAT_LOGO | | Logo (chat window). Defaults to Contoso logo. Configure the URL to your logo image to modify. |
| UI_CHAT_TITLE | `Start chatting` | Title (chat window) |
| UI_CHAT_DESCRIPTION | `This chatbot is configured to answer your questions` | Description (chat window) |
| UI_FAVICON | | Defaults to Contoso favicon. Configure the URL to your favicon to modify. |
| UI_SHOW_SHARE_BUTTON | `true` | Share button (right-top) |
| SANITIZE_ANSWER | `false` | Whether to sanitize the answer from Azure OpenAI. Set to True to remove any HTML tags from the response. |
| USE_PROMPTFLOW | `false` | Use existing Promptflow deployed endpoint. If set to `true` then both `PROMPTFLOW_ENDPOINT` and `PROMPTFLOW_API_KEY` also need to be set. |
| PROMPTFLOW_ENDPOINT | | URL of the deployed Promptflow endpoint e.g. https://pf-deployment-name.region.inference.ml.azure.com/score |
| PROMPTFLOW_API_KEY | | Auth key for deployed Promptflow endpoint. Note: only key-based authentication is supported. |
| PROMPTFLOW_RESPONSE_TIMEOUT | `120`| Timeout value in seconds for the Promptflow endpoint to respond. |
| PROMPTFLOW_REQUEST_FIELD_NAME | `question` | Default field name to construct Promptflow request. Note: chat_history is auto constucted based on the interaction, if your API expects other mandatory field you will need to change the request parameters under `promptflow_request` function. |
| PROMPTFLOW_RESPONSE_FIELD_NAME | `answer` |Default field name to process the response from Promptflow request. |

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
