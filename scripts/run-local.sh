#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
mkdir -p "$ROOT/target"
# Recusa reutilizar uma API que já esteja na porta, evitando testar a instância errada.
if curl -s --connect-timeout 2 --max-time 3 http://localhost:8080/api/v1/auth/login >/dev/null; then
 echo 'Porta 8080 já ocupada. Encerre o serviço ou use scripts/test.sh com BASE_URL.' >&2; exit 1
fi
bash "$ROOT/scripts/start-api.sh" > "$ROOT/target/api.log" 2>&1 &
API_PID=$!
trap 'kill "$API_PID" 2>/dev/null || true; wait "$API_PID" 2>/dev/null || true' EXIT
READY=0
for ((i=0;i<900;i++)); do
 if ! kill -0 "$API_PID" 2>/dev/null; then cat "$ROOT/target/api.log"; exit 1; fi
 CODE=$(curl -s -o /dev/null -w '%{http_code}' --max-time 2 -H 'Content-Type: application/json' -d '{}' http://localhost:8080/api/v1/auth/login || true)
 if [[ "$CODE" == 400 ]]; then READY=1; break; fi
 sleep 2
done
if [[ "$READY" != 1 ]]; then tail -80 "$ROOT/target/api.log"; exit 1; fi
BASE_URL=http://localhost:8080/api/v1 bash "$ROOT/scripts/test.sh" "$@"
