#!/usr/bin/env bash
set -euo pipefail
mkdir -p /tests/runtime-oracle
CP="/api/target/classes:$(tr -d '\r\n' < /api/classpath.txt)"
javac -proc:none -encoding UTF-8 -cp "$CP" -d /tests/runtime-oracle /config/OracleBddBootstrap.java
java -cp "/tests/runtime-oracle:$CP" OracleBddBootstrap
exec java -cp "$CP" br.com.fiap.carbonoapi.CarbonoApiApplication \
  --spring.config.additional-location=file:/config/application-bdd-oracle.yaml
