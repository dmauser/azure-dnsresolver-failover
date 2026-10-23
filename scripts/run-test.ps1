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
. (Join-Path $PSScriptRoot 'lib/azctx.ps1') -SubscriptionId $cfg.SUB
# Probe code is embedded (base64) in each run-command, so VMs need no storage access.
function B64File($f) { [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(([IO.File]::ReadAllText((Join-Path $PSScriptRoot "probe/$f"))).Replace("`r`n", "`n"))) }
$pyB64 = B64File 'probe.py'
$psB64 = B64File 'probe.ps1'

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
echo "__PYB64__" | base64 -d > /opt/dnsprobe/probe.py
case "__PROFILE__" in
  resolved-default) ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf ;;
  glibc-default) grep '^nameserver' /run/systemd/resolve/resolv.conf > /tmp/rc; rm -f /etc/resolv.conf; mv /tmp/rc /etc/resolv.conf ;;
  glibc-tuned) { grep '^nameserver' /run/systemd/resolve/resolv.conf; echo 'options timeout:1 attempts:2'; } > /tmp/rc; rm -f /etc/resolv.conf; mv /tmp/rc /etc/resolv.conf ;;
esac
systemctl restart systemd-resolved   # reset resolved's sticky 'current server' so every run starts on the first server
resolvectl flush-caches || true
systemd-run --unit "dnsprobe-__RUN__" --collect python3 /opt/dnsprobe/probe.py --run-id "__RUN__" --design "__DESIGN__" \
  --profile "__PROFILE__" --start-at __T0__ --end-at __TEND__ --names "__NAMES__" --dig-names "__DIGNAMES__" \
  --servers "__SERVERS__" --ingest-endpoint "__ING__" --dcr "__DCR__"
echo "scheduled dnsprobe-__RUN__ on $(hostname); resolv.conf: $(readlink -f /etc/resolv.conf)"
'@

$winTpl = @'
New-Item -ItemType Directory -Force -Path C:\dnsprobe | Out-Null
[IO.File]::WriteAllBytes('C:\dnsprobe\probe.ps1', [Convert]::FromBase64String('__PSB64__'))
Clear-DnsClientCache
$arg = '-NoProfile -ExecutionPolicy Bypass -File C:\dnsprobe\probe.ps1 -RunId __RUN__ -Design __DESIGN__ -StartAt __T0__ -EndAt __TEND__ -Names __NAMES__ -SrvNames __DIGNAMES__ -Servers __SERVERS__ -IngestEndpoint __ING__ -Dcr __DCR__'
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
    $expectVms = @($cfg.LINUX_CLIENTS -split ',' | Where-Object { $_ } | ForEach-Object { ($_ -split ':')[1] })
    if (-not $NoWindows) { $expectVms += @($cfg.WINDOWS_CLIENTS -split ',' | Where-Object { $_ } | ForEach-Object { ($_ -split ':')[1] }) }
    @{ run_id = $runId; failure = $Failure; design_param = $Design; linux_profile = $LinuxProfile
        t0 = $t0; t_inject_planned = $tInject; t_restore_planned = $tRestore; t_end = $tEnd; vms = $expectVms
    } | ConvertTo-Json | Set-Content (Join-Path $outDir 'run.json')
    Write-Host "== $runId  T0=$([DateTimeOffset]::FromUnixTimeSeconds($t0).UtcDateTime.ToString('HH:mm:ss'))Z" -ForegroundColor Cyan

    $jobs = @()
    foreach ($pair in ($cfg.LINUX_CLIENTS -split ',' | Where-Object { $_ })) {
        $d, $vm = $pair -split ':'
        $script = Fill $linuxTpl @{ PYB64 = $pyB64; ING = $cfg.INGEST_ENDPOINT; DCR = $cfg.DCR_ID; PROFILE = $LinuxProfile; RUN = $runId; DESIGN = $d; T0 = $t0; TEND = $tEnd
            NAMES = $names; DIGNAMES = $digNames; SERVERS = (Servers $d)
        }
        $jobs += Start-ThreadJob -ArgumentList $cfg.RG_R1, $vm, $script -ScriptBlock {
            param($rg, $vm, $s)
            $f = New-TemporaryFile; [IO.File]::WriteAllText($f, $s.Replace("`r`n", "`n"))
            $r = az vm run-command invoke -g $rg -n $vm --command-id RunShellScript --scripts "@$f" --query 'value[0].message' -o tsv 2>&1
            Remove-Item $f; "$vm :: $r"
        }
    }
    if (-not $NoWindows) {
        foreach ($pair in ($cfg.WINDOWS_CLIENTS -split ',' | Where-Object { $_ })) {
            $d, $vm = $pair -split ':'
            $script = Fill $winTpl @{ PSB64 = $psB64; ING = $cfg.INGEST_ENDPOINT; DCR = $cfg.DCR_ID; RUN = $runId; DESIGN = $d; T0 = $t0; TEND = $tEnd
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
