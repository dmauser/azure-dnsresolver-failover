<#
.SYNOPSIS
  DNS failover probe for Windows clients (Windows PowerShell 5.1 compatible).
  One background job per (name, method); one CSV row per query:
    ts,vm,os,design,profile,name,method,server,rcode,answer,ms
  Methods
    os       Resolve-DnsName -DnsOnly (DNS Client service: server list, failover logic and cache)
    os-api   [System.Net.Dns]::GetHostAddresses (what most .NET apps do)
    srv      Resolve-DnsName -Server <ip> -DnsOnly -QuickTimeout (raw per-server reachability)
  At the end the CSV is uploaded to the results account with the VM managed identity.
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
    [string]$Account = '',
    [string]$Out = 'C:\dnsprobe\out'
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $Out | Out-Null
function Epoch { [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() / 1000.0 }
if ($StartAt -gt 0) { $wait = $StartAt - (Epoch); if ($wait -gt 0) { Start-Sleep -Milliseconds ([int]($wait * 1000)) } }
if ($EndAt -le 0) { $EndAt = (Epoch) + $Duration }

$probe = {
    param($Name, $Method, $Server, $EndAt, $Interval, $File, $Base)
    function Epoch { [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() / 1000.0 }
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
        $jobs += Start-Job -ScriptBlock $probe -ArgumentList $n, $m, '', $EndAt, $Interval, $f, $base
    }
}
foreach ($n in ($SrvNames -split ',' | Where-Object { $_ })) {
    foreach ($s in ($Servers -split ',' | Where-Object { $_ })) {
        $f = Join-Path $Out "$RunId-part$i.csv"; $i++; $parts += $f
        $jobs += Start-Job -ScriptBlock $probe -ArgumentList $n, 'srv', $s, $EndAt, $Interval, $f, $base
    }
}
$jobs | Wait-Job -Timeout ([int]($EndAt - (Epoch) + 60)) | Out-Null
$jobs | Receive-Job -ErrorAction SilentlyContinue | Out-Null
$jobs | Remove-Job -Force

$csv = Join-Path $Out "$($RunId)_$($vm)_windows-default.csv"
Set-Content -Path $csv -Value 'ts,vm,os,design,profile,name,method,server,rcode,answer,ms'
foreach ($p in $parts) { if (Test-Path $p) { Get-Content $p | Add-Content -Path $csv; Remove-Item $p } }

if ($Account) {
    $tok = (Invoke-RestMethod -Headers @{ Metadata = 'true' } -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fstorage.azure.com%2F').access_token
    $uri = "https://$Account.blob.core.windows.net/results/$RunId/$(Split-Path $csv -Leaf)"
    $hdr = @{ Authorization = "Bearer $tok"; 'x-ms-version' = '2023-11-03'; 'x-ms-blob-type' = 'BlockBlob' }
    Invoke-RestMethod -Method Put -Uri $uri -Headers $hdr -InFile $csv -ContentType 'text/csv' | Out-Null
    "uploaded $csv"
}
