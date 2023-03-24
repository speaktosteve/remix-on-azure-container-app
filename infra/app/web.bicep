param name string
param location string = resourceGroup().location
param tags object = {}

param containerAppsEnvironmentName string
param containerRegistryName string
param imageName string = ''
param serviceName string = 'web'

@secure()
param sessionSecret string

module app '../core/host/container-app.bicep' = {
  name: '${serviceName}-container-app-module'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    env: [
            {
        name: 'SESSION_SECRET'
        value: sessionSecret
      }
      {
        name: 'PORT'
        value: '3000'
      }
      {
        name: 'NODE_ENV'
        value: 'production'
      }
    ]
    imageName: !empty(imageName) ? imageName : 'nginx:latest'
    targetPort: 80
  }
}


output SERVICE_WEB_IDENTITY_PRINCIPAL_ID string = app.outputs.identityPrincipalId
output SERVICE_WEB_NAME string = app.outputs.name
output SERVICE_WEB_URI string = app.outputs.uri
output SERVICE_WEB_IMAGE_NAME string = app.outputs.imageName
