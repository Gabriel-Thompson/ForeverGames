#!/usr/bin/env bash
set -euo pipefail
: "${RESOURCE_GROUP:?Set RESOURCE_GROUP}"
: "${POSTGRES_SERVER:?Set POSTGRES_SERVER}"
: "${RESTORE_NAME:?Set RESTORE_NAME to a disposable server name}"
: "${RESTORE_TIME:?Set RESTORE_TIME in UTC ISO-8601 format}"
az postgres flexible-server restore --resource-group "$RESOURCE_GROUP" --name "$RESTORE_NAME" --source-server "$POSTGRES_SERVER" --restore-time "$RESTORE_TIME"
echo 'Restore server created. Validate data, record RPO/RTO, then delete it through an approved change.'
