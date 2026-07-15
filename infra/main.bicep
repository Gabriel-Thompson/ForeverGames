targetScope='subscription'

@allowed(['dev','staging','prod']) param environment string
param location string='centralus'
param resourceGroupName string='rg-forevergames-${environment}'
param administratorLogin string='fgadmin'
@secure() param administratorPassword string
param imageTag string
param stableRevisionName string=''
param deployApplication bool=false
param configureDns bool=false
param dnsZoneResourceGroup string=''
param dnsZoneName string='myforevergames.com'
param dnsVerificationId string=''
param budgetAmount int=100
param budgetStartDate string
param budgetContactEmails array=[]
param tags object={application:'forever-games' environment:environment managedBy:'bicep'}

module rg 'modules/resource-group.bicep'={name:'resource-group' params:{name:resourceGroupName location:location tags:tags}}

module network 'modules/network.bicep'={scope:resourceGroup(resourceGroupName) name:'network' dependsOn:[rg] params:{name:'vnet-forevergames-${environment}' location:location tags:tags addressSpace:'10.20.0.0/16' containerAppsSubnetPrefix:'10.20.0.0/23' postgresSubnetPrefix:'10.20.2.0/24' privateEndpointsSubnetPrefix:'10.20.3.0/24'}}
module dnsPrivate 'modules/private-dns.bicep'={scope:resourceGroup(resourceGroupName) name:'private-dns' dependsOn:[rg] params:{vnetId:network.outputs.id environment:environment}}
module identities 'modules/managed-identities.bicep'={scope:resourceGroup(resourceGroupName) name:'identities' dependsOn:[rg] params:{environment:environment location:location tags:tags}}
module registry 'modules/container-registry.bicep'={scope:resourceGroup(resourceGroupName) name:'registry' dependsOn:[rg] params:{environment:environment location:location tags:tags}}
module monitoring 'modules/monitoring.bicep'={scope:resourceGroup(resourceGroupName) name:'monitoring' dependsOn:[rg] params:{environment:environment location:location tags:tags retentionDays:30}}
module vault 'modules/key-vault.bicep'={scope:resourceGroup(resourceGroupName) name:'vault' dependsOn:[rg] params:{environment:environment location:location tags:tags tenantId:tenant().tenantId purgeProtection:environment=='prod' privateEndpointsSubnetId:network.outputs.privateEndpointsSubnetId privateDnsZoneId:dnsPrivate.outputs.vaultZoneId}}
module postgres 'modules/postgresql.bicep'={scope:resourceGroup(resourceGroupName) name:'postgres' dependsOn:[rg] params:{environment:environment location:location tags:tags delegatedSubnetId:network.outputs.postgresSubnetId privateDnsZoneId:dnsPrivate.outputs.postgresZoneId administratorLogin:administratorLogin administratorPassword:administratorPassword}}
module alerts 'modules/alerts.bicep'={scope:resourceGroup(resourceGroupName) name:'alerts' dependsOn:[rg] params:{environment:environment location:location tags:tags postgresId:postgres.outputs.id contactEmails:budgetContactEmails}}
module appEnvironment 'modules/container-app-environment.bicep'={scope:resourceGroup(resourceGroupName) name:'container-app-environment' dependsOn:[rg] params:{environment:environment location:location tags:tags infrastructureSubnetId:network.outputs.containerAppsSubnetId workspaceCustomerId:monitoring.outputs.workspaceCustomerId workspaceSharedKey:monitoring.outputs.workspaceSharedKey}}
module diagnostics 'modules/diagnostics.bicep'={scope:resourceGroup(resourceGroupName) name:'diagnostics' dependsOn:[appEnvironment,postgres,vault] params:{workspaceId:monitoring.outputs.workspaceId postgresName:postgres.outputs.name keyVaultName:vault.outputs.name containerAppEnvironmentName:appEnvironment.outputs.name}}
module roles 'modules/role-assignments.bicep'={scope:resourceGroup(resourceGroupName) name:'roles' dependsOn:[rg] params:{acrName:registry.outputs.name keyVaultName:vault.outputs.name postgresName:postgres.outputs.name runtimePrincipalId:identities.outputs.runtimePrincipalId migrationPrincipalId:identities.outputs.migrationPrincipalId}}
module migrationJob 'modules/migration-job.bicep'={scope:resourceGroup(resourceGroupName) name:'migration-job' dependsOn:[roles] params:{environment:environment location:location tags:tags environmentId:appEnvironment.outputs.id image:'${registry.outputs.loginServer}/forever-games-migrations:${imageTag}' registryServer:registry.outputs.loginServer keyVaultUri:vault.outputs.uri migrationIdentityId:identities.outputs.migrationIdentityId}}
module app 'modules/container-app.bicep'=if(deployApplication){scope:resourceGroup(resourceGroupName) name:'application' dependsOn:[roles] params:{environment:environment location:location tags:tags environmentId:appEnvironment.outputs.id image:'${registry.outputs.loginServer}/forever-games-web:${imageTag}' registryServer:registry.outputs.loginServer keyVaultUri:vault.outputs.uri runtimeIdentityId:identities.outputs.runtimeIdentityId stableRevisionName:stableRevisionName minReplicas:0 maxReplicas:3}}
module publicDns 'modules/dns.bicep'=if(deployApplication&&configureDns){scope:resourceGroup(dnsZoneResourceGroup) name:'public-dns' params:{zoneName:dnsZoneName containerAppFqdn:app.outputs.fqdn verificationId:dnsVerificationId}}
module budget 'modules/budget.bicep'={name:'budget' params:{budgetName:'budget-forevergames-${environment}' amount:budgetAmount startDate:budgetStartDate contactEmails:budgetContactEmails}}

output resourceGroupName string=resourceGroupName
output registryName string=registry.outputs.name
output registryLoginServer string=registry.outputs.loginServer
output keyVaultName string=vault.outputs.name
output postgresServerName string=postgres.outputs.name
output migrationIdentityClientId string=identities.outputs.migrationClientId
output runtimeIdentityClientId string=identities.outputs.runtimeClientId
output containerAppName string=deployApplication?app.outputs.name:''
output containerAppFqdn string=deployApplication?app.outputs.fqdn:''
output migrationJobName string=migrationJob.outputs.name
