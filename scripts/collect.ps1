#requires -Version 7
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunId,
    [int]$Retries = 6
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$cfg = @{}
Get-Content (Join-Path $root '.secrets/lab.env') | ForEach-Object { $k, $v = $_ -split '=', 2; $cfg[$k] = $v }
$expected = @($cfg.LINUX_CLIENTS -split ',' | Where-Object { $_ }).Count + @($cfg.WINDOWS_CLIENTS -split ',' | Where-Object { $_ }).Count
$dest = Join-Path $root 'results/raw'
for ($i = 0; $i -lt $Retries; $i++) {
    $blobs = az storage blob list --account-name $cfg.RESULTS_ACCOUNT -c results --prefix "$RunId/" --auth-mode login --query '[].name' -o tsv
    $n = @($blobs | Where-Object { $_ }).Count
    if ($n -ge $expected) { break }
    Write-Host "  $n/$expected CSVs uploaded, waiting..."
    Start-Sleep 30
}
az storage blob download-batch --account-name $cfg.RESULTS_ACCOUNT -s results --pattern "$RunId/*" -d $dest --auth-mode login --overwrite -o none
Get-ChildItem (Join-Path $dest $RunId) | Select-Object Name, Length | Format-Table -AutoSize
