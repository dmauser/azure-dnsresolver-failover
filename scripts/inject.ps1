#requires -Version 7
<#
.SYNOPSIS
  Injects or restores a simulated failure of the PRIMARY (region 1) resolver path and logs UTC events.

.DESCRIPTION
  F1a  NSG deny UDP+TCP/53 inbound on the region-1 inbound endpoint subnet (snet-dns-inbound).
       Emulates a regional resolver outage for clients; this is the reference failover test.
  F1c  F1a + NSG deny outbound 53 on the region-1 outbound endpoint subnet (whole regional resolver).
  F2   Delete the hub-r1 <-> hub-r2 global peering (both directions). Cross-region path loss:
       region-1 clients can still reach IE1; nothing can reach the other region's inbound endpoint.
  F3   Stop (deallocate) the region-1 NVA router. Cross-region traffic from region 1 is black-holed.
  F4   Delete the region-1 inbound endpoint (restore recreates it with the same static IP).
  F5u  F1a but UDP only.   F5t  F1a but TCP only.
  onprem-link-break  Remove the on-prem site 1 <-> hub-r1 link (peering mode). Site 1 attaches only to
       hub-r1, so both of its forwarder targets (IE r1 and, via the hub NVA, IE r2) become unreachable:
       this demonstrates that the site's own hub link is a single point of failure.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('inject', 'restore')][string]$Action,
    [Parameter(Mandatory)][ValidateSet('F1a', 'F1c', 'F2', 'F3', 'F4', 'F5u', 'F5t', 'onprem-link-break')][string]$Failure,
    [string]$RunId = 'manual',
    [string]$Prefix = 'dnsfo'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$envFile = Join-Path $root '.secrets/lab.env'
$cfg = @{}
Get-Content $envFile | ForEach-Object { $k, $v = $_ -split '=', 2; $cfg[$k] = $v }
$sub = $cfg.SUB; $rg1 = $cfg.RG_R1; $rg2 = $cfg.RG_R2; $ie1 = $cfg.IE_R1
. (Join-Path $PSScriptRoot 'lib/azctx.ps1') -SubscriptionId $sub

$evDir = Join-Path $root "results/raw/$RunId"
New-Item -ItemType Directory -Force -Path $evDir | Out-Null
$evFile = Join-Path $evDir 'events.csv'
if (-not (Test-Path $evFile)) { Set-Content $evFile 'ts,run_id,failure,event,detail' }
function Log($evt, $detail = '') {
    $ts = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    Add-Content $evFile "$ts,$RunId,$Failure,$evt,$detail"
    Write-Host "$ts $Failure $evt $detail"
}
function AzX { az @args; if ($LASTEXITCODE) { throw "az $($args -join ' ') failed" } }

$api = '2022-07-01'
$resolverId = "/subscriptions/$sub/resourceGroups/$rg1/providers/Microsoft.Network/dnsResolvers/dnspr-$Prefix-r1"
$nsgIn = "nsg-$Prefix-hub-r1-dnsin"
$nsgOut = "nsg-$Prefix-hub-r1-dnsout"
$hub1 = "vnet-$Prefix-hub-r1"; $hub2 = "vnet-$Prefix-hub-r2"
$hub1Id = "/subscriptions/$sub/resourceGroups/$rg1/providers/Microsoft.Network/virtualNetworks/$hub1"
$hub2Id = "/subscriptions/$sub/resourceGroups/$rg2/providers/Microsoft.Network/virtualNetworks/$hub2"
$nvaVm = if ($cfg.NVA_VM_R1) { $cfg.NVA_VM_R1 } else { "vm-$Prefix-nva-r1" }
$ruleName = 'lab-deny-dns'

function NsgDeny($nsg, $direction, $proto, $dest = '*') {
    AzX network nsg rule create -g $rg1 --nsg-name $nsg -n $ruleName --priority 100 --direction $direction `
        --access Deny --protocol $proto --destination-port-ranges 53 --destination-address-prefixes $dest `
        --source-address-prefixes '*' --source-port-ranges '*' -o none
}
function NsgClear($nsg) {
    az network nsg rule delete -g $rg1 --nsg-name $nsg -n $ruleName -o none 2>$null
}
function Peer($rg, $vnet, $name, $remoteId, [switch]$UseRemoteGw, [switch]$AllowGwTransit) {
    $a = @('network', 'vnet', 'peering', 'create', '-g', $rg, '--vnet-name', $vnet, '-n', $name, '--remote-vnet', $remoteId,
        '--allow-vnet-access', '--allow-forwarded-traffic', '-o', 'none')
    if ($UseRemoteGw) { $a += '--use-remote-gateways' }
    if ($AllowGwTransit) { $a += '--allow-gateway-transit' }
    AzX @a
}

Log "$($Action)_start"
switch ("$Failure/$Action") {
    'F1a/inject' { NsgDeny $nsgIn Inbound '*' }
    'F1a/restore' { NsgClear $nsgIn }
    'F5u/inject' { NsgDeny $nsgIn Inbound Udp }
    'F5u/restore' { NsgClear $nsgIn }
    'F5t/inject' { NsgDeny $nsgIn Inbound Tcp }
    'F5t/restore' { NsgClear $nsgIn }
    'F1c/inject' { NsgDeny $nsgIn Inbound '*'; NsgDeny $nsgOut Outbound '*' }
    'F1c/restore' { NsgClear $nsgIn; NsgClear $nsgOut }
    'F2/inject' {
        az network vnet peering delete -g $rg1 --vnet-name $hub1 -n to-hub-r2 -o none
        az network vnet peering delete -g $rg2 --vnet-name $hub2 -n to-hub-r1 -o none
    }
    'F2/restore' {
        Peer $rg1 $hub1 'to-hub-r2' $hub2Id
        Peer $rg2 $hub2 'to-hub-r1' $hub1Id
    }
    'F3/inject' { AzX vm deallocate -g $rg1 -n $nvaVm -o none }
    'F3/restore' { AzX vm start -g $rg1 -n $nvaVm -o none }
    'onprem-link-break/inject' {
        if ($cfg.ONPREM_CONNECTIVITY -ne 'Peering') { throw "onprem-link-break supports Peering mode only (ONPREM_CONNECTIVITY=$($cfg.ONPREM_CONNECTIVITY))." }
        az network vnet peering delete -g $cfg.RG_ONPREM1 --vnet-name "vnet-$Prefix-op1" -n to-hub-r1 -o none
        az network vnet peering delete -g $rg1 --vnet-name $hub1 -n to-op1 -o none
    }
    'onprem-link-break/restore' {
        $opId = "/subscriptions/$sub/resourceGroups/$($cfg.RG_ONPREM1)/providers/Microsoft.Network/virtualNetworks/vnet-$Prefix-op1"
        Peer $cfg.RG_ONPREM1 "vnet-$Prefix-op1" 'to-hub-r1' $hub1Id
        Peer $rg1 $hub1 'to-op1' $opId
    }
    'F4/inject' { AzX rest --method delete --url "https://management.azure.com$resolverId/inboundEndpoints/in-r1?api-version=$api" }
    'F4/restore' {
        $loc = az network vnet show -g $rg1 -n $hub1 --query location -o tsv
        $body = @{
            location   = $loc
            properties = @{ ipConfigurations = @(@{
                        subnet                    = @{ id = "$hub1Id/subnets/snet-dns-inbound" }
                        privateIpAddress          = $ie1
                        privateIpAllocationMethod = 'Static'
                    })
            }
        } | ConvertTo-Json -Depth 6 -Compress
        $tmp = New-TemporaryFile; Set-Content $tmp $body
        AzX rest --method put --url "https://management.azure.com$resolverId/inboundEndpoints/in-r1?api-version=$api" --body "@$tmp" -o none
        Remove-Item $tmp
        # PUT returns while provisioning; wait for Succeeded so restore_done is meaningful.
        do { Start-Sleep 5; $st = az rest --method get --url "https://management.azure.com$resolverId/inboundEndpoints/in-r1?api-version=$api" --query properties.provisioningState -o tsv } while ($st -ne 'Succeeded')
    }
}
Log "$($Action)_done"