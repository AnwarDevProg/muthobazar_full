# MuthoBazar - Clean analyzer-scanned tool/backups Dart files
# ----------------------------------------------------------
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\clean_tools_dart_from_analyzer.ps1
#
# Why:
# flutter analyze is scanning .dart files inside tools/ and tools/backups/.
# Those are patch payload/backup files, not active app source files.
# They create false analyzer errors such as missing relative imports.

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$ToolsDir = Join-Path $RepoRoot "tools"

if (!(Test-Path -LiteralPath $ToolsDir)) {
  throw "tools folder not found: $ToolsDir"
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ParentDir = Split-Path $RepoRoot
$ArchiveRoot = Join-Path $ParentDir "MuthoBazar_Analyzer_Ignored_ToolsDart_$Timestamp"

New-Item -ItemType Directory -Force -Path $ArchiveRoot | Out-Null

Write-Host ""
Write-Host "MuthoBazar analyzer cleanup" -ForegroundColor Cyan
Write-Host "Repo root:    $RepoRoot"
Write-Host "Tools folder: $ToolsDir"
Write-Host "Archive:      $ArchiveRoot"
Write-Host ""

$DartFiles = Get-ChildItem -LiteralPath $ToolsDir -Recurse -File -Filter "*.dart"

if ($DartFiles.Count -eq 0) {
  Write-Host "No .dart files found under tools/. Nothing to move." -ForegroundColor Green
} else {
  Write-Host "Moving .dart files out of tools/ so flutter analyze will not scan them..." -ForegroundColor Yellow

  foreach ($File in $DartFiles) {
    $RelativePath = $File.FullName.Substring($ToolsDir.Length).TrimStart('\', '/')
    $Destination = Join-Path $ArchiveRoot $RelativePath
    $DestinationDir = Split-Path $Destination

    New-Item -ItemType Directory -Force -Path $DestinationDir | Out-Null
    Move-Item -LiteralPath $File.FullName -Destination $Destination -Force

    Write-Host ("  moved: tools\{0}" -f $RelativePath)
  }
}

Write-Host ""
Write-Host "Checking important active source files..." -ForegroundColor Yellow

$RequiredFiles = @(
  "packages\shared_ui\lib\widgets\common\product_cards\system\mb_product_card_layout_profile.dart",
  "packages\shared_ui\lib\widgets\common\product_cards\system\mb_product_card_layout_resolver.dart",
  "packages\shared_models\lib\product_cards\config\mb_card_layout_settings.dart",
  "apps\customer_app\lib\features\home\widgets\sections\mb_home_product_grid_section.dart",
  "apps\customer_app\lib\features\home\widgets\sections\gap_fillers\mb_home_gap_filler_models.dart",
  "apps\customer_app\lib\features\home\widgets\sections\gap_fillers\mb_home_gap_filler_resolver.dart",
  "apps\customer_app\lib\features\home\widgets\sections\gap_fillers\mb_home_gap_filler_widget.dart",
  "apps\customer_app\lib\features\home\widgets\sections\gap_fillers\mb_home_grid_layout_tuning.dart"
)

$Missing = @()

foreach ($Rel in $RequiredFiles) {
  $Path = Join-Path $RepoRoot $Rel
  if (Test-Path -LiteralPath $Path) {
    Write-Host "  OK:      $Rel" -ForegroundColor Green
  } else {
    Write-Host "  MISSING: $Rel" -ForegroundColor Red
    $Missing += $Rel
  }
}

if ($Missing.Count -gt 0) {
  Write-Host ""
  Write-Host "Some active source files are missing. Do not continue with visual testing until these are restored." -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host "Cleanup completed." -ForegroundColor Green
Write-Host "Moved .dart files archive:" -ForegroundColor Yellow
Write-Host "  $ArchiveRoot"
Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
