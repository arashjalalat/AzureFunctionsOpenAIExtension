metadata description = 'Create AI accounts.'

param accountName string
param location string = resourceGroup().location
param tags object = {}

@description('Sets the kind of account.')
param kind string = 'OpenAI'

@allowed([
  'S0'
])
@description('SKU for the account. Defaults to "S0".')
param sku string = 'S0'

@description('Enables access from public networks. Defaults to true.')
param enablePublicNetworkAccess bool = true

@description('Name of the SKU for the deployment. Defaults to "Standard".')
param skuName string = 'Standard'

@description('Format of the model to use in the deployment.')
param modelFormat string

var deployments = [
  {
    name: 'gpt-4o-mini'
    skuCapacity: 10
    modelName: 'gpt-4o-mini'
    modelVersion: '2024-07-18'
  }
]

resource openAiAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: accountName
  location: location
  tags: tags
  kind: kind
  sku: {
    name: sku
  }
  properties: {
    customSubDomainName: accountName
    publicNetworkAccess: enablePublicNetworkAccess ? 'Enabled' : 'Disabled'
  }
}

@batchSize(1)
resource openAiModelDeployments 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  parent: openAiAccount
  name: deployment.name
  sku: {
    name: skuName
    capacity: deployment.skuCapacity
  }
  properties: {
    model: {
      name: deployment.modelName
      format: modelFormat
      version: deployment.modelVersion
    }
  }
}]

output name string = openAiAccount.name
output endpoint string = openAiAccount.properties.endpoint
output deployments array = [
  for deployment in range(0, length(deployments)): {
    name: deployments[deployment].name
  }
]
