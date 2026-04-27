# MuthoBazar - Apply Position-Aware Renderer Patch From Downloads
# --------------------------------------------------------------
# This patch makes the hero poster design renderer consume element.position:
# - slot mode
# - free x/y mode
# - z order
# - anchor
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_renderer_position_aware_from_downloads.ps1
#
# Optional:
# powershell -ExecutionPolicy Bypass -File .\tools\apply_renderer_position_aware_from_downloads.ps1 -ZipPath "C:\Users\1\Downloads\muthobazar_renderer_position_aware_patch.zip"

param(
  [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "MuthoBazar Position-Aware Renderer Patch" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host ""

function Resolve-PatchZip {
  param([string]$CustomZipPath)

  if (![string]::IsNullOrWhiteSpace($CustomZipPath)) {
    if (!(Test-Path -LiteralPath $CustomZipPath)) {
      throw "ZIP not found: $CustomZipPath"
    }
    return (Resolve-Path -LiteralPath $CustomZipPath).Path
  }

  $Downloads = Join-Path $env:USERPROFILE "Downloads"
  $Candidate = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_renderer_position_aware_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if ($null -eq $Candidate) {
    throw "Could not find muthobazar_renderer_position_aware_patch*.zip in Downloads."
  }

  return $Candidate.FullName
}

function Resolve-PayloadRoot {
  param([string]$ExtractRoot)

  if (Test-Path -LiteralPath (Join-Path $ExtractRoot "payload")) {
    return $ExtractRoot
  }

  $Nested = Get-ChildItem -LiteralPath $ExtractRoot -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "payload") } |
    Select-Object -First 1

  if ($null -ne $Nested) {
    return $Nested.FullName
  }

  throw "Payload folder not found inside extracted ZIP."
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
    Write-Host "Export already exists: $ExportLine" -ForegroundColor DarkGray
    return
  }

  $NewContent = $Content.TrimEnd() + [Environment]::NewLine + $ExportLine + [Environment]::NewLine
  [System.IO.File]::WriteAllText($FilePath, $NewContent, [System.Text.UTF8Encoding]::new($false))
  Write-Host "Added export: $ExportLine" -ForegroundColor Yellow
}

$PatchZip = Resolve-PatchZip -CustomZipPath $ZipPath
$TempExtract = Join-Path $env:TEMP "muthobazar_renderer_position_aware_$Timestamp"
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\renderer_position_aware_$Timestamp"

$TargetFiles = @(
  "packages/shared_ui/lib/widgets/common/product_cards/design_engine/positioning/mb_design_positioned_element.dart",
  "packages/shared_ui/lib/widgets/common/product_cards/design_engine/templates/hero_poster_circle_diagonal_v1.dart"
)

try {
  Write-Host "Patch ZIP: $PatchZip" -ForegroundColor Yellow

  Remove-Item -LiteralPath $TempExtract -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $TempExtract | Out-Null
  New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null

  Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempExtract -Force
  $PayloadRoot = Resolve-PayloadRoot -ExtractRoot $TempExtract

  foreach ($RelativePath in $TargetFiles) {
    $Source = Join-Path $PayloadRoot ("payload\" + $RelativePath.Replace("/","\"))
    $Target = Join-Path $RepoRoot $RelativePath.Replace("/","\")
    $Backup = Join-Path $BackupRoot $RelativePath.Replace("/","\")

    if (!(Test-Path -LiteralPath $Source)) {
      throw "Payload file missing: $Source"
    }

    if (Test-Path -LiteralPath $Target) {
      New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
      Copy-Item -LiteralPath $Target -Destination $Backup -Force
    }

    New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Target -Force
    Write-Host "Patched: $RelativePath" -ForegroundColor Green
  }

  $Barrel = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_engine\mb_design_card_engine.dart"
  if (Test-Path -LiteralPath $Barrel) {
    $Backup = Join-Path $BackupRoot "packages\shared_ui\lib\widgets\common\product_cards\design_engine\mb_design_card_engine.dart"
    New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
    Copy-Item -LiteralPath $Barrel -Destination $Backup -Force

    Add-ExportLine -FilePath $Barrel -ExportLine "export 'positioning/mb_design_positioned_element.dart';"
  }

  Write-Host ""
  Write-Host "Patch completed." -ForegroundColor Green
  Write-Host "Backup folder:" -ForegroundColor Yellow
  Write-Host "  $BackupRoot"
  Write-Host ""
  Write-Host "Now run:" -ForegroundColor Cyan
  Write-Host "flutter analyze"
  Write-Host "flutter run"
}
finally {
  Remove-Item -LiteralPath $TempExtract -Recurse -Force -ErrorAction SilentlyContinue
}
