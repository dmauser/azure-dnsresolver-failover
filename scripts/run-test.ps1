#requires -Version 7
<#
.SYNOPSIS
  Runs one failover experiment: baseline -> inject -> failure window -> restore -> recovery.

.EXAMPLE
  ./scripts/run-test.ps1 -Failure F1a
  ./scripts/run-test.ps1 -Failure F1a -LinuxProfile glibc-tuned -Repeat 3
  ./scripts/run-test.ps1 -Failure F4 -FailureSec 300 -RecoverySec 300
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('F1a', 'F1b', 'F1c', 'F2', 'F3', 'F4', 'F5u', 'F5t', 'F6', 'none')][string]$Failure,
    [ValidateSet('a', 'b', 'c', 'd')][string]$Design = 'b',
    [ValidateSet('resolved-default', 'glibc-default', 'glibc-tuned')][string]$LinuxProfile = 'resolved-default',
    [int]$BaselineSec = 60,
    [int]$FailureSec = 180,
    [int]$RecoverySec = 180,
    [int]$LeadSec = 150,
    [int]$Repeat = 1,
    [switch]$NoWindows,
    [string]$Prefix = 'dnsfo'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$cfg = @{}
Get-Content (Join-Path $root '.secrets/lab.env') | ForEach-Object { $k, $v = $_ -split '=', 2; $cfg[$k] = $v }
az account set --subscription $cfg.SUB | Out-Null
$acct = $cfg.RESULTS_ACCOUNT

# Upload probe code once per invocation (VMs fetch it with their managed identity).
foreach ($f in 'probe.py', 'probe.ps1') {
    az storage blob upload --account-name $acct -c results -n "_bin/$f" -f (Join-Path $PSScriptRoot "probe/$f") `
        --auth-mode login --overwrite -o none
    if ($LASTEXITCODE) { throw "upload $f failed (Storage Blob Data Contributor may still be propagating)" }
}

$names = @(
    'app1.azure.contoso.internal', 'app2.azure.contoso.internal', 'whoami.lab.contoso.internal',
    'host.onprem.contoso.internal', $cfg.BLOB_R1, 'www.microsoft.com'
) -join ','
$digNames = 'whoami.lab.contoso.internal,app1.azure.contoso.internal'
$designServers = @{
    a = @('168.63.129.16'); d = @('168.63.129.16')
    b = @($cfg.IE_R1, $cfg.IE_R2); c = @('168.63.129.16', $cfg.IE_R2)
}
function Servers($d) { (@($designServers[$d]) + $cfg.IE_R1 + $cfg.IE_R2 | Select-Object -Unique) -join ',' }

$linuxTpl = @'
set -e
mkdir -p /opt/dnsprobe /var/log/dnsprobe
TOK=$(curl -sf -H Metadata:true "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fstorage.azure.com%2F" | python3 -c 'import sys,json;print(json.load(sys.stdin)["access_token"])')
curl -sf -H "Authorization: Bearer $TOK" -H "x-ms-version: 2023-11-03" "https://__ACCT__.blob.core.windows.net/results/_bin/probe.py" -o /opt/dnsprobe/probe.py
case "__PROFILE__" in
  resolved-default) ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf ;;
  glibc-default) grep '^nameserver' /run/systemd/resolve/resolv.conf > /tmp/rc; rm -f /etc/resolv.conf; mv /tmp/rc /etc/resolv.conf ;;
  glibc-tuned) { grep '^nameserver' /run/systemd/resolve/resolv.conf; echo 'options timeout:1 attempts:2'; } > /tmp/rc; rm -f /etc/resolv.conf; mv /tmp/rc /etc/resolv.conf ;;
esac
resolvectl flush-caches || true
systemd-run --unit "dnsprobe-__RUN__" --collect python3 /opt/dnsprobe/probe.py --run-id "__RUN__" --design "__DESIGN__" \
  --profile "__PROFILE__" --start-at __T0__ --end-at __TEND__ --names "__NAMES__" --dig-names "__DIGNAMES__" \
  --servers "__SERVERS__" --account "__ACCT__"
echo "scheduled dnsprobe-__RUN__ on $(hostname); resolv.conf: $(readlink -f /etc/resolv.conf)"
'@

$winTpl = @'
New-Item -ItemType Directory -Force -Path C:\dnsprobe | Out-Null
$tok = (Invoke-RestMethod -Headers @{Metadata='true'} -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fstorage.azure.com%2F').access_token
Invoke-WebRequest -UseBasicParsing -Headers @{Authorization="Bearer $tok";'x-ms-version'='2023-11-03'} -Uri 'https://__ACCT__.blob.core.windows.net/results/_bin/probe.ps1' -OutFile C:\dnsprobe\probe.ps1
Clear-DnsClientCache
$arg = '-NoProfile -ExecutionPolicy Bypass -File C:\dnsprobe\probe.ps1 -RunId __RUN__ -Design __DESIGN__ -StartAt __T0__ -EndAt __TEND__ -Names __NAMES__ -SrvNames __DIGNAMES__ -Servers __SERVERS__ -Account __ACCT__'
$a = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arg
Register-ScheduledTask -TaskName 'dnsprobe-__RUN__' -Action $a -User 'SYSTEM' -RunLevel Highest -Force | Out-Null
Start-ScheduledTask -TaskName 'dnsprobe-__RUN__'
"scheduled dnsprobe-__RUN__ on $env:COMPUTERNAME; dns: $((Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object ServerAddresses | Select-Object -First 1).ServerAddresses -join ',')"
'@

function Fill($tpl, $map) { $s = $tpl; foreach ($k in $map.Keys) { $s = $s.Replace("__$($k)__", [string]$map[$k]) }; $s }

for ($rep = 1; $rep -le $Repeat; $rep++) {
    $runId = "{0}-{1}-{2}-r{3}" -f [DateTime]::UtcNow.ToString('yyyyMMddTHHmmss'), $Failure, $LinuxProfile, $rep
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $t0 = $now + $LeadSec
    $tInject = $t0 + $BaselineSec
    $tRestore = $tInject + $FailureSec
    $tEnd = $tRestore + $RecoverySec
    $outDir = Join-Path $root "results/raw/$runId"
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    @{ run_id = $runId; failure = $Failure; design_param = $Design; linux_profile = $LinuxProfile
        t0 = $t0; t_inject_planned = $tInject; t_restore_planned = $tRestore; t_end = $tEnd
    } | ConvertTo-Json | Set-Content (Join-Path $outDir 'run.json')
    Write-Host "== $runId  T0=$([DateTimeOffset]::FromUnixTimeSeconds($t0).UtcDateTime.ToString('HH:mm:ss'))Z" -ForegroundColor Cyan

    $jobs = @()
    foreach ($pair in ($cfg.LINUX_CLIENTS -split ',' | Where-Object { $_ })) {
        $d, $vm = $pair -split ':'
        $script = Fill $linuxTpl @{ ACCT = $acct; PROFILE = $LinuxProfile; RUN = $runId; DESIGN = $d; T0 = $t0; TEND = $tEnd
            NAMES = $names; DIGNAMES = $digNames; SERVERS = (Servers $d)
        }
        $jobs += Start-ThreadJob -ArgumentList $cfg.RG_R1, $vm, $script -ScriptBlock {
            param($rg, $vm, $s)
            $f = New-TemporaryFile; Set-Content $f $s -NoNewline
            $r = az vm run-command invoke -g $rg -n $vm --command-id RunShellScript --scripts "@$f" --query 'value[0].message' -o tsv 2>&1
            Remove-Item $f; "$vm :: $r"
        }
    }
    if (-not $NoWindows) {
        foreach ($pair in ($cfg.WINDOWS_CLIENTS -split ',' | Where-Object { $_ })) {
            $d, $vm = $pair -split ':'
            $script = Fill $winTpl @{ ACCT = $acct; RUN = $runId; DESIGN = $d; T0 = $t0; TEND = $tEnd
                NAMES = $names; DIGNAMES = $digNames; SERVERS = (Servers $d)
            }
            $jobs += Start-ThreadJob -ArgumentList $cfg.RG_R1, $vm, $script -ScriptBlock {
                param($rg, $vm, $s)
                $f = New-TemporaryFile; $p = "$f.ps1"; Set-Content $p $s
                $r = az vm run-command invoke -g $rg -n $vm --command-id RunPowerShellScript --scripts "@$p" --query 'value[0].message' -o tsv 2>&1
                Remove-Item $f, $p; "$vm :: $r"
            }
        }
    }
    $jobs | Wait-Job -Timeout ($LeadSec + 120) | Receive-Job | ForEach-Object { Write-Host $_ }
    $late = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() - $t0
    if ($late -gt 0) { Write-Warning "Probe scheduling finished $late s after T0; baseline is shorter than planned." }

    if ($Failure -ne 'none') {
        Start-Sleep -Seconds ([Math]::Max(0, $tInject - [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()))
        & (Join-Path $PSScriptRoot 'inject.ps1') -Action inject -Failure $Failure -Design $Design -RunId $runId -Prefix $Prefix
        Start-Sleep -Seconds ([Math]::Max(0, $tRestore - [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()))
        & (Join-Path $PSScriptRoot 'inject.ps1') -Action restore -Failure $Failure -Design $Design -RunId $runId -Prefix $Prefix
    }
    $wait = $tEnd + 90 - [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    Write-Host "Waiting $wait s for probes to finish and upload..."
    Start-Sleep -Seconds ([Math]::Max(0, $wait))
    & (Join-Path $PSScriptRoot 'collect.ps1') -RunId $runId
}
