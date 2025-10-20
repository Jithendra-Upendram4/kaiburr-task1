$ErrorActionPreference = 'Stop'
Write-Host 'Waiting up to 30s for app at http://localhost:8080/tasks...'
$timeout = 30
$start = Get-Date
while ((Get-Date) - $start -lt (New-TimeSpan -Seconds $timeout)) {
    try {
        Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:8080/tasks' -TimeoutSec 5 | Out-Null
        Write-Host 'App is responsive.'
        break
    } catch {
        Write-Host -NoNewline '.'
        Start-Sleep -Seconds 1
    }
}
if ((Get-Date) - $start -ge (New-TimeSpan -Seconds $timeout)) {
    Write-Host ''
    Write-Error 'Timed out waiting for app. Make sure the container is running and port 8080 is accessible.'
    exit 1
}
Write-Host ''

# Create the task
$body = @{ name = 'Print Hello'; owner = 'You'; command = 'echo Hello World' } | ConvertTo-Json
Write-Host 'Creating task...'
$resp = Invoke-RestMethod -Method Put -Uri 'http://localhost:8080/tasks' -ContentType 'application/json' -Body $body
Write-Host 'Created task (API response):'
$resp | ConvertTo-Json -Depth 10 | Write-Host
$taskId = $resp.id
Write-Host "Task id: $taskId"
Write-Host ''

# Execute the task
Write-Host "Executing task $taskId..."
$execResp = Invoke-RestMethod -Method Put -Uri "http://localhost:8080/tasks/$taskId/execute" -ContentType 'application/json'
Write-Host 'Execution response:'
$execResp | ConvertTo-Json -Depth 10 | Write-Host
Write-Host ''

# List tasks via API
Write-Host 'Listing tasks from API:'
$allTasks = Invoke-RestMethod -Uri 'http://localhost:8080/tasks' -Method Get -TimeoutSec 10
$allTasks | ConvertTo-Json -Depth 10 | Write-Host
Write-Host ''

# Dump Mongo tasks collection (requires docker and container name kaiburr-mongo)
Write-Host 'Dumping Mongo tasks collection (JSON):'
try {
    $mongoJSON = docker exec kaiburr-mongo mongosh --quiet --eval "JSON.stringify(db.getSiblingDB('kaiburrdb').tasks.find().toArray())" 2>&1 | Out-String
    Write-Host $mongoJSON
} catch {
    Write-Error "Failed to query Mongo inside container: $($_.Exception.Message)"
}

Write-Host 'Done.'
