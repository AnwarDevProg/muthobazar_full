# MuthoBazar - Apply Card Layout Settings Model Patch From Downloads
# ------------------------------------------------------------------
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_card_layout_settings_model_patch_from_downloads.ps1
#
# Optional:
# powershell -ExecutionPolicy Bypass -File .\tools\apply_card_layout_settings_model_patch_from_downloads.ps1 -ZipPath "C:\Users\1\Downloads\muthobazar_card_layout_settings_model_patch.zip"

param(
  [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "MuthoBazar Card Layout Settings Model Patch" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host ""

function Resolve-PatchZip {
  param([string]$CustomZipPath)

  if (![string]::IsNullOrWhiteSpace($CustomZipPath)) {
    if (!(Test-Path -LiteralPath $CustomZipPath)) {
      throw "Custom ZIP not found: $CustomZipPath"
    }

    return (Resolve-Path -LiteralPath $CustomZipPath).Path
  }

  $Downloads = Join-Path $env:USERPROFILE "Downloads"

  if (!(Test-Path -LiteralPath $Downloads)) {
    throw "Downloads folder not found: $Downloads"
  }

  $Candidates = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_card_layout_settings_model_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending

  if ($Candidates.Count -eq 0) {
    throw "No matching ZIP found in Downloads. Expected: muthobazar_card_layout_settings_model_patch.zip"
  }

  return $Candidates[0].FullName
}

$PatchZip = Resolve-PatchZip -CustomZipPath $ZipPath
$TempExtractDir = Join-Path $env:TEMP "muthobazar_card_layout_settings_model_patch_$Timestamp"
$BackupDir = Join-Path $RepoRoot "tools\backups\card_layout_settings_model_patch_$Timestamp"

$Targets = @(
  "packages\shared_models\lib\product_cards\config\mb_card_layout_settings.dart",
  "packages\shared_ui\lib\widgets\common\product_cards\system\mb_product_card_layout_resolver.dart"
)

try {
  Write-Host "Patch ZIP: $PatchZip" -ForegroundColor Yellow

  Remove-Item -LiteralPath $TempExtractDir -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $TempExtractDir | Out-Null
  New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

  Write-Host ""
  Write-Host "Extracting ZIP..." -ForegroundColor Yellow
  Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempExtractDir -Force

  Write-Host "Creating backups..." -ForegroundColor Yellow

  foreach ($Rel in $Targets) {
    $Target = Join-Path $RepoRoot $Rel

    if (Test-Path -LiteralPath $Target) {
      $Backup = Join-Path $BackupDir $Rel
      New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
      Copy-Item -LiteralPath $Target -Destination $Backup -Force
      Write-Host "  $Rel"
    }
  }

  Write-Host ""
  Write-Host "Patching files..." -ForegroundColor Yellow

  foreach ($Rel in $Targets) {
    $Source = Join-Path $TempExtractDir "payload\$Rel"
    $Target = Join-Path $RepoRoot $Rel

    if (!(Test-Path -LiteralPath $Source)) {
      throw "Payload file missing: $Source"
    }

    New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Target -Force
    Write-Host "  $Rel"
  }

  Write-Host ""
  Write-Host "Patch completed." -ForegroundColor Green
  Write-Host "Backup folder:" -ForegroundColor Yellow
  Write-Host "  $BackupDir"
  Write-Host ""
  Write-Host "Now run:" -ForegroundColor Cyan
  Write-Host "flutter analyze"
}
finally {
  if (Test-Path -LiteralPath $TempExtractDir) {
    Write-Host ""
    Write-Host "Cleaning temporary extract folder..." -ForegroundColor Yellow
    Remove-Item -LiteralPath $TempExtractDir -Recurse -Force
  }
}
