# MuthoBazar - Apply Home Full-Width Card Layout Fix From ZIP
# -----------------------------------------------------------
# Run from repo root:
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_home_full_width_card_layout_zip.ps1
#
# Optional:
# powershell -ExecutionPolicy Bypass -File .\tools\apply_home_full_width_card_layout_zip.ps1 -ZipPath "C:\Users\1\Downloads\muthobazar_home_full_width_card_layout_fix.zip"

param(
    [string]$ZipPath = ".\muthobazar_home_full_width_card_layout_fix.zip"
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$ResolvedZipPath = Resolve-Path -LiteralPath $ZipPath

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$TempExtractDir = Join-Path $env:TEMP "muthobazar_home_full_width_fix_$Timestamp"
$BackupDir = Join-Path $RepoRoot "tools\backups\home_full_width_card_layout_$Timestamp"

$GridTarget = Join-Path $RepoRoot "apps\customer_app\lib\features\home\widgets\sections\mb_home_product_grid_section.dart"
$HorizontalTarget = Join-Path $RepoRoot "apps\customer_app\lib\features\home\widgets\sections\mb_home_product_horizontal_section.dart"

Write-Host ""
Write-Host "MuthoBazar Home Full-Width Card Layout Patch" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host "ZIP:       $ResolvedZipPath"
Write-Host ""

if (!(Test-Path -LiteralPath $GridTarget)) {
    throw "Grid target file not found: $GridTarget"
}

if (!(Test-Path -LiteralPath $HorizontalTarget)) {
    throw "Horizontal target file not found: $HorizontalTarget"
}

if (Test-Path -LiteralPath $TempExtractDir) {
    Remove-Item -LiteralPath $TempExtractDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $TempExtractDir | Out-Null
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

Write-Host "Extracting ZIP..." -ForegroundColor Yellow
Expand-Archive -LiteralPath $ResolvedZipPath -DestinationPath $TempExtractDir -Force

$GridSourcePrimary = Join-Path $TempExtractDir "apps\customer_app\lib\features\home\widgets\sections\mb_home_product_grid_section.dart"
$HorizontalSourcePrimary = Join-Path $TempExtractDir "apps\customer_app\lib\features\home\widgets\sections\mb_home_product_horizontal_section.dart"

$GridSourceFallback = Join-Path $TempExtractDir "tools\mb_home_product_grid_section.dart"
$HorizontalSourceFallback = Join-Path $TempExtractDir "tools\mb_home_product_horizontal_section.dart"

$GridSource = $null
$HorizontalSource = $null

if (Test-Path -LiteralPath $GridSourcePrimary) {
    $GridSource = $GridSourcePrimary
} elseif (Test-Path -LiteralPath $GridSourceFallback) {
    $GridSource = $GridSourceFallback
}

if (Test-Path -LiteralPath $HorizontalSourcePrimary) {
    $HorizontalSource = $HorizontalSourcePrimary
} elseif (Test-Path -LiteralPath $HorizontalSourceFallback) {
    $HorizontalSource = $HorizontalSourceFallback
}

if ($null -eq $GridSource) {
    throw "Replacement grid section file not found inside ZIP."
}

if ($null -eq $HorizontalSource) {
    throw "Replacement horizontal section file not found inside ZIP."
}

Write-Host "Creating backups first..." -ForegroundColor Yellow

$GridBackup = Join-Path $BackupDir "mb_home_product_grid_section.dart.bak"
$HorizontalBackup = Join-Path $BackupDir "mb_home_product_horizontal_section.dart.bak"

Copy-Item -LiteralPath $GridTarget -Destination $GridBackup -Force
Copy-Item -LiteralPath $HorizontalTarget -Destination $HorizontalBackup -Force

Write-Host "Backup created:" -ForegroundColor Green
Write-Host "  $GridBackup"
Write-Host "  $HorizontalBackup"
Write-Host ""

Write-Host "Patching files..." -ForegroundColor Yellow

Copy-Item -LiteralPath $GridSource -Destination $GridTarget -Force
Copy-Item -LiteralPath $HorizontalSource -Destination $HorizontalTarget -Force

Write-Host "Patched:" -ForegroundColor Green
Write-Host "  $GridTarget"
Write-Host "  $HorizontalTarget"
Write-Host ""

Write-Host "Cleaning temp files..." -ForegroundColor Yellow
Remove-Item -LiteralPath $TempExtractDir -Recurse -Force

Write-Host ""
Write-Host "Patch completed successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host ""
Write-Host "Then full restart customer app and pull-refresh Home."