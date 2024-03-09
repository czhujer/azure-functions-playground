@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

@description('Provide a unique name of your Azure Container App')
param acaName string = 'aca-${uniqueString(resourceGroup().id)}-generated'

var acrPullRoleDefinitionId = '/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: acaName
  location: location
}

resource roleAssignmentContainerRegistry 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(identity.id, acrResource.id, acrPullRoleDefinitionId)
  scope: acrResource 
  properties: {
    principalId: identity.properties.principalId
    roleDefinitionId: acrPullRoleDefinitionId
  }
}

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: '${toLower(acaName)}-environment'
  location: location
  properties: {
    // appLogsConfiguration: {
    //   destination: 'log-analytics'
    //   logAnalyticsConfiguration: {
    //     customerId: logAnalytics.properties.customerId
    //     sharedKey: listKeys(logAnalytics.id, '2021-12-01-preview').primarySharedKey
    //   }
    // }
    //  vnetConfiguration: {
    //   internal: false
    //   infrastructureSubnetId: virtualNetwork.properties.subnets[0].id
    //  }
  }
}

resource acaResource 'Microsoft.App/containerApps@2023-05-01' = {
  location: location
  name: acaName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: environment.id
    template: {
      containers: [
        {
          image: 'packetapmtest1.azurecr.io/azure-functions-aca-example1:latest'
          name: 'app'
          probes: [
            {
              httpGet: {
                port: 80
              }
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: []
      }
    }
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 80
      }
      registries: [
        {
          server: '${acrResource.name}.azurecr.io'
          identity: identity.id
        }
      ]
    }
  }
}
