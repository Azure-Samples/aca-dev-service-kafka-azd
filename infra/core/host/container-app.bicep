param name string
param location string = resourceGroup().location
param tags object = {}

param environmentId string
param serviceId string = ''
param containerName string
param containerImage string
param containerCommands array = []
param containerArgs array = []
param minReplicas int
param maxReplicas int
param targetPort int = 0
param externalIngress bool = false

resource app 'Microsoft.App/containerApps@2023-04-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    environmentId: environmentId
    configuration: {
      ingress: targetPort > 0 ? {
        targetPort: targetPort
        external: externalIngress
      } : null
    }
    template: {
      serviceBinds: !empty(serviceId) ? [
        {
          serviceId: serviceId
        }
      ] : null
      containers: [
        {
          name: containerName
          image: containerImage
          command: !empty(containerCommands) ? containerCommands : null
          args: !empty(containerArgs) ? containerArgs : null
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
}
