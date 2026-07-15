param environment string
param location string
param tags object
param environmentId string
param image string
param registryServer string
param keyVaultUri string
param migrationIdentityId string
resource job 'Microsoft.App/jobs@2024-03-01' = {
  name: 'caj-forevergames-${environment}-migrate'
  location: location
  tags: tags
  identity: { type: 'SystemAssigned, UserAssigned', userAssignedIdentities: { '${migrationIdentityId}': {} } }
  properties: {
    environmentId: environmentId
    configuration: {
      triggerType: 'Manual'
      replicaTimeout: 1800
      replicaRetryLimit: 0
      registries: [{ server: registryServer, identity: migrationIdentityId }]
      secrets: [{ name: 'direct-url', keyVaultUrl: '${keyVaultUri}secrets/DIRECT-URL', identity: migrationIdentityId }]
    }
    template: {
      containers: [{
        name: 'migration'
        image: image
        command: ['node', 'scripts/migrate-deploy.mjs']
        env: [{ name: 'NODE_ENV', value: 'production' }, { name: 'DIRECT_URL', secretRef: 'direct-url' }]
        resources: { cpu: json('0.5'), memory: '1Gi' }
      }]
    }
  }
}
output name string = job.name
output id string = job.id
