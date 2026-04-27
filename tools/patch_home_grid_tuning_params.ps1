# MuthoBazar Home Grid Tuning Params Patch V2
# -------------------------------------------
# Fixes previous script issue:
# PowerShell variable names are case-insensitive; $Home conflicts with built-in $HOME.
# This script uses $HomePageContent instead.

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$ToolDir = Split-Path $MyInvocation.MyCommand.Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$BackupDir = Join-Path $RepoRoot "tools\backups\home_grid_tuning_v2_$Timestamp"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

$GridPath = Join-Path $RepoRoot "apps\customer_app\lib\features\home\widgets\sections\mb_home_product_grid_section.dart"
$HomePath = Join-Path $RepoRoot "apps\customer_app\lib\features\home\pages\home_page.dart"
$GapDir = Join-Path $RepoRoot "apps\customer_app\lib\features\home\widgets\sections\gap_fillers"
$ProfilePath = Join-Path $GapDir "mb_home_card_layout_profile.dart"
$TuningPath = Join-Path $GapDir "mb_home_grid_layout_tuning.dart"

$ProfileSource = Join-Path $ToolDir "mb_home_card_layout_profile.dart"
$TuningSource = Join-Path $ToolDir "mb_home_grid_layout_tuning.dart"

if (!(Test-Path $GridPath)) { throw "Grid file not found: $GridPath" }
if (!(Test-Path $HomePath)) { throw "HomePage file not found: $HomePath" }
if (!(Test-Path $ProfileSource)) { throw "Profile source not found: $ProfileSource" }
if (!(Test-Path $TuningSource)) { throw "Tuning source not found: $TuningSource" }

New-Item -ItemType Directory -Force -Path $GapDir | Out-Null

Write-Host ""
Write-Host "Creating backups..." -ForegroundColor Yellow

Copy-Item -LiteralPath $GridPath -Destination (Join-Path $BackupDir "mb_home_product_grid_section.dart.bak") -Force
Copy-Item -LiteralPath $HomePath -Destination (Join-Path $BackupDir "home_page.dart.bak") -Force

if (Test-Path $ProfilePath) {
  Copy-Item -LiteralPath $ProfilePath -Destination (Join-Path $BackupDir "mb_home_card_layout_profile.dart.bak") -Force
}

if (Test-Path $TuningPath) {
  Copy-Item -LiteralPath $TuningPath -Destination (Join-Path $BackupDir "mb_home_grid_layout_tuning.dart.bak") -Force
}

Write-Host "Backup folder:" -ForegroundColor Green
Write-Host "  $BackupDir"

Write-Host ""
Write-Host "Writing tuning/profile files..." -ForegroundColor Yellow
Copy-Item -LiteralPath $TuningSource -Destination $TuningPath -Force
Copy-Item -LiteralPath $ProfileSource -Destination $ProfilePath -Force

# Patch grid file to use manual column/row gaps.
$GridContent = [System.IO.File]::ReadAllText($GridPath)

if ($GridContent -notmatch "mb_home_grid_layout_tuning\.dart") {
  $GridContent = $GridContent -replace "import 'gap_fillers/mb_home_card_layout_profile.dart';", "import 'gap_fillers/mb_home_card_layout_profile.dart';`r`nimport 'gap_fillers/mb_home_grid_layout_tuning.dart';"
}

$GridContent = $GridContent -replace "final\s+gap\s*=\s*MBSpacing\.sm;", "final columnGap = MBHomeGridLayoutTuning.cardColumnGap;`r`n    final rowGap = MBHomeGridLayoutTuning.cardRowGap;"
$GridContent = $GridContent -replace "gap:\s*gap,", "gap: columnGap,"
$GridContent = $GridContent -replace "if\s*\(index\s*!=\s*rows\.length\s*-\s*1\)\s*SizedBox\(height:\s*gap\),", "if (index != rows.length - 1) SizedBox(height: rowGap),"
$GridContent = $GridContent -replace "if\s*\(index\s*!=\s*rows\.length\s*-\s*1\)\s*SizedBox\(height:\s*columnGap\),", "if (index != rows.length - 1) SizedBox(height: rowGap),"
$GridContent = $GridContent -replace "final\s+elasticPenalty\s*=\s*adjustmentNeeded\s*\*\s*[0-9.]+;", "final elasticPenalty = adjustmentNeeded * MBHomeGridLayoutTuning.elasticResizePenalty;"
$GridContent = $GridContent -replace "remaining\s*\*\s*0\.62", "remaining * MBHomeGridLayoutTuning.shortCardExpandBias"

[System.IO.File]::WriteAllText($GridPath, $GridContent, [System.Text.UTF8Encoding]::new($false))

# Patch gap filler widget top padding if file exists.
$GapWidgetPath = Join-Path $GapDir "mb_home_gap_filler_widget.dart"
if (Test-Path $GapWidgetPath) {
  Copy-Item -LiteralPath $GapWidgetPath -Destination (Join-Path $BackupDir "mb_home_gap_filler_widget.dart.bak") -Force
  $GapWidgetContent = [System.IO.File]::ReadAllText($GapWidgetPath)

  if ($GapWidgetContent -notmatch "mb_home_grid_layout_tuning\.dart") {
    $GapWidgetContent = $GapWidgetContent -replace "import 'mb_home_gap_filler_models.dart';", "import 'mb_home_gap_filler_models.dart';`r`nimport 'mb_home_grid_layout_tuning.dart';"
  }

  $GapWidgetContent = $GapWidgetContent -replace "padding:\s*EdgeInsets\.only\(top:\s*MBSpacing\.xs\),", "padding: const EdgeInsets.only(top: MBHomeGridLayoutTuning.fillerTopGap),"

  [System.IO.File]::WriteAllText($GapWidgetPath, $GapWidgetContent, [System.Text.UTF8Encoding]::new($false))
}

# Patch HomePage body horizontal margin.
$HomePageContent = [System.IO.File]::ReadAllText($HomePath)

if ($HomePageContent -notmatch "class\s+_HomeLayoutTuning") {
  $Insert = @"

class _HomeLayoutTuning {
  const _HomeLayoutTuning._();

  // Manual left/right margin for Home body content and product grid.
  // Recommended: 8, 10, 12, or 16.
  static const double bodyHorizontalPadding = 10;
}

"@
  $HomePageContent = $HomePageContent -replace "class\s+HomePage\s+extends\s+StatefulWidget", "$Insert`r`nclass HomePage extends StatefulWidget"
}

$HomePageContent = $HomePageContent -replace "horizontal:\s*MBSpacing\.pageHorizontal\(context\),", "horizontal: _HomeLayoutTuning.bodyHorizontalPadding,"

[System.IO.File]::WriteAllText($HomePath, $HomePageContent, [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "Patch completed." -ForegroundColor Green
Write-Host ""
Write-Host "Manual adjustment files:" -ForegroundColor Cyan
Write-Host "  $TuningPath"
Write-Host "  $HomePath"
Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host "Full restart customer app and pull-refresh Home."
