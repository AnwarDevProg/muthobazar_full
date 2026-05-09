<#
MuthoBazar Patch ZIP Runner

Run from any folder. Usually run from Downloads.
It copies the patch ZIP from Downloads to:
E:\MuthoBazar\Patch_Files\<patch_name>
then extracts there and runs the first apply.ps1 it finds.

Example:
powershell -ExecutionPolicy Bypass -File "C:\Users\1\AndroidStudioProjects\MuthoBazar\tools\scripts\patching\mb_apply_patch.ps1" -PatchName "mb_v4_base_v1"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$PatchName,

    [string]$DownloadsDir = (Join-Path $env:USERPROFILE "Downloads"),

    [string]$PatchRoot = "E:\MuthoBazar\Patch_Files"
)

$ErrorActionPreference = "Stop"

$HelperPath = Join-Path $PSScriptRoot "mb_patch_helpers.ps1"
if (!(Test-Path $HelperPath)) {
    throw "Patch helper not found: $HelperPath"
}

. $HelperPath

try {
    Invoke-MBPatchZipFromDownloads `
        -PatchName $PatchName `
        -DownloadsDir $DownloadsDir `
        -PatchRoot $PatchRoot
}
catch {
    Write-MBFail $_.Exception.Message
    exit 1
}
