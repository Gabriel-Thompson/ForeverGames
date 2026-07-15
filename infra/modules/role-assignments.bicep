param acrName string
param keyVaultName string
param postgresName string
param runtimePrincipalId string
param migrationPrincipalId string

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing={name:acrName}
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' existing={name:keyVaultName}
resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' existing={name:postgresName}

resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01'={scope:acr name:guid(acr.id,runtimePrincipalId,'acrpull') properties:{principalId:runtimePrincipalId principalType:'ServicePrincipal' roleDefinitionId:subscriptionResourceId('Microsoft.Authorization/roleDefinitions','7f951dda-4ed3-4680-a7ca-43fe172d538d')}}
resource migrationAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01'={scope:acr name:guid(acr.id,migrationPrincipalId,'acrpull') properties:{principalId:migrationPrincipalId principalType:'ServicePrincipal' roleDefinitionId:subscriptionResourceId('Microsoft.Authorization/roleDefinitions','7f951dda-4ed3-4680-a7ca-43fe172d538d')}}
resource runtimeSecrets 'Microsoft.Authorization/roleAssignments@2022-04-01'={scope:vault name:guid(vault.id,runtimePrincipalId,'secrets-user') properties:{principalId:runtimePrincipalId principalType:'ServicePrincipal' roleDefinitionId:subscriptionResourceId('Microsoft.Authorization/roleDefinitions','4633458b-17de-408a-b874-0445c86b69e6')}}
resource migrationSecrets 'Microsoft.Authorization/roleAssignments@2022-04-01'={scope:vault name:guid(vault.id,migrationPrincipalId,'secrets-user') properties:{principalId:migrationPrincipalId principalType:'ServicePrincipal' roleDefinitionId:subscriptionResourceId('Microsoft.Authorization/roleDefinitions','4633458b-17de-408a-b874-0445c86b69e6')}}
resource migrationDatabase 'Microsoft.Authorization/roleAssignments@2022-04-01'={scope:postgres name:guid(postgres.id,migrationPrincipalId,'postgres-contributor') properties:{principalId:migrationPrincipalId principalType:'ServicePrincipal' roleDefinitionId:subscriptionResourceId('Microsoft.Authorization/roleDefinitions','5f2e7ae8-9b47-4f8c-ae3a-4fe89d29e279')}}
