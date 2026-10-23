#requires -Version 7
<#
.SYNOPSIS
  Deploys the DNS Private Resolver failover lab (what-if first, then apply).
.EXAMPLE
  ./scripts/deploy.ps1 -SubscriptionId <id> -Owner me@contoso.com
  ./scripts/deploy.ps1 -SubscriptionId <id> -Owner me@contoso.com -WhatIfOnly
.NOTES
  Deploys the multi-region hub-spoke reference lab (hubs + NVA routers + spokes). Add emulated on-premises with ./scripts/deploy-onprem.ps1.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$SubscriptionId,
    [Parameter(Mandatory)][string]$Owner,
    [string]$Location = 'eastus2',
    [string]$TtlTag = (Get-Date).ToUniversalTime().AddDays(7).ToString('yyyy-MM-dd'),
    [switch]$WhatIfOnly,
    [switch]$Yes
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$secrets = Join-Path $root '.secrets'
New-Item -ItemType Directory -Force -Path $secrets | Out-Null

. (Join-Path $PSScriptRoot 'lib/azctx.ps1') -SubscriptionId $SubscriptionId

# SSH key (never committed; .secrets/ is git-ignored). Used only for VM creation; access is via run-command.
$key = Join-Path $secrets 'lab_ed25519'
if (-not (Test-Path $key)) { ssh-keygen -q -t ed25519 -N '""' -f $key -C 'dnsfo-lab' | Out-Null }
$pub = (Get-Content "$key.pub" -Raw).Trim()

# One-time Windows password: generated, passed once, never written to disk.
$chars = 'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!#%*+-'
$winPwd = -join (1..24 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] }) + 'Aa1!'

$name = "dnsfo-$((Get-Date).ToUniversalTime().ToString('yyyyMMddHHmm'))"
$common = @(
    '--location', $Location,
    '--template-file', (Join-Path $root 'infra/main.bicep'),
    '--parameters', "@$(Join-Path $root 'infra/main.parameters.json')",
    '--parameters', "owner=$Owner", "ttlTag=$TtlTag", "sshPublicKey=$pub",
    "windowsAdminPassword=$winPwd"
)

Write-Host "== what-if ($name)" -ForegroundColor Cyan
az deployment sub what-if --name $name @common --result-format ResourceIdOnly
if ($LASTEXITCODE) { throw 'what-if failed' }
if ($WhatIfOnly) { return }
if (-not $Yes) {
    $ans = Read-Host 'Deploy? Resolver endpoints and VMs are billed hourly (see docs/cost.md) [y/N]'
    if ($ans -ne 'y') { return }
}

Write-Host "== deploy ($name)" -ForegroundColor Cyan
$out = az deployment sub create --name $name @common --query properties.outputs -o json
if ($LASTEXITCODE) { throw 'deployment failed' }
$out | Set-Content (Join-Path $secrets 'outputs.json')
& (Join-Path $PSScriptRoot 'lib/write-env.ps1') -OutputsPath (Join-Path $secrets 'outputs.json') -SubscriptionId $SubscriptionId
Write-Host 'Done. Lab outputs written to .secrets/lab.env' -ForegroundColor Green
