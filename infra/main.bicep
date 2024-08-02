targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@minLength(1)
@maxLength(64)
@description('FunctionApp Name')
param appName string

@description('Azure OpenAI Endpoint')
param azureOpenAIEndpoint string

@description('Azure OpenAI Key')
@secure()
param azureOpenAIKey string = ''

@description('Chat Model Deployment Name')
param chatModelDeploymentName string

var functionAppName = '${abbrs.webSitesFunctions}${appName}${resourceToken}'
var storageAccountName = '${abbrs.storageStorageAccounts}${toLower(substring(appName, 0, min(length(appName), 9)))}${resourceToken}'

var tags = {
  'azd-env-name': environmentName
}

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module servicePlan 'core/host/appserviceplan.bicep' = {
  scope: rg
  name: 'appserviceplan'
  params: {
    name: '${abbrs.webServerFarms}${appName}${resourceToken}'
    location: location
    sku: {
      name: 'Y1'
      tier: 'Dynamic'
    }
    tags: tags
  }
}

module storageAccount 'core/storage/storage-account.bicep' = {
  scope: rg
  name: 'storageaccount'
  params: {
    name: storageAccountName
    location: location
    tags: tags
  }
}


module logAnalytics 'core/monitor/loganalytics.bicep' = {
  scope: rg
  name: 'loganalytics'
  params: {
    name: '${abbrs.analysisServicesServers}${appName}${resourceToken}'
    location: location
    tags: tags
  }
}

module applicationInsights 'core/monitor/applicationinsights.bicep' = {
  scope: rg
  name: 'applicationinsights'
  params: {
    name: '${abbrs.insightsComponents}${appName}${resourceToken}'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
    dashboardName: appName
  }
}

module functionApp 'core/host/functions.bicep' = {
  name: 'functionApp'
  scope: rg
  params: {
    name: functionAppName
    location: location
    alwaysOn: false
    appServicePlanId: servicePlan.outputs.id
    runtimeName: 'dotnet-isolated'
    extensionVersion:'~4'
    storageAccountName: storageAccount.outputs.name
    applicationInsightsName:  applicationInsights.outputs.name
    tags: union(tags, { 'azd-service-name': 'api' })
    managedIdentity: true 
    appSettings:{
      WEBSITE_RUN_FROM_PACKAGE: 1
      AZURE_OPENAI_ENDPOINT: azureOpenAIEndpoint
      AZURE_OPENAI_KEY: azureOpenAIKey
      CHAT_MODEL_DEPLOYMENT_NAME: chatModelDeploymentName
    }
  }
  dependsOn: [
    servicePlan
    storageAccount
    applicationInsights
  ]
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_FUNCTIONAPP_URI string = functionApp.outputs.uri
output STORAGE_ACCOUNT_NAME string = storageAccountName 
