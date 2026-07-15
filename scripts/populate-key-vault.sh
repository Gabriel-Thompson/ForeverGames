#!/usr/bin/env bash
set -euo pipefail
: "${KEY_VAULT_NAME:?Set KEY_VAULT_NAME}"
for name in DATABASE_URL DIRECT_URL SESSION_SECRET FIELD_ENCRYPTION_KEY STEAM_WEB_API_KEY; do
  variable="${name}"
  value="${!variable:-}"
  if [[ -z "$value" ]]; then
    echo "Missing required environment variable: ${variable}" >&2
    exit 1
  fi
  secret_name="${name//_/-}"
  az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "$secret_name" --value "$value" --output none
done
echo 'Key Vault secrets populated; values were not printed.'
