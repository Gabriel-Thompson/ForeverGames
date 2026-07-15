param environment string
param location string
param tags object
param retentionDays int=30
resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01'={name:'log-forevergames-${environment}' location:location tags:tags properties:{retentionInDays:retentionDays features:{enableLogAccessUsingOnlyResourcePermissions:true}} sku:{name:'PerGB2018'}}
resource insights 'Microsoft.Insights/components@2020-02-02'={name:'appi-forevergames-${environment}' location:location kind:'web' tags:tags properties:{Application_Type:'web' WorkspaceResourceId:workspace.id IngestionMode:'LogAnalytics' publicNetworkAccessForIngestion:'Enabled' publicNetworkAccessForQuery:'Enabled'}}
output workspaceId string=workspace.id
output workspaceCustomerId string=workspace.properties.customerId
output appInsightsId string=insights.id
output connectionString string=insights.properties.ConnectionString
@secure()
output workspaceSharedKey string=workspace.listKeys().primarySharedKey
