# MuthoBazar - Apply Design Preview V1 Patch From Downloads
# --------------------------------------------------------
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_design_preview_v1_from_downloads.ps1
#
# Optional:
# powershell -ExecutionPolicy Bypass -File .\tools\apply_design_preview_v1_from_downloads.ps1 -ZipPath "C:\Users\1\Downloads\muthobazar_design_preview_v1_patch.zip"

param(
  [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "MuthoBazar Design Preview V1 Patch" -ForegroundColor Cyan
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
  $Candidates = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_design_preview_v1_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending

  if ($Candidates.Count -eq 0) {
    throw "No matching ZIP found in Downloads. Expected: muthobazar_design_preview_v1_patch.zip"
  }

  return $Candidates[0].FullName
}

function Add-ExportLine {
  param(
    [string]$FilePath,
    [string]$ExportLine
  )

  if (!(Test-Path -LiteralPath $FilePath)) {
    return
  }

  $Content = [System.IO.File]::ReadAllText($FilePath)
  if ($Content.Contains($ExportLine)) {
    Write-Host "  export already exists: $FilePath"
    return
  }

  $NewContent = $Content.TrimEnd() + [Environment]::NewLine + $ExportLine + [Environment]::NewLine
  [System.IO.File]::WriteAllText($FilePath, $NewContent, [System.Text.UTF8Encoding]::new($false))
  Write-Host "  export added: $FilePath"
}

$PatchZip = Resolve-PatchZip -CustomZipPath $ZipPath
$TempExtractDir = Join-Path $env:TEMP "muthobazar_design_preview_v1_$Timestamp"
$BackupDir = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\design_preview_v1_$Timestamp"

$EngineTargetDir = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_engine"
$PayloadEngineDir = Join-Path $TempExtractDir "payload\packages\shared_ui\lib\widgets\common\product_cards\design_engine"

try {
  Write-Host "Patch ZIP: $PatchZip" -ForegroundColor Yellow

  Remove-Item -LiteralPath $TempExtractDir -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $TempExtractDir | Out-Null
  New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

  Write-Host ""
  Write-Host "Extracting ZIP..." -ForegroundColor Yellow
  Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempExtractDir -Force

  if (!(Test-Path -LiteralPath $PayloadEngineDir)) {
    throw "Payload design preview folder missing: $PayloadEngineDir"
  }

  $FilesToBackup = @(
    "packages\shared_ui\lib\widgets\common\product_cards\design_engine\mb_design_card_default_configs.dart",
    "packages\shared_ui\lib\widgets\common\product_cards\design_engine\preview\mb_design_card_mobile_preview_frame.dart",
    "packages\shared_ui\lib\widgets\common\product_cards\design_engine\preview\mb_design_card_preview_panel.dart",
    "packages\shared_ui\lib\widgets\common\product_cards\design_engine\mb_design_card_engine.dart"
  )

  Write-Host "Creating backup outside repo..." -ForegroundColor Yellow
  foreach ($Rel in $FilesToBackup) {
    $Target = Join-Path $RepoRoot $Rel
    if (Test-Path -LiteralPath $Target) {
      $Backup = Join-Path $BackupDir $Rel
      New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
      Copy-Item -LiteralPath $Target -Destination $Backup -Force
      Write-Host "  $Backup"
    }
  }

  Write-Host ""
  Write-Host "Copying preview files..." -ForegroundColor Yellow
  New-Item -ItemType Directory -Force -Path $EngineTargetDir | Out-Null
  Copy-Item -Path "$PayloadEngineDir\*" -Destination $EngineTargetDir -Recurse -Force

  $Barrel = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_engine\mb_design_card_engine.dart"

  Write-Host ""
  Write-Host "Updating design engine barrel..." -ForegroundColor Yellow
  Add-ExportLine -FilePath $Barrel -ExportLine "export 'mb_design_card_default_configs.dart';"
  Add-ExportLine -FilePath $Barrel -ExportLine "export 'preview/mb_design_card_mobile_preview_frame.dart';"
  Add-ExportLine -FilePath $Barrel -ExportLine "export 'preview/mb_design_card_preview_panel.dart';"

  Write-Host ""
  Write-Host "Patch completed." -ForegroundColor Green
  Write-Host "Backup folder:" -ForegroundColor Yellow
  Write-Host "  $BackupDir"
  Write-Host ""
  Write-Host "Now run:" -ForegroundColor Cyan
  Write-Host "flutter analyze"
}
finally {
  if (Test-Path -LiteralPath $TempExtractDir) {
    Write-Host ""
    Write-Host "Cleaning temporary extract folder..." -ForegroundColor Yellow
    Remove-Item -LiteralPath $TempExtractDir -Recurse -Force
  }
}
