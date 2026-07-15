#!/usr/bin/env bash
set -euo pipefail
: "${ENVIRONMENT:?Set ENVIRONMENT to dev, staging, or prod}"
: "${POSTGRES_ADMIN_PASSWORD:?Set POSTGRES_ADMIN_PASSWORD without printing it}"
PARAM_FILE="infra/parameters/${ENVIRONMENT}.bicepparam"
test -f "$PARAM_FILE"
az deployment sub create --name "forevergames-${ENVIRONMENT}-bootstrap" --location centralus --template-file infra/main.bicep --parameters "$PARAM_FILE" deployApplication=false
echo 'Base infrastructure created. Populate Key Vault from a private-network-connected operator before deploying the app.'
