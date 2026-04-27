# MuthoBazar - Fix undefined columnGap in Home product grid section
# -----------------------------------------------------------------
# Run from repo root:
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\fix_home_grid_column_gap_scope.ps1
#
# Problem:
# flutter analyze reports:
# Undefined name 'columnGap'
# apps/customer_app/lib/features/home/widgets/sections/mb_home_product_grid_section.dart:246:12
#
# Cause:
# A previous regex patch changed a nested Row spacer from:
#   SizedBox(width: gap)
# to:
#   SizedBox(width: columnGap)
#
# But columnGap only exists in the parent flow build method.
# The nested row receives the value as the parameter named gap.

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Target = Join-Path $RepoRoot "apps\customer_app\lib\features\home\widgets\sections\mb_home_product_grid_section.dart"

if (!(Test-Path -LiteralPath $Target)) {
  throw "Target file not found: $Target"
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupDir = Join-Path $RepoRoot "tools\backups\fix_home_grid_column_gap_scope_$Timestamp"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

$Backup = Join-Path $BackupDir "mb_home_product_grid_section.dart.bak"
Copy-Item -LiteralPath $Target -Destination $Backup -Force

$Content = [System.IO.File]::ReadAllText($Target)

$BeforeCount = ([regex]::Matches($Content, "SizedBox\s*\(\s*width:\s*columnGap\s*\)")).Count

$Content = $Content -replace "SizedBox\s*\(\s*width:\s*columnGap\s*\)", "SizedBox(width: gap)"

$AfterCount = ([regex]::Matches($Content, "SizedBox\s*\(\s*width:\s*columnGap\s*\)")).Count

[System.IO.File]::WriteAllText($Target, $Content, [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "Backup created:" -ForegroundColor Yellow
Write-Host "  $Backup"
Write-Host ""
Write-Host "Replaced occurrences:" -ForegroundColor Green
Write-Host "  Before: $BeforeCount"
Write-Host "  After:  $AfterCount"
Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
