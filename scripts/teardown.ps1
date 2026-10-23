#requires -Version 7
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$SubscriptionId,
    [string]$Prefix = 'dnsfo',
    [switch]$Yes
)
$ErrorActionPreference = 'Stop'
az account set --subscription $SubscriptionId | Out-Null
$rgs = "rg-$Prefix-r1", "rg-$Prefix-r2", "rg-$Prefix-shared"
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
