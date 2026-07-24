targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Environment name used for deterministic resource naming.')
param environmentName string

@minLength(1)
@description('Azure region for all resources.')
param location string

@description('Object ID of the deploying identity. AZD provides this as AZURE_PRINCIPAL_ID.')
param principalId string = ''

@description('Type of the deploying identity. AZD provides this as AZURE_PRINCIPAL_TYPE.')
@allowed([
  'User'
  'ServicePrincipal'
])
param principalType string = 'User'

@description('AI account product kind. Use AIServices for Microsoft Foundry accounts, OpenAI for Azure OpenAI Service accounts.')
@allowed([
  'AIServices'
  'OpenAI'
])
param aiAccountKind string = 'AIServices'

@description('Optional AI account name. Leave empty to auto-generate.')
param aiAccountName string = ''

@description('SKU for the AI account.')
@allowed([
  'S0'
])
param aiAccountSku string = 'S0'

@description('Model deployment name.')
param modelDeploymentName string = 'gpt-5.4'

@description('Model name for the deployment.')
param modelName string = 'gpt-5.4'

@description('Model version for the deployment.')
param modelVersion string = '2026-03-05'

@description('Model publisher/format for the deployment.')
param modelFormat string = 'OpenAI'

@description('Model deployment SKU.')
param modelSkuName string = 'GlobalStandard'

@description('Model deployment capacity in thousands of TPM.')
@minValue(1)
param modelCapacity int = 50

@description('Enable the token-governance sample resources (APIM, App Service, and ledger). Keep false to avoid APIM costs.')
param enableTokenUsageSample bool = false

@description('Publisher email required by API Management when sample deployment is enabled.')
param tokenUsagePublisherEmail string = 'noreply@contoso.com'

@minValue(1)
@description('Monthly token quota for the APIM-native and APIM-only approaches.')
param simpleTokenQuota int = 600

@minValue(1)
@description('Monthly token quota for the strict authoritative-ledger approach.')
param strictTokenQuota int = 600

@minValue(1)
@description('Worst-case token reservation for each strict request.')
param strictReservationTokens int = 256

@minValue(1)
@description('Maximum completion tokens accepted by the strict endpoint.')
param strictMaxOutputTokens int = 64

@minValue(1)
@description('Safety padding reserved for model framing tokens.')
param strictSafetyPaddingTokens int = 64

@description('Log Analytics retention days used by sample reporting.')
@minValue(30)
param logAnalyticsRetentionInDays int = 30

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var accountName = !empty(aiAccountName) ? aiAccountName : '${abbrs.cognitiveServicesAccounts}${resourceToken}'
var tags = {
  'azd-env-name': environmentName
}

resource aiAccount 'Microsoft.CognitiveServices/accounts@2026-05-01' = {
  name: accountName
  location: location
  tags: tags
  kind: aiAccountKind
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: aiAccountSku
  }
  properties: union(
    {
      customSubDomainName: accountName
      publicNetworkAccess: 'Enabled'
    },
    aiAccountKind == 'AIServices' ? {
      allowProjectManagement: true
    } : {}
  )
}

resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2026-05-01' = {
  parent: aiAccount
  name: modelDeploymentName
  sku: {
    name: modelSkuName
    capacity: modelCapacity
  }
  properties: {
    model: {
      format: modelFormat
      name: modelName
      version: modelVersion
    }
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2026-03-01' = if (enableTokenUsageSample) {
  name: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: logAnalyticsRetentionInDays
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = if (enableTokenUsageSample) {
  name: '${abbrs.insightsComponents}${resourceToken}'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

// Role: Cognitive Services OpenAI User
resource principalOpenAiUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(principalId)) {
  scope: aiAccount
  name: guid(aiAccount.id, principalId, '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
  }
}

module tokenUsage 'token-usage.bicep' = if (enableTokenUsageSample) {
  name: 'token-usage'
  params: {
    location: location
    tags: tags
    resourceToken: resourceToken
    cognitiveServicesName: aiAccount.name
    modelDeploymentName: modelDeployment.name
    logAnalyticsWorkspaceName: logAnalytics!.name
    applicationInsightsName: applicationInsights!.name
    publisherEmail: tokenUsagePublisherEmail
    simpleTokenQuota: simpleTokenQuota
    strictTokenQuota: strictTokenQuota
    strictReservationTokens: strictReservationTokens
    strictMaxOutputTokens: strictMaxOutputTokens
    strictSafetyPaddingTokens: strictSafetyPaddingTokens
  }
}

output AI_ACCOUNT_KIND string = aiAccountKind
output AZURE_TENANT_ID string = tenant().tenantId
output COGNITIVE_SERVICES_NAME string = aiAccount.name
output COGNITIVE_SERVICES_ENDPOINT string = aiAccount.properties.endpoint
output MODEL_DEPLOYMENT_NAME string = modelDeployment.name
output APPLICATION_INSIGHTS_NAME string = enableTokenUsageSample ? applicationInsights!.name : ''
output LOG_ANALYTICS_WORKSPACE_NAME string = enableTokenUsageSample ? logAnalytics!.name : ''
output API_MANAGEMENT_NAME string = enableTokenUsageSample ? tokenUsage!.outputs.API_MANAGEMENT_NAME : ''
output APIM_GATEWAY_URL string = enableTokenUsageSample ? tokenUsage!.outputs.APIM_GATEWAY_URL : ''
output TOKEN_USAGE_APIM_API_NAME string = enableTokenUsageSample ? tokenUsage!.outputs.TOKEN_USAGE_APIM_API_NAME : ''
output TOKEN_USAGE_API_NAME string = enableTokenUsageSample ? tokenUsage!.outputs.TOKEN_USAGE_API_NAME : ''
output TOKEN_USAGE_API_URL string = enableTokenUsageSample ? tokenUsage!.outputs.TOKEN_USAGE_API_URL : ''
output TOKEN_USAGE_SUBSCRIPTION_NAME string = enableTokenUsageSample ? tokenUsage!.outputs.TOKEN_USAGE_SUBSCRIPTION_NAME : ''
output TOKEN_USAGE_STRICT_RESERVATION_TOKENS int = enableTokenUsageSample ? tokenUsage!.outputs.TOKEN_USAGE_STRICT_RESERVATION_TOKENS : 0
