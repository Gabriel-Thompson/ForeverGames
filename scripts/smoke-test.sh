#!/usr/bin/env bash
set -euo pipefail
: "${BASE_URL:?Set BASE_URL to the HTTPS application origin}"
curl --fail --silent --show-error --retry 6 --retry-delay 5 "${BASE_URL%/}/health/live" >/dev/null
curl --fail --silent --show-error --retry 6 --retry-delay 5 "${BASE_URL%/}/health/ready" >/dev/null
echo 'Liveness and readiness smoke tests passed.'
