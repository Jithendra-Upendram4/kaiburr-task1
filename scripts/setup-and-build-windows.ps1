<#
setup-and-build-windows.ps1

This script installs Temurin JDK 21 and Apache Maven using winget or Chocolatey,
refreshes the session environment, and runs a Maven package build (skip tests).
Run this script from an elevated PowerShell (it will re-launch itself elevated if needed).
#>

# Ensure script runs with ExecutionPolicy bypass when elevated
param()

function Is-Administrator {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Relaunch elevated if not admin
if (-not (Is-Administrator)) {
    Write-Host 'Not running as Administrator — relaunching elevated...'
    $args = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    # Prefer pwsh if available in PSHOME, otherwise fall back to Windows PowerShell
    $pwshCandidate = Join-Path $PSHOME 'pwsh.exe'
    $winpsCandidate = Join-Path $PSHOME 'powershell.exe'
    if (Test-Path $pwshCandidate) {
        $exe = $pwshCandidate
    } elseif (Test-Path $winpsCandidate) {
        $exe = $winpsCandidate
    } else {
        # Fallback to in-path executable name
        $exe = 'powershell.exe'
    }
    Start-Process -FilePath $exe -ArgumentList $args -Verb RunAs
    exit 0
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Install-With-Winget {
    param($id)
    Write-Host "Installing $id via winget..."
    winget install --id $id -e --accept-package-agreements --accept-source-agreements --silent
}

function Install-With-Choco {
    param($pkg)
    Write-Host "Installing $pkg via choco..."
    choco install $pkg -y --no-progress
}

# Detect package manager
$hasWinget = $null -ne (Get-Command winget -ErrorAction SilentlyContinue)
$hasChoco = $null -ne (Get-Command choco -ErrorAction SilentlyContinue)

# Install JDK21
if ($hasWinget) {
    try {
        Install-With-Winget -id 'EclipseAdoptium.Temurin.21.JDK'
    } catch {
        Write-Warning "winget JDK install failed: $_"
        if ($hasChoco) { Install-With-Choco -pkg 'Temurin21' }
        else { throw 'Unable to install JDK: winget failed and choco not available.' }
    }
} elseif ($hasChoco) {
    Install-With-Choco -pkg 'Temurin21'
} else {
    throw 'No winget or choco found. Please install JDK 21 and Maven manually.'
}

# Install Maven
if ($hasWinget) {
    try {
        Install-With-Winget -id 'Apache.Maven'
    } catch {
        Write-Warning "winget Maven install failed: $_"
        try { Install-With-Winget -id 'Maven.Maven' } catch { 
            if ($hasChoco) { Install-With-Choco -pkg 'maven' } else { throw 'Maven install failed and choco not available.' }
        }
    }
} elseif ($hasChoco) {
    Install-With-Choco -pkg 'maven'
}

# Refresh environment for this elevated session
Write-Host 'Refreshing PATH and JAVA_HOME for this session...'
$javaPath = (& where.exe java 2>$null | Select-Object -First 1)
if ($javaPath) {
    $javaBin = Split-Path $javaPath -Parent
    $env:JAVA_HOME = Split-Path $javaBin -Parent
    $env:PATH = "$javaBin;" + $env:PATH
    Write-Host "Set JAVA_HOME=$env:JAVA_HOME"
} else {
    Write-Warning 'java not found after install. You may need to sign out/in or restart.'
}

$mvnPath = (& where.exe mvn 2>$null | Select-Object -First 1)
if ($mvnPath) {
    $mvnBin = Split-Path $mvnPath -Parent
    $env:PATH = "$mvnBin;" + $env:PATH
    Write-Host "Maven bin added to PATH: $mvnBin"
} else {
    Write-Warning 'mvn not found after install. You may need to sign out/in or restart.'
}

# Show versions
Write-Host '--- java -version ---'
try { java -version } catch { Write-Warning 'java -version failed.' }
Write-Host '--- javac -version ---'
try { javac -version } catch { }
Write-Host '--- mvn -v ---'
try { mvn -v } catch { Write-Warning 'mvn not found or failed.' }

# Build the project
$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path "D:\kaiburr-task1")) { $repoRoot = 'D:\kaiburr-task1' }
Write-Host "Building project at $repoRoot ..."
Push-Location $repoRoot
try {
    & mvn -U -DskipTests clean package
    Write-Host 'Build completed. Check target/ for the produced artifact.'
} catch {
    Write-Error "Build failed: $_"
    exit 1
} finally {
    Pop-Location
}

Write-Host 'Done.'
