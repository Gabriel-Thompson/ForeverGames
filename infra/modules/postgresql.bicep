param environment string
param location string
param tags object
param delegatedSubnetId string
param privateDnsZoneId string
param administratorLogin string
@secure()
param administratorPassword string
param postgresVersion string = '16'
param skuName string = 'Standard_B1ms'
param storageSizeGB int = 32
param backupRetentionDays int = 7
resource server 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  name: take('psql-forevergames-${environment}', 63)
  location: location
  tags: tags
  sku: { name: skuName, tier: 'Burstable' }
  properties: {
    version: postgresVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    network: {
      delegatedSubnetResourceId: delegatedSubnetId
      privateDnsZoneArmResourceId: privateDnsZoneId
      publicNetworkAccess: 'Disabled'
    }
    storage: { storageSizeGB: storageSizeGB, autoGrow: 'Enabled' }
    backup: { backupRetentionDays: backupRetentionDays, geoRedundantBackup: 'Disabled' }
    highAvailability: { mode: 'Disabled' }
    authConfig: { activeDirectoryAuth: 'Enabled', passwordAuth: 'Enabled' }
    dataEncryption: { type: 'SystemManaged' }
  }
}
resource ssl 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2024-08-01' = {
  parent: server
  name: 'require_secure_transport'
  properties: { value: 'on', source: 'user-override' }
}
output id string = server.id
output name string = server.name
output fqdn string = server.properties.fullyQualifiedDomainName
