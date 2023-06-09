targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

param appEnvironmentName string = 'aca-env'
param kafkaSvcName string = 'kafka01'
param kafkaCliAppName string = 'kafka-cli-app'
param kafkaUiAppName string = 'kafka-ui'

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module appEnvironment './core/host/container-apps-environment.bicep' = {
  name: 'appEnvironment'
  scope: rg
  params: {
    name: appEnvironmentName
    location: location
    tags: tags
  }
}

module kafka './core/host/container-app-service.bicep' = {
  name: 'kafka'
  scope: rg
  params: {
    name: kafkaSvcName
    location: location
    tags: tags
    environmentId: appEnvironment.outputs.appEnvironmentId
    serviceType: 'kafka'
  }
}

module kafkaCli './core/host/container-app.bicep' = {
  name: 'kafkaCli'
  scope: rg
  params: {
    name: kafkaCliAppName
    location: location
    tags: tags
    environmentId: appEnvironment.outputs.appEnvironmentId
    serviceId: kafka.outputs.serviceId
    containerImage: 'mcr.microsoft.com/k8se/services/kafka:3.4'
    containerName: 'kafka-cli'
    maxReplicas: 1
    minReplicas: 1
    containerCommands: [ '/bin/sleep', 'infinity' ]
  }
}

module kafkaUi './core/host/container-app.bicep' = {
  name: 'kafka-ui'
  scope: rg
  params: {
    name: kafkaUiAppName
    location: location
    tags: tags
    environmentId: appEnvironment.outputs.appEnvironmentId
    serviceId: kafka.outputs.serviceId
    containerImage: 'docker.io/provectuslabs/kafka-ui:latest'
    containerName: 'kafka-ui'
    maxReplicas: 1
    minReplicas: 1
    containerCommands: [ '/bin/sh' ]
    containerArgs: [ 
      '-c'
      '''export KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS="$KAFKA_BOOTSTRAP_SERVERS" && \
      export KAFKA_CLUSTERS_0_PROPERTIES_SASL_JAAS_CONFIG="$KAFKA_PROPERTIES_SASL_JAAS_CONFIG" && \
      export KAFKA_CLUSTERS_0_PROPERTIES_SASL_MECHANISM="$KAFKA_SASL_MECHANISM" && \
      export KAFKA_CLUSTERS_0_PROPERTIES_SECURITY_PROTOCOL="$KAFKA_SECURITY_PROTOCOL" && \
      java $JAVA_OPTS -jar kafka-ui-api.jar'''
    ]
    targetPort: 8080
    externalIngress: true
  }
}

output KAFKA_UI_URL string = kafkaUi.outputs.url
