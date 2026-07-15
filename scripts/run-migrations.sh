#!/usr/bin/env bash
set -euo pipefail
: "${RESOURCE_GROUP:?Set RESOURCE_GROUP}"
: "${MIGRATION_JOB_NAME:?Set MIGRATION_JOB_NAME}"
execution="$(az containerapp job start --resource-group "$RESOURCE_GROUP" --name "$MIGRATION_JOB_NAME" --query name -o tsv)"
for _ in {1..60}; do
  status="$(az containerapp job execution show --resource-group "$RESOURCE_GROUP" --name "$MIGRATION_JOB_NAME" --job-execution-name "$execution" --query properties.status -o tsv)"
  case "$status" in
    Succeeded) echo 'Migration completed.'; exit 0 ;;
    Failed) echo 'Migration failed.' >&2; exit 1 ;;
  esac
  sleep 10
done
echo 'Migration timed out.' >&2
exit 1
