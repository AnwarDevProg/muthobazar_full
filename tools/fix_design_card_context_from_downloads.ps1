# MuthoBazar - Fix Design Card Context Build Errors
# ------------------------------------------------
# This fixes build errors caused by reading MBProduct fields that do not
# exist yet in the current shared_models product model.
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\fix_design_card_context_from_downloads.ps1
#
# Optional:
# powershell -ExecutionPolicy Bypass -File .\tools\fix_design_card_context_from_downloads.ps1 -ZipPath "C:\Users\1\Downloads\muthobazar_fix_design_card_context_patch.zip"

param(
  [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "MuthoBazar Fix Design Card Context Patch" -ForegroundColor Cyan
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

  $Candidates = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_fix_design_card_context_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending

  if ($Candidates.Count -eq 0) {
    throw "No matching ZIP found in Downloads. Expected: muthobazar_fix_design_card_context_patch.zip"
  }

  return $Candidates[0].FullName
}

$PatchZip = Resolve-PatchZip -CustomZipPath $ZipPath
$TempExtractDir = Join-Path $env:TEMP "muthobazar_fix_design_card_context_$Timestamp"
$BackupDir = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\fix_design_card_context_$Timestamp"

$TargetRel = "packages\shared_ui\lib\widgets\common\product_cards\design_engine\mb_design_card_context.dart"
$Target = Join-Path $RepoRoot $TargetRel

try {
  Write-Host "Patch ZIP: $PatchZip" -ForegroundColor Yellow

  if (!(Test-Path -LiteralPath $Target)) {
    throw "Target file not found: $Target"
  }

  Remove-Item -LiteralPath $TempExtractDir -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $TempExtractDir | Out-Null
  New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

  Write-Host ""
  Write-Host "Extracting ZIP..." -ForegroundColor Yellow
  Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempExtractDir -Force

  $Source = Join-Path $TempExtractDir ("payload\" + $TargetRel)

  if (!(Test-Path -LiteralPath $Source)) {
    throw "Payload source missing: $Source"
  }

  Write-Host "Creating backup outside repo..." -ForegroundColor Yellow
  $Backup = Join-Path $BackupDir $TargetRel
  New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
  Copy-Item -LiteralPath $Target -Destination $Backup -Force
  Write-Host "  $Backup"

  Write-Host ""
  Write-Host "Replacing context file..." -ForegroundColor Yellow
  Copy-Item -LiteralPath $Source -Destination $Target -Force
  Write-Host "  $TargetRel"

  Write-Host ""
  Write-Host "Patch completed." -ForegroundColor Green
  Write-Host "Backup folder:" -ForegroundColor Yellow
  Write-Host "  $BackupDir"
  Write-Host ""
  Write-Host "Now run:" -ForegroundColor Cyan
  Write-Host "flutter analyze"
  Write-Host "flutter run"
}
finally {
  if (Test-Path -LiteralPath $TempExtractDir) {
    Write-Host ""
    Write-Host "Cleaning temporary extract folder..." -ForegroundColor Yellow
    Remove-Item -LiteralPath $TempExtractDir -Recurse -Force
  }
}
