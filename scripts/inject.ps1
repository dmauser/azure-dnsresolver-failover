#requires -Version 7
<#
.SYNOPSIS
  Injects or restores a simulated failure of the PRIMARY (region 1) resolver path and logs UTC events.

.DESCRIPTION
  F1a  NSG deny UDP+TCP/53 inbound on the region-1 inbound endpoint subnet (snet-dns-inbound).
  F1b  NSG deny UDP+TCP/53 outbound to 10.10.0.4 on a client spoke subnet (-Design, default b).
  F1c  F1a + NSG deny outbound 53 on both region-1 outbound endpoint subnets (whole regional resolver).
  F2   UDR 10.10.0.4/32 -> None on a client spoke (-Design, default b). Direct client->IE traffic only.
  F3   Remove spoke <-> hub-r1 peering (-Design, default b).
  F4   Delete the region-1 inbound endpoint (restore recreates it with the same static IP).
  F5u  F1a but UDP only.   F5t  F1a but TCP only.
  F6   Unlink spoke-c from the spoke ruleset (what does 168.63.129.16 return when the path breaks?).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('inject', 'restore')][string]$Action,
    [Parameter(Mandatory)][ValidateSet('F1a', 'F1b', 'F1c', 'F2', 'F3', 'F4', 'F5u', 'F5t', 'F6')][string]$Failure,
    [ValidateSet('a', 'b', 'c', 'd')][string]$Design = 'b',
    [string]$RunId = 'manual',
    [string]$Prefix = 'dnsfo'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$envFile = Join-Path $root '.secrets/lab.env'
$cfg = @{}
Get-Content $envFile | ForEach-Object { $k, $v = $_ -split '=', 2; $cfg[$k] = $v }
$sub = $cfg.SUB; $rg1 = $cfg.RG_R1; $ie1 = $cfg.IE_R1
az account set --subscription $sub | Out-Null

$evDir = Join-Path $root "results/raw/$RunId"
New-Item -ItemType Directory -Force -Path $evDir | Out-Null
$evFile = Join-Path $evDir 'events.csv'
if (-not (Test-Path $evFile)) { Set-Content $evFile 'ts,run_id,failure,event,detail' }
function Log($evt, $detail = '') {
    $ts = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    Add-Content $evFile "$ts,$RunId,$Failure,$evt,$detail"
    Write-Host "$ts $Failure $evt $detail"
}
function Az { az @args; if ($LASTEXITCODE) { throw "az $($args -join ' ') failed" } }

$api = '2022-07-01'
$resolverId = "/subscriptions/$sub/resourceGroups/$rg1/providers/Microsoft.Network/dnsResolvers/dnspr-$Prefix-r1"
$nsgIn = "nsg-$Prefix-hub-r1-dnsin"
$nsgOut = "nsg-$Prefix-hub-r1-dnsout"
$nsgSpoke = "nsg-$Prefix-spoke-$Design"
$rtSpoke = "rt-$Prefix-spoke-$Design"
$ruleName = 'lab-deny-dns'

function NsgDeny($nsg, $direction, $proto, $dest = '*') {
    Az network nsg rule create -g $rg1 --nsg-name $nsg -n $ruleName --priority 100 --direction $direction `
        --access Deny --protocol $proto --destination-port-ranges 53 --destination-address-prefixes $dest `
        --source-address-prefixes '*' --source-port-ranges '*' -o none
}
function NsgClear($nsg) {
    az network nsg rule delete -g $rg1 --nsg-name $nsg -n $ruleName -o none 2>$null
}

Log "$($Action)_start" "design=$Design"
switch ("$Failure/$Action") {
    'F1a/inject' { NsgDeny $nsgIn Inbound '*' }
    'F1a/restore' { NsgClear $nsgIn }
    'F5u/inject' { NsgDeny $nsgIn Inbound Udp }
    'F5u/restore' { NsgClear $nsgIn }
    'F5t/inject' { NsgDeny $nsgIn Inbound Tcp }
    'F5t/restore' { NsgClear $nsgIn }
    'F1b/inject' { NsgDeny $nsgSpoke Outbound '*' "$ie1/32" }
    'F1b/restore' { NsgClear $nsgSpoke }
    'F1c/inject' { NsgDeny $nsgIn Inbound '*'; NsgDeny $nsgOut Outbound '*' }
    'F1c/restore' { NsgClear $nsgIn; NsgClear $nsgOut }
    'F2/inject' {
        Az network route-table route create -g $rg1 --route-table-name $rtSpoke -n lab-blackhole-ie1 `
            --address-prefix "$ie1/32" --next-hop-type None -o none
    }
    'F2/restore' { az network route-table route delete -g $rg1 --route-table-name $rtSpoke -n lab-blackhole-ie1 -o none }
    'F3/inject' {
        az network vnet peering delete -g $rg1 --vnet-name "vnet-$Prefix-spoke-$Design" -n to-hub-r1 -o none
        az network vnet peering delete -g $rg1 --vnet-name "vnet-$Prefix-hub-r1" -n "to-spoke-$Design" -o none
    }
    'F3/restore' {
        Az network vnet peering create -g $rg1 --vnet-name "vnet-$Prefix-spoke-$Design" -n to-hub-r1 `
            --remote-vnet "vnet-$Prefix-hub-r1" --allow-vnet-access -o none
        Az network vnet peering create -g $rg1 --vnet-name "vnet-$Prefix-hub-r1" -n "to-spoke-$Design" `
            --remote-vnet "vnet-$Prefix-spoke-$Design" --allow-vnet-access -o none
    }
    'F4/inject' { Az rest --method delete --url "https://management.azure.com$resolverId/inboundEndpoints/in-r1?api-version=$api" }
    'F4/restore' {
        $loc = az network vnet show -g $rg1 -n "vnet-$Prefix-hub-r1" --query location -o tsv
        $body = @{
            location   = $loc
            properties = @{ ipConfigurations = @(@{
                        subnet                    = @{ id = "/subscriptions/$sub/resourceGroups/$rg1/providers/Microsoft.Network/virtualNetworks/vnet-$Prefix-hub-r1/subnets/snet-dns-inbound" }
                        privateIpAddress          = $ie1
                        privateIpAllocationMethod = 'Static'
                    }) 
            }
        } | ConvertTo-Json -Depth 6 -Compress
        $tmp = New-TemporaryFile; Set-Content $tmp $body
        Az rest --method put --url "https://management.azure.com$resolverId/inboundEndpoints/in-r1?api-version=$api" --body "@$tmp" -o none
        Remove-Item $tmp
        # PUT returns while provisioning; wait for Succeeded so restore_done is meaningful.
        do { Start-Sleep 5; $st = az rest --method get --url "https://management.azure.com$resolverId/inboundEndpoints/in-r1?api-version=$api" --query properties.provisioningState -o tsv } while ($st -ne 'Succeeded')
    }
    'F6/inject' {
        Az rest --method delete --url "https://management.azure.com/subscriptions/$sub/resourceGroups/$rg1/providers/Microsoft.Network/dnsForwardingRulesets/dnsfrs-$Prefix-spoke-r1/virtualNetworkLinks/spoke-c?api-version=$api"
    }
    'F6/restore' {
        $vnetId = "/subscriptions/$sub/resourceGroups/$rg1/providers/Microsoft.Network/virtualNetworks/vnet-$Prefix-spoke-c"
        $tmp = New-TemporaryFile; Set-Content $tmp (@{ properties = @{ virtualNetwork = @{ id = $vnetId } } } | ConvertTo-Json -Depth 4 -Compress)
        Az rest --method put --url "https://management.azure.com/subscriptions/$sub/resourceGroups/$rg1/providers/Microsoft.Network/dnsForwardingRulesets/dnsfrs-$Prefix-spoke-r1/virtualNetworkLinks/spoke-c?api-version=$api" --body "@$tmp" -o none
        Remove-Item $tmp
    }
}
Log "$($Action)_done" "design=$Design"
