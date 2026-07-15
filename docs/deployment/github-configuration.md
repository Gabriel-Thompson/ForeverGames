# Required GitHub configuration

Create `azure-plan`, `staging`, and `production` environments. Production must require reviewers, prevent self-review, and restrict deployment to protected main. Protect main with CI, infrastructure validation, review, and no force pushes.

Use federated Azure credentials. Each environment needs `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, and `POSTGRES_ADMIN_PASSWORD`. Staging currently needs scoped `ACR_PUSH_CLIENT_ID` and `ACR_PUSH_CLIENT_SECRET`; replace these with OIDC/`az acr login` when the push identity is finalized. Variables: `ACR_LOGIN_SERVER` and `CONTAINER_APP_FQDN`. Scope plan to read/what-if and deploy identities to their environment plus subscription deployment/budget permissions.

Enable secret scanning, push protection, Dependabot, and CodeQL. Never echo secrets or enable shell tracing in secret-bearing steps.
