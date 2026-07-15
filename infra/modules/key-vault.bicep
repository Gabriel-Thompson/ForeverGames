param environment string
param location string
param tags object
param tenantId string
param purgeProtection bool
param privateEndpointsSubnetId string
param privateDnsZoneId string
resource vault 'Microsoft.KeyVault/vaults@2023-07-01'={name:take('kv-forevergames-${environment}',24) location:location tags:tags properties:{tenantId:tenantId sku:{family:'A' name:'standard'} enableRbacAuthorization:true enablePurgeProtection:purgeProtection enableSoftDelete:true softDeleteRetentionInDays:90 publicNetworkAccess:'Disabled' networkAcls:{bypass:'AzureServices' defaultAction:'Deny'}}}
resource endpoint 'Microsoft.Network/privateEndpoints@2024-05-01'={name:'pe-${vault.name}' location:location tags:tags properties:{subnet:{id:privateEndpointsSubnetId} privateLinkServiceConnections:[{name:'vault' properties:{privateLinkServiceId:vault.id groupIds:['vault']}}]}}
resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01'={parent:endpoint name:'default' properties:{privateDnsZoneConfigs:[{name:'vault' properties:{privateDnsZoneId:privateDnsZoneId}}]}}
output id string=vault.id
output name string=vault.name
output uri string=vault.properties.vaultUri
