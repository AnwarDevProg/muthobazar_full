# MuthoBazar - Apply Card Design Models V1 Patch From Downloads
# ------------------------------------------------------------
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_card_design_models_v1_from_downloads.ps1
#
# Optional:
# powershell -ExecutionPolicy Bypass -File .\tools\apply_card_design_models_v1_from_downloads.ps1 -ZipPath "C:\Users\1\Downloads\muthobazar_card_design_models_v1_patch.zip"

param(
  [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "MuthoBazar Card Design Models V1 Patch" -ForegroundColor Cyan
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

  $Candidates = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_card_design_models_v1_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending

  if ($Candidates.Count -eq 0) {
    throw "No matching ZIP found in Downloads. Expected: muthobazar_card_design_models_v1_patch.zip"
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
$TempExtractDir = Join-Path $env:TEMP "muthobazar_card_design_models_v1_$Timestamp"
$BackupDir = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\card_design_models_v1_$Timestamp"

$DesignTargetDir = Join-Path $RepoRoot "packages\shared_models\lib\product_cards\design"
$PayloadDesignDir = Join-Path $TempExtractDir "payload\packages\shared_models\lib\product_cards\design"

try {
  Write-Host "Patch ZIP: $PatchZip" -ForegroundColor Yellow

  Remove-Item -LiteralPath $TempExtractDir -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $TempExtractDir | Out-Null
  New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

  Write-Host ""
  Write-Host "Extracting ZIP..." -ForegroundColor Yellow
  Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempExtractDir -Force

  if (!(Test-Path -LiteralPath $PayloadDesignDir)) {
    throw "Payload design folder missing: $PayloadDesignDir"
  }

  Write-Host "Creating backups outside repo..." -ForegroundColor Yellow

  if (Test-Path -LiteralPath $DesignTargetDir) {
    $DesignBackupDir = Join-Path $BackupDir "packages\shared_models\lib\product_cards\design"
    New-Item -ItemType Directory -Force -Path (Split-Path $DesignBackupDir) | Out-Null
    Copy-Item -LiteralPath $DesignTargetDir -Destination $DesignBackupDir -Recurse -Force
    Write-Host "  $DesignBackupDir"
  }

  $SharedModelsBarrel = Join-Path $RepoRoot "packages\shared_models\lib\shared_models.dart"
  $ProductCardsBarrel = Join-Path $RepoRoot "packages\shared_models\lib\product_cards\product_cards.dart"

  foreach ($Barrel in @($SharedModelsBarrel, $ProductCardsBarrel)) {
    if (Test-Path -LiteralPath $Barrel) {
      $BackupPath = Join-Path $BackupDir ($Barrel.Substring($RepoRoot.Length).TrimStart('\', '/'))
      New-Item -ItemType Directory -Force -Path (Split-Path $BackupPath) | Out-Null
      Copy-Item -LiteralPath $Barrel -Destination $BackupPath -Force
      Write-Host "  $BackupPath"
    }
  }

  Write-Host ""
  Write-Host "Copying design model files..." -ForegroundColor Yellow
  New-Item -ItemType Directory -Force -Path $DesignTargetDir | Out-Null
  Copy-Item -Path "$PayloadDesignDir\*" -Destination $DesignTargetDir -Recurse -Force

  Write-Host ""
  Write-Host "Updating exports if barrel files exist..." -ForegroundColor Yellow
  Add-ExportLine -FilePath $SharedModelsBarrel -ExportLine "export 'product_cards/design/mb_card_design_models.dart';"
  Add-ExportLine -FilePath $ProductCardsBarrel -ExportLine "export 'design/mb_card_design_models.dart';"

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
