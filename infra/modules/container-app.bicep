param environment string
param location string
param tags object
param environmentId string
param image string
param registryServer string
param keyVaultUri string
param runtimeIdentityId string
param stableRevisionName string = ''
param minReplicas int = 0
param maxReplicas int = 3
resource app 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'ca-forevergames-${environment}-web'
  location: location
  tags: tags
  identity: { type: 'SystemAssigned, UserAssigned', userAssignedIdentities: { '${runtimeIdentityId}': {} } }
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        external: true
        targetPort: 3000
        allowInsecure: false
        transport: 'auto'
        traffic: empty(stableRevisionName) ? [{ latestRevision: true, weight: 100 }] : [{ revisionName: stableRevisionName, weight: 100 }]
      }
      registries: [{ server: registryServer, identity: runtimeIdentityId }]
      secrets: [
        { name: 'database-url', keyVaultUrl: '${keyVaultUri}secrets/DATABASE-URL', identity: runtimeIdentityId }
        { name: 'direct-url', keyVaultUrl: '${keyVaultUri}secrets/DIRECT-URL', identity: runtimeIdentityId }
        { name: 'session-secret', keyVaultUrl: '${keyVaultUri}secrets/SESSION-SECRET', identity: runtimeIdentityId }
        { name: 'field-encryption-key', keyVaultUrl: '${keyVaultUri}secrets/FIELD-ENCRYPTION-KEY', identity: runtimeIdentityId }
        { name: 'steam-api-key', keyVaultUrl: '${keyVaultUri}secrets/STEAM-WEB-API-KEY', identity: runtimeIdentityId }
      ]
    }
    template: {
      revisionSuffix: take(uniqueString(image), 10)
      containers: [{
        name: 'web'
        image: image
        env: [
          { name: 'NODE_ENV', value: 'production' }
          { name: 'APP_ENV', value: environment == 'prod' ? 'production' : environment }
          { name: 'PUBLIC_BASE_URL', value: environment == 'prod' ? 'https://myforevergames.com' : 'https://${environment}.myforevergames.com' }
          { name: 'CANONICAL_DOMAIN', value: environment == 'prod' ? 'myforevergames.com' : '${environment}.myforevergames.com' }
          { name: 'DATABASE_URL', secretRef: 'database-url' }
          { name: 'DIRECT_URL', secretRef: 'direct-url' }
          { name: 'SESSION_SECRET', secretRef: 'session-secret' }
          { name: 'FIELD_ENCRYPTION_KEY', secretRef: 'field-encryption-key' }
          { name: 'STEAM_WEB_API_KEY', secretRef: 'steam-api-key' }
          { name: 'ENABLE_SYNTHETIC_FALLBACK', value: 'false' }
          { name: 'ENABLE_EVIDENCE_UPLOADS', value: 'false' }
          { name: 'ENABLE_CHECKOUT', value: 'false' }
        ]
        resources: { cpu: json('0.5'), memory: '1Gi' }
        probes: [
          { type: 'Startup', httpGet: { path: '/health/live', port: 3000, scheme: 'HTTP' }, initialDelaySeconds: 5, periodSeconds: 5, failureThreshold: 12 }
          { type: 'Liveness', httpGet: { path: '/health/live', port: 3000, scheme: 'HTTP' }, periodSeconds: 30, failureThreshold: 3 }
          { type: 'Readiness', httpGet: { path: '/health/ready', port: 3000, scheme: 'HTTP' }, periodSeconds: 10, failureThreshold: 3 }
        ]
      }]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        rules: [{ name: 'http-scaling', http: { metadata: { concurrentRequests: '50' } } }]
      }
    }
  }
}
output id string = app.id
output name string = app.name
output principalId string = app.identity.principalId
output fqdn string = app.properties.configuration.ingress.fqdn
