<#
Automated run script for Kaiburr Task1 (PowerShell).
Usage: Open PowerShell at repository root and run: .\scripts\auto-run.ps1

This script will:
- ensure a Mongo container named 'kaiburr-mongo' is running
- build the project inside a Maven container (skip tests)
- start the app container 'kaiburr-app' with MONGODB_URI pointing to host.docker.internal
- wait for readiness, create a sample task, execute it
- save create+execute JSON to docs/ and push to origin/main
#>

param(
    [string]$MongoImage = 'mongo:6.0',
    [string]$MavenImage = 'maven:3.9.5-eclipse-temurin-21',
    [string]$AppContainer = 'kaiburr-app',
    [string]$MongoContainer = 'kaiburr-mongo'
)

Set-StrictMode -Version Latest
Push-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)/.. | Out-Null

function Ensure-ContainerRunning($name, $image, $ports) {
    $exists = docker ps -a --format "{{.Names}}" | Select-String $name -Quiet
    if (-not $exists) {
        Write-Host "Creating and starting container $name..."
        docker run -d --name $name -p $ports -v ${name}-data:/data/db $image | Out-Null
    } else {
        Write-Host "Starting existing container $name..."
        docker start $name | Out-Null
    }
}

Ensure-ContainerRunning -name $MongoContainer -image $MongoImage -ports '27017:27017'

Write-Host "Building jar inside Maven container (this may take a few minutes)..."
docker run --rm -v ${PWD}:/workspace -w /workspace $MavenImage mvn -B -U -DskipTests package

# Remove any existing app container
if (docker ps -a --format "{{.Names}}" | Select-String $AppContainer) { docker rm -f $AppContainer | Out-Null }

Write-Host "Starting application container $AppContainer..."
docker run -d --name $AppContainer -v ${PWD}:/workspace -w /workspace -p 8080:8080 -e MONGODB_URI="mongodb://host.docker.internal:27017/kaiburrdb" $MavenImage java -jar target/kaiburr-task1-0.0.1-SNAPSHOT.jar

Write-Host "Waiting for application to respond on http://localhost:8080/tasks ..."
$up = $false
for ($i=0; $i -lt 40; $i++) {
    try { Invoke-RestMethod -Uri http://localhost:8080/tasks -Method Get -TimeoutSec 2 | Out-Null; $up = $true; break } catch { Start-Sleep -Seconds 1 }
}
if (-not $up) { Write-Host 'ERROR: app did not come up in time'; exit 1 }

# Create sample task
$body = '{"name":"Print Hello","owner":"AutoScript","command":"echo Hello World"}'
$create = Invoke-RestMethod -Uri http://localhost:8080/tasks -Method Put -Body $body -ContentType 'application/json'
if (-not (Test-Path docs)) { New-Item -ItemType Directory -Path docs | Out-Null }
$create | ConvertTo-Json -Depth 10 | Set-Content -Path docs/sample_create.json -Encoding UTF8

# Execute task
$id = $create.id
$exec = Invoke-RestMethod -Uri ("http://localhost:8080/tasks/$id/execute") -Method Put
$exec | ConvertTo-Json -Depth 10 | Set-Content -Path docs/sample_execute.json -Encoding UTF8

Write-Host "Saved docs/sample_create.json and docs/sample_execute.json"

git add docs/sample_create.json docs/sample_execute.json
$staged = git diff --staged --name-only
if ($staged) { git commit -m "Add API samples: automated run"; git push origin main } else { Write-Host 'No changes to commit' }

Pop-Location | Out-Null

Write-Host "Done."
