# Overview of the Teams Bot Blueprint

This template is based on the teams extension of the chat-with-your-data-solution-accelerator: https://github.com/Azure-Samples/chat-with-your-data-solution-accelerator/tree/main/extensions/teams

This blueprint features the the following extensions:
- Single-sign-on for users
- Extended formatting of references: Markdown Items and Tables
- Authenticated accesses to the backend web app

You can extend it as you wish.

Make sure, that the [manual infrastructure setup](../terraform/core/README.md#manual-steps) steps are done and that the [Web App](../cwyd-apps/README.md) is running because the teams app connects to the web app.

## Development Setup

- Install Node.js
  
  For example use node version manager: 
  ```bash
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  nvm install 18
  ```

- Install teams toolkit: https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/teams-toolkit-cli?pivots=version-three
  ```bash
  npm install -g @microsoft/teamsapp-cli
  ```

## Deployment

Make sure you have setup the Azure DevOps pipeline from the [Web App](../cwyd-apps/README.md)

Before running the pipeline choose the teams app.
This pipeline will deploy the App Service that communicates with the Teams client.

#### Teams App Packaging

To create the App in the Teams client, you need to packaget it bevore you upload it.

First configure the settings in the environment files `/teams-app/env/.env.*`.

The run the packaging command:

```bash
npm install @microsoft/teamsapp-cli
teamsapp package --env=dev
```

Then you can upload the resulting package to the teams client.
To use it for testing purposes, you need to configure the M365 tenant that allows uploading Teams Apps for your self.

## Get Started with Blueprint Development

**Prerequisites**

To run the Basic Bot template in your local dev machine, you will need:

- [Node.js](https://nodejs.org/), supported versions: 16, 18
- [Teams Toolkit Visual Studio Code Extension](https://aka.ms/teams-toolkit) version 5.0.0 and higher or [Teams Toolkit CLI](https://aka.ms/teamsfx-toolkit-cli)

1. First, select the Teams Toolkit icon on the left in the VS Code toolbar.
2. Press F5 to start debugging which launches your app in Teams App Test Tool using a web browser. Select `Debug in Test Tool (Preview)`.
3. The browser will pop up to open Teams App Test Tool.
4. You will receive a welcome message from the bot, and you can send anything to the bot to get an echoed response.

**Congratulations**! You are running an application that can now interact with users in Teams App Test Tool:

![basic bot](https://github.com/OfficeDev/TeamsFx/assets/9698542/bdf87809-7dd7-4926-bff0-4546ada25e4b)

## What's Included in the Blueprint

| Folder | Contents |
| - | - |
| .vscode | VSCode files for debugging |
| appPackage | Templates for the Teams application manifest |
| env | Environment files |

The following files can be customized and demonstrate an example implementation to get you started.

| File | Contents |
| - | - |
| teamsBot.ts| Handles business logics for the Basic Bot. |
| index.ts| `index.ts` is used to setup and configure the Basic Bot. |

The following are Teams Toolkit specific project files. You can [visit a complete guide on Github](https://github.com/OfficeDev/TeamsFx/wiki/Teams-Toolkit-Visual-Studio-Code-v5-Guide#overview) to understand how Teams Toolkit works.

| File | Contents |
| - | - |
| teamsapp.yml | This is the main Teams Toolkit project file. The project file defines two primary things:  Properties and configuration Stage definitions. |
| teamsapp.local.yml | This overrides `teamsapp.yml` with actions that enable local execution and debugging. |
| teamsapp.testtool.yml | This overrides `teamsapp.yml` with actions that enable local execution and debugging in Teams App Test Tool. |
