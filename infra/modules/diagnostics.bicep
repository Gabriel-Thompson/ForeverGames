param workspaceId string
param postgresName string
param keyVaultName string
param containerAppEnvironmentName string

resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' existing={name:postgresName}
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' existing={name:keyVaultName}
resource environment 'Microsoft.App/managedEnvironments@2024-03-01' existing={name:containerAppEnvironmentName}

// Azure has not published a stable diagnosticSettings API; this is the current control-plane version.
resource postgresDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'={scope:postgres name:'log-analytics' properties:{workspaceId:workspaceId logs:[{categoryGroup:'allLogs' enabled:true}] metrics:[{category:'AllMetrics' enabled:true}]}}
resource vaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'={scope:vault name:'log-analytics' properties:{workspaceId:workspaceId logs:[{category:'AuditEvent' enabled:true}] metrics:[{category:'AllMetrics' enabled:true}]}}
resource environmentDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'={scope:environment name:'log-analytics' properties:{workspaceId:workspaceId logs:[{categoryGroup:'allLogs' enabled:true}] metrics:[{category:'AllMetrics' enabled:true}]}}
