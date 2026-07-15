#!/usr/bin/env bash
set -euo pipefail
command -v az >/dev/null
az bicep build --file infra/main.bicep --stdout >/dev/null
for file in infra/parameters/*.bicepparam; do
  az bicep build-params --file "$file" --stdout >/dev/null
done
echo 'Infrastructure templates are syntactically valid.'
