# Build the project using the official Maven Docker image (includes JDK)
# Usage: .\build-with-docker-maven.ps1

$ErrorActionPreference = 'Stop'
$workspace = (Get-Location).Path
Write-Host "Building project in: $workspace"

# Use a Maven image that bundles Temurin 21
$image = 'maven:3.9.5-eclipse-temurin-21'

# Pull and run Maven to build the project
Write-Host "Running Docker image $image to build... (this may pull the image)"
# Construct a Windows-friendly volume mapping for Docker (escape drive letter)
# e.g. D:\path -> /host_mnt/d/path inside Docker on Docker Desktop; but simpler is to use absolute path with double quotes
# Ensure Windows backslashes are OK for mounting; Docker Desktop accepts Windows paths directly when quoted
$volume = "${workspace}:/workspace"
Write-Host "Mounting host path: $workspace as /workspace in container"

# Execute docker run
$args = @('run','--rm','-v',$volume,'-w','/workspace',$image,'mvn','-DskipTests','clean','package')
Write-Host "docker $($args -join ' ')"
$proc = Start-Process -FilePath 'docker' -ArgumentList $args -NoNewWindow -Wait -PassThru
if ($proc.ExitCode -eq 0) { Write-Host 'Build succeeded (via Docker Maven).' } else { Write-Error "Build failed inside Docker (exit $($proc.ExitCode))."; exit $proc.ExitCode }
