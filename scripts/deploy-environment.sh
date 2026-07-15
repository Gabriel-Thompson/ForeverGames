#!/usr/bin/env bash
set -euo pipefail
: "${ENVIRONMENT:?Set ENVIRONMENT}"
: "${IMAGE_TAG:?Set IMAGE_TAG to an immutable Git SHA}"
: "${POSTGRES_ADMIN_PASSWORD:?Set POSTGRES_ADMIN_PASSWORD}"
az deployment sub create --name "forevergames-${ENVIRONMENT}-${IMAGE_TAG:0:8}" --location centralus --template-file infra/main.bicep --parameters "infra/parameters/${ENVIRONMENT}.bicepparam" imageTag="$IMAGE_TAG" deployApplication=true
