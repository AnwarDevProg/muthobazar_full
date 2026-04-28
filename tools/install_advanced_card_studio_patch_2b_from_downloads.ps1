# MuthoBazar Advanced Card Studio Patch 2B installer
# Run from any PowerShell location. It expects the ZIP in your Downloads folder.

$ErrorActionPreference = "Stop"

$RepoRoot = "C:\Users\1\AndroidStudioProjects\MuthoBazar"
$Zip = Get-ChildItem "$env:USERPROFILE\Downloads" -Filter "muthobazar_advanced_card_studio_patch_2b*.zip" |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $Zip) {
  throw "Patch 2B ZIP not found in Downloads. Download muthobazar_advanced_card_studio_patch_2b.zip first."
}

$Temp = Join-Path $env:TEMP ("mb_advanced_card_patch_2b_" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $Temp -Force | Out-Null

Expand-Archive -Path $Zip.FullName -DestinationPath $Temp -Force

$SourceAdvanced = Get-ChildItem $Temp -Directory -Recurse |
  Where-Object { $_.Name -eq "design_studio_advanced" } |
  Select-Object -First 1

if (-not $SourceAdvanced) {
  throw "Could not find design_studio_advanced inside Patch 2B ZIP."
}

$TargetProductCards = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards"
$TargetAdvanced = Join-Path $TargetProductCards "design_studio_advanced"

if (-not (Test-Path $TargetProductCards)) {
  throw "Target product_cards folder not found: $TargetProductCards"
}

$BackupRoot = Join-Path $RepoRoot ("_backup_advanced_card_patch_2b_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null

if (Test-Path $TargetAdvanced) {
  Copy-Item $TargetAdvanced (Join-Path $BackupRoot "design_studio_advanced") -Recurse -Force
  Remove-Item $TargetAdvanced -Recurse -Force
}

Copy-Item $SourceAdvanced.FullName $TargetProductCards -Recurse -Force

Write-Host "Advanced Card Studio Patch 2B installed successfully." -ForegroundColor Green
Write-Host "Target: $TargetAdvanced"
Write-Host "Backup: $BackupRoot"
Write-Host ""
Write-Host "Run this from repo root next:" -ForegroundColor Cyan
Write-Host "flutter analyze packages/shared_ui"
Write-Host "flutter run -d web-server --web-hostname localhost --web-port 8080"

Test-Path $TargetAdvanced
