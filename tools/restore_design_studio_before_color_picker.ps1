# MuthoBazar - Restore Design Studio Before Color Picker
# ------------------------------------------------------
# The color-picker patch corrupted mb_card_design_studio.dart by injecting
# invalid Dart fragments/import text into the file.
#
# This script restores the latest automatic backup made by:
# add_design_studio_color_picker.ps1
#
# It also backs up the currently broken file before restoring.
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\restore_design_studio_before_color_picker.ps1
#
# Then:
# flutter analyze

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$ParentRoot = Split-Path $RepoRoot
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$RelativePath = "packages\shared_ui\lib\widgets\common\product_cards\design_studio\mb_card_design_studio.dart"
$Target = Join-Path $RepoRoot $RelativePath

$ColorPickerBackupRoot = Join-Path $ParentRoot "MuthoBazar_PatchBackups"
$RecoveryBackupRoot = Join-Path $ParentRoot "MuthoBazar_PatchBackups\restore_design_studio_before_color_picker_$Timestamp"
$BrokenBackup = Join-Path $RecoveryBackupRoot $RelativePath

Write-Host ""
Write-Host "MuthoBazar - Restore Design Studio Before Color Picker" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host ""

if (!(Test-Path -LiteralPath $Target)) {
  throw "Target file not found: $Target"
}

if (!(Test-Path -LiteralPath $ColorPickerBackupRoot)) {
  throw "Patch backup root not found: $ColorPickerBackupRoot"
}

$CandidateBackups = Get-ChildItem -LiteralPath $ColorPickerBackupRoot -Directory -Filter "add_design_studio_color_picker_*" |
  Sort-Object Name -Descending |
  ForEach-Object {
    $CandidateFile = Join-Path $_.FullName $RelativePath
    if (Test-Path -LiteralPath $CandidateFile) {
      [PSCustomObject]@{
        Folder = $_.FullName
        File = $CandidateFile
        LastWriteTime = (Get-Item -LiteralPath $CandidateFile).LastWriteTime
      }
    }
  } |
  Sort-Object LastWriteTime -Descending

$RestoreSource = $CandidateBackups | Select-Object -First 1

if ($null -eq $RestoreSource) {
  throw "No add_design_studio_color_picker backup containing $RelativePath was found."
}

New-Item -ItemType Directory -Force -Path (Split-Path $BrokenBackup) | Out-Null
Copy-Item -LiteralPath $Target -Destination $BrokenBackup -Force

Copy-Item -LiteralPath $RestoreSource.File -Destination $Target -Force

Write-Host "Restored design studio from:" -ForegroundColor Green
Write-Host "  $($RestoreSource.File)"
Write-Host ""
Write-Host "Broken file backed up to:" -ForegroundColor Yellow
Write-Host "  $BrokenBackup"
Write-Host ""

$Text = [System.IO.File]::ReadAllText($Target)

if ($Text.Contains("class _MBHexColorPickerDialog")) {
  Write-Host "Warning: restored file still contains _MBHexColorPickerDialog." -ForegroundColor Yellow
}

if ($Text.Contains("import 'dart:convert';`r`nimport 'dart:math' as math;")) {
  Write-Host "Warning: restored file may still contain inserted import fragments." -ForegroundColor Yellow
}

Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host ""
Write-Host "After analyze is clean enough again, send this output before we rebuild color picker safely:" -ForegroundColor Cyan
Write-Host 'Select-String -Path .\packages\shared_ui\lib\widgets\common\product_cards\design_studio\mb_card_design_studio.dart -Pattern "_styleHexField|_paletteHexField|_styleNullableSlider" -Context 2,40'
