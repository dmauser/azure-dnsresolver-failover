#requires -Version 7
<#
.SYNOPSIS
  Adds two emulated on-premises sites (op1, op2) to an existing lab deployed by deploy.ps1.
.DESCRIPTION
  Each site is a VNet with a BIND DNS server (conditional forwarders -> both DNS Private
  Resolver inbound endpoints, local endpoint first) and a Linux probe client.
  Connectivity to the hubs:
    Peering (default) - VNet peering op1<->hub-r1, op2<->hub-r2. Cheapest, deploys in minutes.
    Vpn               - VNet-to-VNet IPsec/BGP using four VPN gateways. Realistic, ~45 min, ~$0.80/h extra.
.EXAMPLE
  ./scripts/deploy-onprem.ps1 -SubscriptionId <id> -Owner me@contoso.com
  ./scripts/deploy-onprem.ps1 -SubscriptionId <id> -Owner me@contoso.com -Connectivity Vpn
.NOTES
  Requires the core lab (deploy.ps1) to exist first: it peers to / builds gateways in the hub VNets.
  The hub GatewaySubnet is part of the core deployment, so a core redeploy keeps it. Re-run this
  script after a core redeploy anyway to restore the hub-side peerings/routes for the sites.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$SubscriptionId,
    [Parameter(Mandatory)][string]$Owner,
    [ValidateSet('Peering', 'Vpn')][string]$Connectivity = 'Peering',
    [string]$Prefix = 'dnsfo',
    [string]$PrimaryLocation = 'eastus2',
    [string]$SecondaryLocation = 'centralus',
    [string]$TtlTag = (Get-Date).ToUniversalTime().AddDays(7).ToString('yyyy-MM-dd'),
    [switch]$WhatIfOnly,
    [switch]$Yes
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$secrets = Join-Path $root '.secrets'
New-Item -ItemType Directory -Force -Path $secrets | Out-Null

. (Join-Path $PSScriptRoot 'lib/azctx.ps1') -SubscriptionId $SubscriptionId

foreach ($rg in "rg-$Prefix-r1", "rg-$Prefix-r2") {
    if ((az group exists -n $rg) -ne 'true') { throw "$rg not found. Deploy the core lab first (scripts/deploy.ps1)." }
}

$key = Join-Path $secrets 'lab_ed25519'
if (-not (Test-Path $key)) { ssh-keygen -q -t ed25519 -N '""' -f $key -C 'dnsfo-lab' | Out-Null }
$pub = (Get-Content "$key.pub" -Raw).Trim()

$params = @(
    "prefix=$Prefix", "primaryLocation=$PrimaryLocation", "secondaryLocation=$SecondaryLocation",
    "owner=$Owner", "ttlTag=$TtlTag", "sshPublicKey=$pub", "connectivity=$Connectivity"
)
if ($Connectivity -eq 'Vpn') {
    # Generated per run, passed once, never written to disk.
    $chars = 'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    $params += "vpnSharedKey=$(-join (1..32 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] }))"
}

$name = "dnsfo-onprem-$((Get-Date).ToUniversalTime().ToString('yyyyMMddHHmm'))"
$common = @('--location', $PrimaryLocation, '--template-file', (Join-Path $root 'infra/onprem.bicep'), '--parameters') + $params

Write-Host "== what-if ($name, $Connectivity)" -ForegroundColor Cyan
az deployment sub what-if --name $name @common --result-format ResourceIdOnly
if ($LASTEXITCODE) { throw 'what-if failed' }
if ($WhatIfOnly) { return }
if (-not $Yes) {
    $msg = if ($Connectivity -eq 'Vpn') { 'Deploy? 4 VPN gateways (~45 min, billed hourly, see docs/cost.md) [y/N]' } else { 'Deploy? 4 small VMs + peering (see docs/cost.md) [y/N]' }
    if ((Read-Host $msg) -ne 'y') { return }
}

Write-Host "== deploy ($name)" -ForegroundColor Cyan
$out = az deployment sub create --name $name @common --query properties.outputs -o json
if ($LASTEXITCODE) { throw 'deployment failed' }
$outPath = Join-Path $secrets 'onprem-outputs.json'
$out | Set-Content $outPath
$o = $out | ConvertFrom-Json

# Merge on-prem keys into lab.env (replace any previous on-prem values).
$envPath = Join-Path $secrets 'lab.env'
$keep = if (Test-Path $envPath) { Get-Content $envPath | Where-Object { $_ -notmatch '^(RG_ONPREM\d|ONPREM_[A-Z_0-9]+)=' } } else { @() }
$new = @(
    "ONPREM_CONNECTIVITY=$($o.connectivity.value)"
    "RG_ONPREM1=$($o.onpremResourceGroups.value[0])"
    "RG_ONPREM2=$($o.onpremResourceGroups.value[1])"
    "ONPREM_CLIENTS=$($o.onpremClients.value -join ',')"
    "ONPREM_DNS_1=$($o.onpremDnsIps.value[0])"
    "ONPREM_DNS_2=$($o.onpremDnsIps.value[1])"
    "ONPREM_BIND_VMS=$($o.onpremBindVms.value -join ',')"
    "ONPREM_APP_FQDNS=$($o.onpremAppFqdns.value -join ',')"
)
@($keep) + $new | Set-Content $envPath
Write-Host "Done. On-prem keys merged into .secrets/lab.env ($Connectivity)." -ForegroundColor Green
