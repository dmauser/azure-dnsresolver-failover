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
. (Join-Path $PSScriptRoot 'lib/azctx.ps1') -SubscriptionId $cfg.SUB
$dir = Join-Path $root "results/raw/$RunId"
$vms = @((Get-Content (Join-Path $dir 'run.json') -Raw | ConvertFrom-Json).vms)

function Kql($q) {
    # Token bound to the lab subscription's tenant, so a changed global 'az account' default cannot break collection.
    $tok = az account get-access-token --subscription $cfg.SUB --resource https://api.loganalytics.io --query accessToken -o tsv 2>$null
    if ($LASTEXITCODE -or -not $tok) { Write-Warning 'could not get Log Analytics token'; return @() }
    try {
        $r = Invoke-RestMethod -Method Post -Uri "https://api.loganalytics.io/v1/workspaces/$($cfg.LAW_ID)/query" `
            -Headers @{ Authorization = "Bearer $tok" } -ContentType 'application/json' `
            -Body (@{ query = $q; timespan = 'P2D' } | ConvertTo-Json)
    } catch { Write-Warning "query failed: $($_.Exception.Message)"; return @() }
    $cols = $r.tables[0].columns.name
    @(foreach ($row in $r.tables[0].rows) {
            $o = [ordered]@{}; for ($i = 0; $i -lt $cols.Count; $i++) { $o[$cols[$i]] = $row[$i] }; [pscustomobject]$o
        })
}

$deadline = (Get-Date).AddMinutes($TimeoutMin)
while ($true) {
    $st = Kql @"
DnsProbe_CL | where RunId == '$RunId'
| summarize data = countif(Method != 'meta'), expected = toint(take_anyif(Answer, Method == 'meta')) by Vm
"@
    $done = @($st | Where-Object { $null -ne $_.expected -and [int]$_.data -ge [int]$_.expected }).Count
    $missing = @($vms | Where-Object { $_ -notin @($st | Where-Object { $null -ne $_.expected -and [int]$_.data -ge [int]$_.expected }).Vm })
    if (-not $missing.Count) { break }
    if ((Get-Date) -gt $deadline) { Write-Warning "Timed out; incomplete: $($missing -join ', ')"; break }
    Write-Host "  $done/$($vms.Count) VMs complete in Log Analytics (waiting on $($missing -join ', '))..."
    Start-Sleep 30
}

foreach ($vm in $vms) {
    $rows = Kql @"
DnsProbe_CL | where RunId == '$RunId' and Vm == '$vm' and Method != 'meta'
| project ts = tolong((TimeGenerated - datetime(1970-01-01)) / 1ms), vm = Vm, os = Os, design = Design, profile = Profile, name = Name, method = Method,
          server = Server, rcode = Rcode, answer = Answer, ms = Ms
| order by ts asc
"@
    if (-not $rows.Count) { Write-Warning "no rows for $vm"; continue }
    $f = Join-Path $dir "$($RunId)_$($vm)_$($rows[0].profile).csv"
    # ts comes back as epoch ms (avoids PowerShell's lossy auto date parsing) and is written as ISO 8601 UTC.
    $rows | Select-Object @{ n = 'ts'; e = { [DateTimeOffset]::FromUnixTimeMilliseconds([long]$_.ts).UtcDateTime.ToString('yyyy-MM-ddTHH:mm:ss.fffZ') } }, vm, os, design, profile, name, method, server, rcode, answer, ms |
        Export-Csv -Path $f -NoTypeInformation -UseQuotes AsNeeded
    Write-Host "  $vm -> $($rows.Count) rows"
}
