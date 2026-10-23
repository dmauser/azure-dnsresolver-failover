#requires -Version 7
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$SubscriptionId,
    [string]$Prefix = 'dnsfo',
    [switch]$Yes
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib/azctx.ps1') -SubscriptionId $SubscriptionId
# On-prem sites first: they hold peerings/VPN connections into the hub VNets (r1/r2).
$rgs = "rg-$Prefix-onprem1", "rg-$Prefix-onprem2", "rg-$Prefix-r1", "rg-$Prefix-r2", "rg-$Prefix-shared"
if (-not $Yes) {
    if ((Read-Host "Delete $($rgs -join ', ')? [y/N]") -ne 'y') { return }
}
# r1 holds the spokes, rulesets and policy links; delete it first so hub2 peerings/links clear cleanly.
foreach ($rg in $rgs) {
    if ((az group exists -n $rg) -eq 'true') {
        Write-Host "Deleting $rg"
        az group delete -n $rg --yes
    }
}
