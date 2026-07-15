#!/usr/bin/env bash
set -euo pipefail
: "${RESOURCE_GROUP:?Set RESOURCE_GROUP}"
: "${CONTAINER_APP_NAME:?Set CONTAINER_APP_NAME}"
: "${REVISION_NAME:?Set REVISION_NAME to a previously verified revision}"
az containerapp revision activate --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_APP_NAME" --revision "$REVISION_NAME"
az containerapp ingress traffic set --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_APP_NAME" --revision-weight "${REVISION_NAME}=100"
echo "Traffic restored to ${REVISION_NAME}. Database migrations are not reversed by this script."
