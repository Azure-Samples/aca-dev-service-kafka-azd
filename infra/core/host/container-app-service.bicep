param name string
param location string = resourceGroup().location
param tags object = {}
param environmentId string
param serviceType string


resource service 'Microsoft.App/containerApps@2023-04-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    environmentId: environmentId
    configuration: {
      service: {
          type: serviceType
      }
    }
  }
}

output serviceId string = service.id
