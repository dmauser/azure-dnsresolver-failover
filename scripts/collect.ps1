#requires -Version 7
<#
.SYNOPSIS
  Pulls one run's probe rows from Log Analytics (DnsProbe_CL) into results/raw/<run>/<run>_<vm>_<profile>.csv.
  Waits until every VM listed in run.json has posted its 'meta' row and all of its data rows are queryable
  (ingestion latency is typically a few minutes; the first run after deployment can take longer).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunId,
    [int]$TimeoutMin = 25
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$cfg = @{}
Get-Content (Join-Path $root '.secrets/lab.env') | ForEach-Object { $k, $v = $_ -split '=', 2; $cfg[$k] = $v }
$dir = Join-Path $root "results/raw/$RunId"
$vms = @((Get-Content (Join-Path $dir 'run.json') -Raw | ConvertFrom-Json).vms)

function Kql($q) {
    $r = az monitor log-analytics query -w $cfg.LAW_ID --analytics-query $q --timespan P2D -o json 2>$null
    if ($LASTEXITCODE) { return @() }
    @($r | ConvertFrom-Json)
}

$deadline = (Get-Date).AddMinutes($TimeoutMin)
while ($true) {
    $st = Kql @"
DnsProbe_CL | where RunId == '$RunId'
| summarize data = countif(Method != 'meta'), expected = toint(take_anyif(Answer, Method == 'meta')) by Vm
"@
    $done = @($st | Where-Object { $_.expected -and [int]$_.data -ge [int]$_.expected }).Count
    $missing = @($vms | Where-Object { $_ -notin @($st | Where-Object { $_.expected -and [int]$_.data -ge [int]$_.expected }).Vm })
    if (-not $missing.Count) { break }
    if ((Get-Date) -gt $deadline) { Write-Warning "Timed out; incomplete: $($missing -join ', ')"; break }
    Write-Host "  $done/$($vms.Count) VMs complete in Log Analytics (waiting on $($missing -join ', '))..."
    Start-Sleep 30
}

foreach ($vm in $vms) {
    $rows = Kql @"
DnsProbe_CL | where RunId == '$RunId' and Vm == '$vm' and Method != 'meta'
| project ts = TimeGenerated, vm = Vm, os = Os, design = Design, profile = Profile, name = Name, method = Method,
          server = Server, rcode = Rcode, answer = Answer, ms = Ms
| order by ts asc
"@
    if (-not $rows.Count) { Write-Warning "no rows for $vm"; continue }
    $f = Join-Path $dir "$($RunId)_$($vm)_$($rows[0].profile).csv"
    $rows | Select-Object ts, vm, os, design, profile, name, method, server, rcode, answer, ms |
        Export-Csv -Path $f -NoTypeInformation -UseQuotes AsNeeded
    Write-Host "  $vm -> $($rows.Count) rows"
}
