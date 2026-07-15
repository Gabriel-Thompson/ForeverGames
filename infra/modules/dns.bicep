param zoneName string
param containerAppFqdn string
param verificationId string=''
resource zone 'Microsoft.Network/dnsZones@2018-05-01' existing={name:zoneName}
resource apex 'Microsoft.Network/dnsZones/CNAME@2018-05-01'={parent:zone name:'@' properties:{TTL:300 CNAMERecord:{cname:containerAppFqdn}}}
resource www 'Microsoft.Network/dnsZones/CNAME@2018-05-01'={parent:zone name:'www' properties:{TTL:300 CNAMERecord:{cname:containerAppFqdn}}}
resource verification 'Microsoft.Network/dnsZones/TXT@2018-05-01'=if(!empty(verificationId)){parent:zone name:'asuid' properties:{TTL:300 TXTRecords:[{value:[verificationId]}]}}
