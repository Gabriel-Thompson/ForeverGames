param environment string
param location string
param tags object
param infrastructureSubnetId string
param workspaceCustomerId string
@secure() param workspaceSharedKey string
resource cae 'Microsoft.App/managedEnvironments@2024-03-01'={name:'cae-forevergames-${environment}' location:location tags:tags properties:{vnetConfiguration:{infrastructureSubnetId:infrastructureSubnetId internal:false} appLogsConfiguration:{destination:'log-analytics' logAnalyticsConfiguration:{customerId:workspaceCustomerId sharedKey:workspaceSharedKey}} zoneRedundant:false}}
output id string=cae.id
output name string=cae.name
output defaultDomain string=cae.properties.defaultDomain
