$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
if (!$env:BASE_URL) { $env:BASE_URL = "http://localhost:8080/api/v1" }
mvn -B test @args
exit $LASTEXITCODE
