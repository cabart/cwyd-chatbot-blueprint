# CWYD Blueprint

This CWYD Blueprint is based on the [Microsoft Sample Chat App with AOAI](https://github.com/microsoft/sample-app-aoai-chatGPT).

The *Chat with Your Data* blueprint is a project designed to provide a simple and easy-to-use chatbot for interacting with your data.

## Usage Guidelines

This repository must be forked into your own project; it cannot be consumed as a Terraform module.

Set up the pipelines according to the stages you need and configure the appropriate variables for each pipeline.

## Blueprint Structure

### Infrastructure

The `terraform/` section contains the Azure infrastructure definition in Terraform. It is divided into a *core* and *prereq* Terraform module. 
* `terraform/prereq` [prereq module](./terraform/prereq/readme.md): The *prereq* module creates the necessary Azure and Entra ID services required to deploy the *core* module.
* `terraform/core` [core module](./terraform/core/README.md): The *core* module defines the Azure services used for chatting with your data and running the applications.

The dependencies between the *core* and *prereq* modules, the requirements for the *prereq* module, configuration options, and examples are documented in the README files within each module.

A Terraform example, including the bootstrapping process (required Azure resources for the *prereq* module), can be found [here](./terraform/example/).

## Application

The application consists of two parts:
  * `cwyd-apps/` [Web App](./cwyd-apps/README.md): Web hat user interface and backend endpoints
    * `cwyd-apps/backend` Backend API endpoints
    * `cwyd-apps/frontend` Frontend react components
    * `cwyd-apps/scripts` [Data ingestion](./cwyd-apps/scripts/README.md): Ingest data into AI Search
  * `teams-app/` [Teams App](./teams-app/README.md): App service and packaging for app in teams clients
