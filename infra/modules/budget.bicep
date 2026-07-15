targetScope = 'subscription'
param budgetName string
param amount int
param startDate string
param contactEmails array = []
resource budget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: budgetName
  properties: {
    amount: amount
    timeGrain: 'Monthly'
    timePeriod: { startDate: startDate }
    category: 'Cost'
    notifications: {
      actual80: { enabled: true, operator: 'GreaterThan', threshold: 80, thresholdType: 'Actual', contactEmails: contactEmails }
      forecast100: { enabled: true, operator: 'GreaterThan', threshold: 100, thresholdType: 'Forecasted', contactEmails: contactEmails }
    }
  }
}
