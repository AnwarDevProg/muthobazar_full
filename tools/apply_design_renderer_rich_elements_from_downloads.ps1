# MuthoBazar - Apply Rich Elements Design Renderer Patch From Downloads
# --------------------------------------------------------------------
# Upgrades the new design-family renderer so the hero poster card
# shows many more visible design elements during design phase.
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_design_renderer_rich_elements_from_downloads.ps1
#
# Optional:
# powershell -ExecutionPolicy Bypass -File .\tools\apply_design_renderer_rich_elements_from_downloads.ps1 -ZipPath "C:\Users\1\Downloads\muthobazar_design_renderer_rich_elements_patch.zip"

param(
  [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "MuthoBazar Design Renderer Rich Elements Patch" -ForegroundColor Cyan
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

  $Candidates = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_design_renderer_rich_elements_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending

  if ($Candidates.Count -eq 0) {
    throw "No matching ZIP found in Downloads. Expected: muthobazar_design_renderer_rich_elements_patch.zip"
  }

  return $Candidates[0].FullName
}

$PatchZip = Resolve-PatchZip -CustomZipPath $ZipPath
$TempExtractDir = Join-Path $env:TEMP "muthobazar_design_renderer_rich_elements_$Timestamp"
$BackupDir = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\design_renderer_rich_elements_$Timestamp"

$TargetFiles = @(
  "packages\shared_models\lib\product_cards\design\mb_card_design_registry.dart",
  "packages\shared_ui\lib\widgets\common\product_cards\design_engine\mb_design_card_context.dart",
  "packages\shared_ui\lib\widgets\common\product_cards\design_engine\templates\hero_poster_circle_diagonal_v1.dart",
  "apps\customer_app\lib\features\chat\pages\chat_page.dart"
)

try {
  Write-Host "Patch ZIP: $PatchZip" -ForegroundColor Yellow

  foreach ($rel in $TargetFiles) {
    $target = Join-Path $RepoRoot $rel
    if (!(Test-Path -LiteralPath $target)) {
      throw "Target file not found: $target"
    }
  }

  Remove-Item -LiteralPath $TempExtractDir -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $TempExtractDir | Out-Null
  New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

  Write-Host ""
  Write-Host "Extracting ZIP..." -ForegroundColor Yellow
  Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempExtractDir -Force

  foreach ($rel in $TargetFiles) {
    $source = Join-Path $TempExtractDir ("payload\" + $rel)
    $target = Join-Path $RepoRoot $rel
    $backup = Join-Path $BackupDir $rel

    if (!(Test-Path -LiteralPath $source)) {
      throw "Payload source missing: $source"
    }

    New-Item -ItemType Directory -Force -Path (Split-Path $backup) | Out-Null
    Copy-Item -LiteralPath $target -Destination $backup -Force

    New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
    Copy-Item -LiteralPath $source -Destination $target -Force

    Write-Host "Patched: $rel" -ForegroundColor Green
  }

  Write-Host ""
  Write-Host "Patch completed." -ForegroundColor Green
  Write-Host "Backup folder:" -ForegroundColor Yellow
  Write-Host "  $BackupDir"
  Write-Host ""
  Write-Host "Now run:" -ForegroundColor Cyan
  Write-Host "flutter analyze"
  Write-Host "flutter run -d web-server --web-hostname localhost --web-port 8080"
}
finally {
  if (Test-Path -LiteralPath $TempExtractDir) {
    Write-Host ""
    Write-Host "Cleaning temporary extract folder..." -ForegroundColor Yellow
    Remove-Item -LiteralPath $TempExtractDir -Recurse -Force
  }
}
