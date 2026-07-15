param environment string
param tags object
param postgresId string
param contactEmails array = []
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'ag-forevergames-${environment}'
  location: 'global'
  tags: tags
  properties: {
    groupShortName: take('fg-${environment}', 12)
    enabled: true
    emailReceivers: [for (email, index) in contactEmails: {
      name: 'operator-${index}'
      emailAddress: email
      useCommonAlertSchema: true
    }]
  }
}
resource databaseAlerts 'Microsoft.Insights/metricAlerts@2018-03-01' = [for definition in [
  { name: 'cpu-high', metric: 'cpu_percent', threshold: 80 }
  { name: 'storage-high', metric: 'storage_percent', threshold: 80 }
  { name: 'connections-high', metric: 'active_connections', threshold: 80 }
]: {
  name: 'alert-forevergames-${environment}-db-${definition.name}'
  location: 'global'
  tags: tags
  properties: {
    description: 'Forever Games PostgreSQL ${definition.name}; tune after baseline collection.'
    severity: 2
    enabled: true
    scopes: [postgresId]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [{
        name: definition.name
        metricNamespace: 'Microsoft.DBforPostgreSQL/flexibleServers'
        metricName: definition.metric
        operator: 'GreaterThan'
        threshold: definition.threshold
        timeAggregation: 'Average'
        criterionType: 'StaticThresholdCriterion'
      }]
    }
    actions: empty(contactEmails) ? [] : [{ actionGroupId: actionGroup.id }]
  }
}]
output actionGroupId string = actionGroup.id
