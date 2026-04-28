# MuthoBazar Advanced Card Design Studio - Patch 1 Downloads Installer
# Run this from the MuthoBazar repository root.
# It finds the ZIP in Downloads, extracts it to a temp folder, backs up the target folder, then copies files.
# Example:
#   PS C:\Users\1\AndroidStudioProjects\MuthoBazar> powershell -ExecutionPolicy Bypass -File C:\Users\1\Downloads\install_advanced_card_studio_patch_1_from_downloads.ps1

param(
  [string]$RepoRoot = (Get-Location).Path,
  [string]$ZipPath = (Join-Path $env:USERPROFILE "Downloads\muthobazar_advanced_card_studio_patch_1.zip")
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path $RepoRoot).Path
$RequiredRepoPath = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards"
if (!(Test-Path $RequiredRepoPath)) {
  throw "This script must target the MuthoBazar repository root. Missing: $RequiredRepoPath"
}

if (!(Test-Path $ZipPath)) {
  throw "Patch ZIP not found: $ZipPath"
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ExtractRoot = Join-Path $env:TEMP "muthobazar_advanced_card_studio_patch_1_$Timestamp"
New-Item -ItemType Directory -Force -Path $ExtractRoot | Out-Null

Expand-Archive -Path $ZipPath -DestinationPath $ExtractRoot -Force

$PatchRoot = Join-Path $ExtractRoot "muthobazar_advanced_card_studio_patch_1"
$SourceDir = Join-Path $PatchRoot "packages\shared_ui\lib\widgets\common\product_cards\design_studio_advanced"
$TargetDir = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_studio_advanced"

if (!(Test-Path $SourceDir)) {
  throw "Extracted patch source folder not found: $SourceDir"
}

$BackupRoot = Join-Path $RepoRoot ".patch_backups\advanced_card_studio_patch_1_$Timestamp"
New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null

if (Test-Path $TargetDir) {
  $BackupTarget = Join-Path $BackupRoot "design_studio_advanced"
  Copy-Item -Path $TargetDir -Destination $BackupTarget -Recurse -Force
  Write-Host "Backup created: $BackupTarget" -ForegroundColor Yellow
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $TargetDir) | Out-Null
Copy-Item -Path $SourceDir -Destination (Split-Path -Parent $TargetDir) -Recurse -Force

Write-Host "Advanced Card Design Studio Patch 1 installed." -ForegroundColor Green
Write-Host "Installed to: $TargetDir" -ForegroundColor Green
Write-Host "Temp extraction folder: $ExtractRoot" -ForegroundColor DarkGray
Write-Host "Next recommended check:" -ForegroundColor Cyan
Write-Host "  flutter analyze packages/shared_ui" -ForegroundColor Cyan
