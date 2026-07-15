param environment string
param location string
param tags object
resource migration 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31'={name:'id-forevergames-${environment}-migration' location:location tags:tags}
resource runtime 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31'={name:'id-forevergames-${environment}-runtime' location:location tags:tags}
output migrationIdentityId string=migration.id
output migrationPrincipalId string=migration.properties.principalId
output migrationClientId string=migration.properties.clientId
output runtimeIdentityId string=runtime.id
output runtimePrincipalId string=runtime.properties.principalId
