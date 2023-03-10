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

GitHub actions: see workflows in [.github/workflows](.github/workflows)

### Build and Test workflow

![build-and-test workflow](docs/images/build-test-action.png?raw=true "Build and Test workflow")

### Provision and Deploy workflow

![provision-and-deploy workflow](docs/images/provision-deploy-action.png?raw=true "Provision and Deploy workflow")
