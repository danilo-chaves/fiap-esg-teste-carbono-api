#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
API_DIR=$(cd "${CARBONO_API_DIR:-$ROOT/../carbono-api}" && pwd)
MVN=${MVN:-mvn}
mkdir -p "$ROOT/target/runtime"
# Compila os fontes originais; somente target/ da base recebe artefatos de build.
"$MVN" -B -f "$API_DIR/pom.xml" -DskipTests package
"$MVN" -B -f "$API_DIR/pom.xml" dependency:build-classpath -DincludeScope=test "-Dmdep.outputFile=$ROOT/target/runtime/classpath.txt"

# Maven escreve o classpath no formato do SO da JVM. No Git Bash, a JVM
# e nativa do Windows: exige ';' e caminhos Windows, inclusive em pastas com espacos.
CP_SEPARATOR=':'
WINDOWS_JAVA=0
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    command -v cygpath >/dev/null || { echo 'cygpath nao encontrado; execute pelo Git Bash.' >&2; exit 1; }
    CP_SEPARATOR=';'
    WINDOWS_JAVA=1
    ;;
esac
native_path() {
  if [[ "$WINDOWS_JAVA" == 1 ]]; then cygpath -am "$1"; else printf '%s\n' "$1"; fi
}
CLASSES_NATIVE=$(native_path "$API_DIR/target/classes")
RUNTIME_NATIVE=$(native_path "$ROOT/target/runtime")
SEED_NATIVE=$(native_path "$ROOT/config/SeedGenerator.java")
DEPENDENCIES_CP=$(tr -d '\r\n' < "$ROOT/target/runtime/classpath.txt")
CP="${CLASSES_NATIVE}${CP_SEPARATOR}${DEPENDENCIES_CP}"

MAIN_CLASS_FILE="$API_DIR/target/classes/br/com/fiap/carbonoapi/CarbonoApiApplication.class"
if [[ ! -f "$MAIN_CLASS_FILE" ]]; then
  echo "Classe principal nao encontrada apos o build: $MAIN_CLASS_FILE" >&2
  exit 1
fi
cp "$ROOT/config/application-bdd.yaml" "$ROOT/target/runtime/application-bdd.yaml"
export BDD_CONFIG_DIR="$RUNTIME_NATIVE"
if [[ "$WINDOWS_JAVA" == 1 ]]; then
  # Todos os argumentos Java abaixo ja usam caminhos nativos. Impede que o
  # Git Bash reconverta o classpath misto ou o argumento file:C:/... do Spring.
  export MSYS2_ARG_CONV_EXCL='*'
  export MSYS2_ENV_CONV_EXCL="${MSYS2_ENV_CONV_EXCL:+${MSYS2_ENV_CONV_EXCL};}BDD_CONFIG_DIR"
fi
javac -proc:none -cp "$CP" -d "$RUNTIME_NATIVE" "$SEED_NATIVE"
java -cp "${RUNTIME_NATIVE}${CP_SEPARATOR}${CP}" SeedGenerator > "$ROOT/target/runtime/data-bdd.sql"
exec java -cp "$CP" br.com.fiap.carbonoapi.CarbonoApiApplication \
  "--spring.config.additional-location=file:$RUNTIME_NATIVE/application-bdd.yaml"
