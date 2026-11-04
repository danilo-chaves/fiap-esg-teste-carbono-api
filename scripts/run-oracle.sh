#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
command -v docker >/dev/null || { echo 'Docker não encontrado. Abra o Docker Desktop.' >&2; exit 1; }
docker info >/dev/null
docker compose version
STAMP=$(date +%Y%m%d-%H%M%S)
EVIDENCE="$ROOT/evidencias/oracle/$STAMP"
mkdir -p "$EVIDENCE" "$ROOT/target/oracle"
# Limpa somente os relatórios deste modo, evitando confundir uma falha de startup
# com resultados de uma execução anterior. O banco e os fontes não são apagados.
for path in cucumber-reports.html cucumber.json cucumber.xml surefire-reports; do
 if [[ -e "$ROOT/target/oracle/$path" ]]; then
  mkdir -p "$EVIDENCE/relatorios-anteriores"
  mv "$ROOT/target/oracle/$path" "$EVIDENCE/relatorios-anteriores/"
 fi
done
set +e
docker compose -f compose.oracle.yaml up --build --abort-on-container-exit --exit-code-from tests \
  2>&1 | tee "$EVIDENCE/execucao-compose.log"
RESULT=${PIPESTATUS[0]}
set -e
docker compose -f compose.oracle.yaml logs --no-color api > "$EVIDENCE/api-oracle.log" 2>&1 || true
docker compose -f compose.oracle.yaml ps -a > "$EVIDENCE/containers.txt" 2>&1 || true
docker compose -f compose.oracle.yaml images > "$EVIDENCE/imagens.txt" 2>&1 || true
for path in cucumber-reports.html cucumber.json cucumber.xml surefire-reports; do
 if [[ -e "$ROOT/target/oracle/$path" ]]; then
  cp -R "$ROOT/target/oracle/$path" "$EVIDENCE/"
 fi
done
printf 'data=%s\nmodo=Oracle Docker\ncompose_exit_code=%s\n' "$(date -Iseconds)" "$RESULT" > "$EVIDENCE/resultado.txt"
echo "Evidências: $EVIDENCE"
echo 'Para remover os contêineres, mantendo o banco: docker compose -f compose.oracle.yaml down'
if [[ "$RESULT" == 0 && ! -f "$EVIDENCE/cucumber.xml" ]]; then
 echo 'Compose terminou sem relatório de testes; execução não confirmada.' >&2
 exit 1
fi
exit "$RESULT"
