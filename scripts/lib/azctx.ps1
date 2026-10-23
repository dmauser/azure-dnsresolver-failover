# Pins this PowerShell process (and its thread jobs) to a private Azure CLI config directory whose
# default subscription is the lab subscription, so another shell/session running 'az account set'
# cannot redirect lab commands mid-run. Seeded once from the user's existing az login (same user
# profile; the token cache stays DPAPI-protected and is never written to the repo).
param([Parameter(Mandatory)][string]$SubscriptionId)
$dir = Join-Path ($env:LOCALAPPDATA ?? $HOME) 'dnsfo-az'
if (-not (Test-Path (Join-Path $dir 'azureProfile.json'))) {
    $src = $env:AZURE_CONFIG_DIR ?? (Join-Path $HOME '.azure')
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Get-ChildItem -Path $src -File | Where-Object { $_.Name -match '^(azureProfile\.json|msal_.*|clouds\.config|config|service_principal_entries.*)$' } |
        Copy-Item -Destination $dir -Force
}
$env:AZURE_CONFIG_DIR = $dir
az account set --subscription $SubscriptionId | Out-Null
if ($LASTEXITCODE) { throw "az login required: run 'az login' (then delete $dir and retry)" }
