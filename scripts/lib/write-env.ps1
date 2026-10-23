param(
    [Parameter(Mandatory)][string]$OutputsPath,
    [Parameter(Mandatory)][string]$SubscriptionId
)
$o = Get-Content $OutputsPath -Raw | ConvertFrom-Json
$lines = @(
    "SUB=$SubscriptionId"
    "RG_SHARED=$($o.rgShared.value)"
    "RG_R1=$($o.rgR1.value)"
    "RG_R2=$($o.rgR2.value)"
    "IE_R1=$($o.inboundIpR1.value)"
    "IE_R2=$($o.inboundIpR2.value)"
    "WHOAMI_R1=$($o.whoamiR1.value)"
    "WHOAMI_R2=$($o.whoamiR2.value)"
    "BLOB_R1=$($o.blobFqdnR1.value)"
    "BLOB_R2=$($o.blobFqdnR2.value)"
    "LAW_ID=$($o.workspaceCustomerId.value)"
    "INGEST_ENDPOINT=$($o.ingestEndpoint.value)"
    "DCR_ID=$($o.dcrImmutableId.value)"
    "RESOLVER_R1=$($o.resolverR1.value)"
    "RESOLVER_R2=$($o.resolverR2.value)"
    "HUB_R1=$($o.hubR1.value)"
    "HUB_R2=$($o.hubR2.value)"
    "SPOKE_R1=$($o.spokeR1.value)"
    "SPOKE_R2=$($o.spokeR2.value)"
    "NVA_R1=$($o.nvaIpR1.value)"
    "NVA_R2=$($o.nvaIpR2.value)"
    "NVA_VM_R1=$($o.nvaVmR1.value)"
    "NVA_VM_R2=$($o.nvaVmR2.value)"
    "LINUX_CLIENTS=$(($o.linuxClients.value | ForEach-Object { "$($_.design):$($_.vm):$($_.rg)" }) -join ',')"
    "WINDOWS_CLIENTS=$(($o.windowsClients.value | ForEach-Object { "$($_.design):$($_.vm):$($_.rg)" }) -join ',')"
)
$envPath = Join-Path (Split-Path $OutputsPath) 'lab.env'
# Keep keys written by deploy-onprem.ps1 so redeploying the core lab does not drop them.
if (Test-Path $envPath) {
    $lines += Get-Content $envPath | Where-Object { $_ -match '^(ONPREM_|RG_ONPREM)' }
}
$lines | Set-Content $envPath
