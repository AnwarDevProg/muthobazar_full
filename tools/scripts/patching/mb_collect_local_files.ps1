<#
MuthoBazar Local File Collector

Copies latest local repo files into one flat folder:
E:\MuthoBazar\Local_Files\<patch_name>_<timestamp>

Example:
powershell -ExecutionPolicy Bypass -File .\tools\scripts\patching\mb_collect_local_files.ps1 `
  -PatchName "mb_v4_base_v1" `
  -Files "packages\shared_ui\pubspec.yaml", "packages\shared_models\lib\shared_models.dart"

Copied files are flattened using safe names. Original paths are recorded in _source_paths.txt.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$PatchName,

    [Parameter(Mandatory = $true)]
    [string[]]$Files,

    [string]$RepoPath = "C:\Users\1\AndroidStudioProjects\MuthoBazar",

    [string]$LocalFilesRoot = "E:\MuthoBazar\Local_Files"
)

$ErrorActionPreference = "Stop"

$HelperPath = Join-Path $PSScriptRoot "mb_patch_helpers.ps1"
if (!(Test-Path $HelperPath)) {
    throw "Patch helper not found: $HelperPath"
}

. $HelperPath

try {
    $OutDir = Collect-MBLocalFiles `
        -PatchName $PatchName `
        -RelativePaths $Files `
        -RepoPath $RepoPath `
        -LocalFilesRoot $LocalFilesRoot

    Write-Host ""
    Write-MBInfo "Upload/reference files are here:"
    Write-Host $OutDir -ForegroundColor Yellow
    Start-Process explorer.exe $OutDir
}
catch {
    Write-MBFail $_.Exception.Message
    exit 1
}
