# MuthoBazar Home Full-Width Card Layout Fix
#
# Run from repo root:
# powershell -ExecutionPolicy Bypass -File .\tools\patch_home_full_width_card_layout.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$ToolDir = Split-Path $MyInvocation.MyCommand.Path

$GridTarget = Join-Path $RepoRoot "apps\customer_app\lib\features\home\widgets\sections\mb_home_product_grid_section.dart"
$HorizontalTarget = Join-Path $RepoRoot "apps\customer_app\lib\features\home\widgets\sections\mb_home_product_horizontal_section.dart"

$GridSource = Join-Path $ToolDir "mb_home_product_grid_section.dart"
$HorizontalSource = Join-Path $ToolDir "mb_home_product_horizontal_section.dart"

if (!(Test-Path $GridTarget)) { throw "Grid target not found: $GridTarget" }
if (!(Test-Path $HorizontalTarget)) { throw "Horizontal target not found: $HorizontalTarget" }
if (!(Test-Path $GridSource)) { throw "Grid source not found: $GridSource" }
if (!(Test-Path $HorizontalSource)) { throw "Horizontal source not found: $HorizontalSource" }

$GridBackup = "$GridTarget.bak_full_width_layout_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$HorizontalBackup = "$HorizontalTarget.bak_full_width_layout_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

Copy-Item -LiteralPath $GridTarget -Destination $GridBackup -Force
Copy-Item -LiteralPath $HorizontalTarget -Destination $HorizontalBackup -Force

Copy-Item -LiteralPath $GridSource -Destination $GridTarget -Force
Copy-Item -LiteralPath $HorizontalSource -Destination $HorizontalTarget -Force

Write-Host ""
Write-Host "Backups created:" -ForegroundColor Yellow
Write-Host $GridBackup
Write-Host $HorizontalBackup
Write-Host ""
Write-Host "Patched Home sections so full-width card variants span a full row." -ForegroundColor Green
Write-Host ""
Write-Host "Next:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host "Full restart customer app and pull-refresh Home."
