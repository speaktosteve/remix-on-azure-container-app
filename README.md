# Remix Accelerator

This repo provides the main building blocks to develop and deploy your full-stack [Remix](https://remix.run/docs) web application to the cloud.

It includes:

- really simple Remix app
- infrastructure as code using Bicep
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
