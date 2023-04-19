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

**Service Principal**

In order for the docker build and push action to be able to connect to and push to ACR we are using a service principal.

Create your service principal like so:

```
ACR_NAME=[name of your Azure Container Registry]
SERVICE_PRINCIPAL_NAME=[Must be unique within your AD tenant]

# Obtain the full registry ID
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query "id" --output tsv)
# echo $registryId

# Create the service principal with rights scoped to the registry.
# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query "password" --output tsv)
USER_NAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)

# Output the service principal's credentials; use these in your services and
# applications to authenticate to the container registry.
echo "Service principal ID: $USER_NAME"
echo "Service principal password: $PASSWORD"
```

You will then need to grant the above service principal the permissions to push to the ACR

```
az role assignment create --assignee [ID OF SERVICE PRINCIPAL] --scope /subscriptions/[SUBSCRIPTION ID]/resourceGroups/[RESOURCE GROUP NAME]/providers/Microsoft.ContainerRegistry/registries/[name of your Azure Container Registry] --role acrpush


```

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

NB: currently the service principal is not created as part of the automation, you must create it manually as per instructions above. As it relies on the existence of the ACR, you will need to run the provisioning and deployment workflow first (it will fail), then create the service principal and add its details to the secrets before running the workflow again.

Once the **Provision and Deploy workflow** is run the infrastructure should be created by the Provisioning stage, but the **Build and Push Image** will fail.
Once the infra is created, go to the ACR in the Azure Portal and grab the following information for these secrets:

- REGISTRY_ENDPOINT - the login server address of the newly created ACR overview screen, e.g. car654654645.azurecr.io
- REGISTRY_USERNAME - the client ID of the service principal created above
- REGISTRY_PASSWORD - the client secret of the service principal created above

Your repo secrets should look like this:
![secrets](docs/images/repo-secrets.png?raw=true "Repo Secrets")

If you then re-run the **Provision and Deploy workflow** it should complete successfully. You should then have a running app within the Container App service.
