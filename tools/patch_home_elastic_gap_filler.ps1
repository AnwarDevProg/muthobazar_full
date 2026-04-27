# MuthoBazar Home Elastic Gap Filler Patch
# ---------------------------------------
# Run from repo root:
# powershell -ExecutionPolicy Bypass -File .\tools\patch_home_elastic_gap_filler.ps1
#
# Creates timestamped backups first.

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$ToolDir = Split-Path $MyInvocation.MyCommand.Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$BackupDir = Join-Path $RepoRoot "tools\backups\home_elastic_gap_filler_$Timestamp"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

$GridTarget = Join-Path $RepoRoot "apps\customer_app\lib\features\home\widgets\sections\mb_home_product_grid_section.dart"
$GapTargetDir = Join-Path $RepoRoot "apps\customer_app\lib\features\home\widgets\sections\gap_fillers"

$GridSource = Join-Path $ToolDir "mb_home_product_grid_section.dart"
$ProfileSource = Join-Path $ToolDir "gap_fillers\mb_home_card_layout_profile.dart"
$ModelsSource = Join-Path $ToolDir "gap_fillers\mb_home_gap_filler_models.dart"
$ResolverSource = Join-Path $ToolDir "gap_fillers\mb_home_gap_filler_resolver.dart"
$WidgetSource = Join-Path $ToolDir "gap_fillers\mb_home_gap_filler_widget.dart"

if (!(Test-Path $GridTarget)) {
  throw "Grid target not found: $GridTarget"
}

foreach ($Source in @($GridSource, $ProfileSource, $ModelsSource, $ResolverSource, $WidgetSource)) {
  if (!(Test-Path $Source)) {
    throw "Source file not found: $Source"
  }
}

Write-Host ""
Write-Host "Creating backups..." -ForegroundColor Yellow

$GridBackup = Join-Path $BackupDir "mb_home_product_grid_section.dart.bak"
Copy-Item -LiteralPath $GridTarget -Destination $GridBackup -Force
Write-Host "  $GridBackup"

if (Test-Path $GapTargetDir) {
  $GapBackupDir = Join-Path $BackupDir "gap_fillers_existing"
  Copy-Item -LiteralPath $GapTargetDir -Destination $GapBackupDir -Recurse -Force
  Write-Host "  $GapBackupDir"
}

Write-Host ""
Write-Host "Creating target directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $GapTargetDir | Out-Null

Write-Host "Patching files..." -ForegroundColor Yellow

Copy-Item -LiteralPath $GridSource -Destination $GridTarget -Force
Copy-Item -LiteralPath $ProfileSource -Destination (Join-Path $GapTargetDir "mb_home_card_layout_profile.dart") -Force
Copy-Item -LiteralPath $ModelsSource -Destination (Join-Path $GapTargetDir "mb_home_gap_filler_models.dart") -Force
Copy-Item -LiteralPath $ResolverSource -Destination (Join-Path $GapTargetDir "mb_home_gap_filler_resolver.dart") -Force
Copy-Item -LiteralPath $WidgetSource -Destination (Join-Path $GapTargetDir "mb_home_gap_filler_widget.dart") -Force

Write-Host ""
Write-Host "Patch completed." -ForegroundColor Green
Write-Host ""
Write-Host "Modified:" -ForegroundColor Cyan
Write-Host "  $GridTarget"
Write-Host ""
Write-Host "Added:" -ForegroundColor Cyan
Write-Host "  $(Join-Path $GapTargetDir 'mb_home_card_layout_profile.dart')"
Write-Host "  $(Join-Path $GapTargetDir 'mb_home_gap_filler_models.dart')"
Write-Host "  $(Join-Path $GapTargetDir 'mb_home_gap_filler_resolver.dart')"
Write-Host "  $(Join-Path $GapTargetDir 'mb_home_gap_filler_widget.dart')"
Write-Host ""
Write-Host "Backups:" -ForegroundColor Yellow
Write-Host "  $BackupDir"
Write-Host ""
Write-Host "Next:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host "Full restart customer app and pull-refresh Home."
