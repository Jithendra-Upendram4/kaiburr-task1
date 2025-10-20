<#
Simple PowerShell helper to query GitHub Actions runs for this repository.

Usage:
  # set a PAT into GH_PAT environment variable (scoped to repo/workflow)
  $env:GH_PAT = 'ghp_xxx'
  .\scripts\check-actions.ps1 -owner 'Jithendra-Upendram4' -repo 'kaiburr-task1' -branch 'main'

Security: do NOT commit your PAT. Use environment variables or a secure secret manager.
#>

param(
  [string]$owner = 'Jithendra-Upendram4',
  [string]$repo  = 'kaiburr-task1',
  [string]$branch = 'main'
)

$pat = $env:GH_PAT
if (-not $pat) { Write-Host "Set GH_PAT environment variable with a Personal Access Token and rerun."; exit 1 }

$headers = @{ Authorization = "token $pat"; 'User-Agent' = 'ps-check-actions' }
$uri = "https://api.github.com/repos/$owner/$repo/actions/runs?branch=$branch&per_page=10"

try {
  $res = Invoke-RestMethod -Uri $uri -Headers $headers -UseBasicParsing
  $res.workflow_runs | Select-Object id,name,status,conclusion,head_branch,head_sha,html_url,created_at | Format-Table -AutoSize
} catch {
  Write-Host "Failed to query Actions API: $($_.Exception.Message)"
}
