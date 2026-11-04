#!/usr/bin/env bash
set -euo pipefail
mkdir -p /tests/runtime
CP="/api/target/classes:$(cat /api/classpath.txt)"
cp /config/application-bdd.yaml /tests/runtime/application-bdd.yaml
javac -cp "$CP" -d /tests/runtime /config/SeedGenerator.java
java -cp "/tests/runtime:$CP" SeedGenerator > /tests/runtime/data-bdd.sql
export BDD_CONFIG_DIR=/tests/runtime
exec java -cp "$CP" br.com.fiap.carbonoapi.CarbonoApiApplication --spring.config.additional-location=file:/tests/runtime/application-bdd.yaml
