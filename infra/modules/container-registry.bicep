param environment string
param location string
param tags object
param sku string='Basic'
var registryName=take(toLower(replace('acrforevergames${environment}','-','')),50)
resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01'={name:registryName location:location tags:tags sku:{name:sku} properties:{adminUserEnabled:false anonymousPullEnabled:false publicNetworkAccess:'Enabled'}}
output id string=registry.id
output name string=registry.name
output loginServer string=registry.properties.loginServer
