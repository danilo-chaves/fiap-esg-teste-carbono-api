#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export BASE_URL=${BASE_URL:-http://localhost:8080/api/v1}
exec "${MVN:-mvn}" -B test "$@"
