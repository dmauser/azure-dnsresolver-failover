<#
.SYNOPSIS
  DNS failover probe for Windows clients (Windows PowerShell 5.1 compatible).
  One background job per (name, method); one CSV row per query:
    ts,vm,os,design,profile,name,method,server,rcode,answer,ms
  Methods
    os       Resolve-DnsName -DnsOnly (DNS Client service: server list, failover logic and cache)
    os-api   [System.Net.Dns]::GetHostAddresses (what most .NET apps do)
    srv      Resolve-DnsName -Server <ip> -DnsOnly -QuickTimeout (raw per-server reachability)
  At the end the rows are sent to Log Analytics (DnsProbe_CL) via the Logs Ingestion API with the VM managed identity.
#>
param(
    [Parameter(Mandatory)][string]$RunId,
    [Parameter(Mandatory)][string]$Design,
    [Parameter(Mandatory)][string]$Names,
    [string]$SrvNames = '',
    [string]$Servers = '',
    [double]$StartAt = 0,
    [double]$EndAt = 0,
    [int]$Duration = 420,
    [double]$Interval = 0.5,
    [string]$IngestEndpoint = '',
    [string]$Dcr = '',
    [string]$Out = 'C:\dnsprobe\out'
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $Out | Out-Null
function Epoch { [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() / 1000.0 }
# Jobs are started immediately and each waits for StartAt itself: spawning ~18 powershell.exe jobs on a
if ($EndAt -le 0) { $EndAt = [Math]::Max((Epoch), $StartAt) + $Duration }

$probe = {
    param($Name, $Method, $Server, $StartAt, $EndAt, $Interval, $File, $Base)
    function Epoch { [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() / 1000.0 }
    $w = $StartAt - (Epoch); if ($w -gt 0) { Start-Sleep -Milliseconds ([int]($w * 1000)) }
    function Code($err) {
        $e = $err.Exception
        while ($e.InnerException -and -not ($e -is [System.ComponentModel.Win32Exception])) { $e = $e.InnerException }
        $n = if ($e -is [System.ComponentModel.Win32Exception]) { $e.NativeErrorCode } elseif ($e -is [System.Net.Sockets.SocketException]) { $e.ErrorCode } else { 0 }
        switch ($n) {
            9003 { 'NXDOMAIN' }  # DNS_ERROR_RCODE_NAME_ERROR
            9002 { 'SERVFAIL' }  # DNS_ERROR_RCODE_SERVER_FAILURE
            9501 { 'NODATA' }    # DNS_INFO_NO_RECORDS
            1460 { 'TIMEOUT' }   # ERROR_TIMEOUT
            11001 { 'NXDOMAIN_OR_FAIL' } # WSAHOST_NOT_FOUND (os-api)
            11002 { 'TRY_AGAIN' }        # WSATRY_AGAIN (os-api)
            default { "ERR$n" }
        }
    }
    $sw = [Diagnostics.Stopwatch]::new()
    $rows = New-Object System.Collections.Generic.List[string]
    while ((Epoch) -lt $EndAt) {
        $loop = Epoch
        $ts = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
        $rcode = 'NOERROR'; $ans = ''
        $sw.Restart()
        try {
            switch ($Method) {
                'os' { $r = Resolve-DnsName -Name $Name -Type A -DnsOnly -ErrorAction Stop }
                'os-api' { $r = [System.Net.Dns]::GetHostAddresses($Name) }
                'srv' { $r = Resolve-DnsName -Name $Name -Type A -DnsOnly -QuickTimeout -Server $Server -ErrorAction Stop }
            }
            if ($Method -eq 'os-api') { $ans = ($r | ForEach-Object { $_.IPAddressToString } | Sort-Object -Unique) -join ';' }
            else { $ans = ($r | Where-Object { $_.Type -eq 'A' } | ForEach-Object { $_.IPAddress } | Sort-Object -Unique) -join ';' }
            if (-not $ans) { $rcode = 'NODATA' }
        } catch { $rcode = Code $_ }
        $sw.Stop()
        $rows.Add(('{0},{1},{2},{3},{4},{5},{6},{7}' -f $ts, $Base, $Name, $Method, $Server, $rcode, $ans, $sw.ElapsedMilliseconds))
        if ($rows.Count -ge 20) { Add-Content -Path $File -Value $rows; $rows.Clear() }
        $sleep = $Interval - ((Epoch) - $loop)
        if ($sleep -gt 0) { Start-Sleep -Milliseconds ([int]($sleep * 1000)) }
    }
    if ($rows.Count) { Add-Content -Path $File -Value $rows }
}

$vm = $env:COMPUTERNAME.ToLower()
$base = "$vm,windows,$($Design.ToUpper()),windows-default"
$jobs = @()
$parts = @()
$i = 0
foreach ($n in ($Names -split ',' | Where-Object { $_ })) {
    foreach ($m in 'os', 'os-api') {
        $f = Join-Path $Out "$RunId-part$i.csv"; $i++; $parts += $f
        $jobs += Start-Job -ScriptBlock $probe -ArgumentList $n, $m, '', $StartAt, $EndAt, $Interval, $f, $base
    }
}
foreach ($n in ($SrvNames -split ',' | Where-Object { $_ })) {
    foreach ($s in ($Servers -split ',' | Where-Object { $_ })) {
        $f = Join-Path $Out "$RunId-part$i.csv"; $i++; $parts += $f
        $jobs += Start-Job -ScriptBlock $probe -ArgumentList $n, 'srv', $s, $StartAt, $EndAt, $Interval, $f, $base
    }
}
$jobs | Wait-Job -Timeout ([int]($EndAt - (Epoch) + 60)) | Out-Null
$jobs | Receive-Job -ErrorAction SilentlyContinue | Out-Null
$jobs | Remove-Job -Force

$csv = Join-Path $Out "$($RunId)_$($vm)_windows-default.csv"
Set-Content -Path $csv -Value 'ts,vm,os,design,profile,name,method,server,rcode,answer,ms'
foreach ($p in $parts) { if (Test-Path $p) { Get-Content $p | Add-Content -Path $csv; Remove-Item $p } }

if ($IngestEndpoint -and $Dcr) {
    $tok = (Invoke-RestMethod -Headers @{ Metadata = 'true' } -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmonitor.azure.com%2F').access_token
    $uri = "$IngestEndpoint/dataCollectionRules/$Dcr/streams/Custom-DnsProbe?api-version=2023-01-01"
    $rows = @(Import-Csv $csv | ForEach-Object {
            [ordered]@{ TimeGenerated = $_.ts; RunId = $RunId; Vm = $_.vm; Os = $_.os; Design = $_.design; Profile = $_.profile
                Name = $_.name; Method = $_.method; Server = $_.server; Rcode = $_.rcode; Answer = $_.answer; Ms = [int]$_.ms
            } })
    # Always send a 'meta' row (answer = data-row count) so the collector never waits on an empty VM.
    $meta = [ordered]@{ TimeGenerated = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ss.fffZ'); RunId = $RunId; Vm = $vm; Os = 'windows'
        Design = $Design.ToUpper(); Profile = 'windows-default'; Name = '-'; Method = 'meta'; Server = ''; Rcode = 'DONE'
        Answer = [string]$rows.Count; Ms = 0
    }
        $batches = @()
        for ($i = 0; $i -lt $rows.Count; $i += 500) { $batches += , ($rows[$i..([Math]::Min($i + 499, $rows.Count - 1))]) }
        $batches += , @($meta)
        foreach ($b in $batches) {
            $body = [Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject @($b) -Compress))
            for ($a = 0; $a -lt 5; $a++) {
                try { Invoke-RestMethod -Method Post -Uri $uri -Body $body -ContentType 'application/json' -Headers @{ Authorization = "Bearer $tok" } | Out-Null; break }
                catch { Start-Sleep -Seconds (5 * ($a + 1)); if ($a -eq 4) { throw } }
            }
        }
    "ingested $($rows.Count) rows from $csv"
}
