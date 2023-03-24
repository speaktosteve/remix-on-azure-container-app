[![👷 Build and Test](https://github.com/speaktosteve/remix-from-scratch/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/speaktosteve/remix-from-scratch/actions/workflows/build-and-test.yml)

[![🚀 Provision and Deploy](https://github.com/speaktosteve/remix-from-scratch/actions/workflows/provision-and-deploy.yml/badge.svg)](https://github.com/speaktosteve/remix-from-scratch/actions/workflows/provision-and-deploy.yml)

# Remix Accelerator

This repo provides the main building blocks to develop and deploy your full-stack [Remix](https://remix.run/docs) web application to the cloud.

It includes:

- really simple Remix app
- infrastructure as code using Bicep, creating minimal Azure resources for the app
- GitHub Actions to build and deploy your app

## Development

The app was created using `npx create-remix@latest`, using no stack as we define our own infra and deployment mechanisms.

### Running locally

From your terminal:

```sh
npm run dev
```

This starts your app in development mode, rebuilding assets on file changes.

## Infrastructure

The Remix app can be run locally either directly using `npm run dev` or within a Docker container, which is defined in the [Dockerfile](Dockerfile). When deployed to the cloud, the app runs as a container.

This accelerator deploys the Remix app to an [Azure Container App](https://azure.microsoft.com/en-us/products/container-apps) which provides a serverless host for the app to run on.

The following infrastructure is provisioned as defined in the Bicep definition files found in the [infra/](infra) directory:

- Resource group
  - Container registry
  - Container App
  - Container Apps Environment
  - Shared dashboard
  - Log Analytics workspace

## Actions

The following workflows are used to build and deploy the app to Azure. In order for these to work you will need to set up a number of secrets and variables in your repo. See Set Up.

GitHub actions: see workflows in [.github/workflows](.github/workflows)

### Build and Test workflow

![build-and-test workflow](docs/images/build-test-action.png?raw=true "Build and Test workflow")

### Provision and Deploy workflow

![provision-and-deploy workflow](docs/images/provision-deploy-action.png?raw=true "Provision and Deploy workflow")

### Respository set up

#### Secrets and first time build and deployment

**Variables**

The following repo variables will need creating:

- AZURE_ENV_NAME - e.g. remix-environment. Used by AZD to name the environment
- AZURE_LOCATION - e.g. uksouth. The Azure region where the infra will be created
- REMIX_APP_IMAGE_NAME - the name that the image will be given in the ACR repo

Your repo variables should look like this:
![variables](docs/images/repo-variables.png?raw=true "Repo Variables")

**Secrets**

- AZURE_CREDENTIALS, in order for the GitHub CLI to authenticate to your subscription: see https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux#use-the-azure-login-action-with-a-service-principal-secret
- AZURE_SUBSCRIPTION_ID - the ID of the subscription in which you want the resources created

NB: Known issue! The first time the provisioning and deployment workflow is run the deployment will fail. Certain configuration values will need taken from the newly-created ACR before the deployment workflow can successfully deploy the app.

Once the **Provision and Deploy workflow** is run the infrastructure should be created by the Provisioning stage, but the **Build and Push Image** will fail.
Once the infra is created, go to the ACR in the Azure Portal and grab the following information for these secrets:

- REGISTRY_ENDPOINT - the login server address of the newly created ACR overview screen, e.g. car654654645.azurecr.io
- REGISTRY_USERNAME - from the ACR access keys screen in the portal
- REGISTRY_PASSWORD - from the ACR access keys screen in the portal

Your repo secrets should look like this:
![secrets](docs/images/repo-secrets.png?raw=true "Repo Secrets")

If you then re-run the **Provision and Deploy workflow** it should complete successfully. You should then have a running app within the Container App service.
