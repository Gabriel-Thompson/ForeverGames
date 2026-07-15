param name string
param location string
param tags object
param addressSpace string
param containerAppsSubnetPrefix string
param postgresSubnetPrefix string
param privateEndpointsSubnetPrefix string
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: { addressPrefixes: [addressSpace] }
    subnets: [
      {
        name: 'snet-containerapps'
        properties: {
          addressPrefix: containerAppsSubnetPrefix
          delegations: [{ name: 'container-apps', properties: { serviceName: 'Microsoft.App/environments' } }]
        }
      }
      {
        name: 'snet-postgresql'
        properties: {
          addressPrefix: postgresSubnetPrefix
          delegations: [{ name: 'postgres-flexible', properties: { serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers' } }]
        }
      }
      {
        name: 'snet-private-endpoints'
        properties: {
          addressPrefix: privateEndpointsSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}
output id string = vnet.id
output containerAppsSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', name, 'snet-containerapps')
output postgresSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', name, 'snet-postgresql')
output privateEndpointsSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', name, 'snet-private-endpoints')
