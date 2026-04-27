# MuthoBazar - Apply Card Design Studio Shell Patch From Downloads
# ----------------------------------------------------------------
# Extracts the working Chat design lab into a reusable shared_ui widget.
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_card_design_studio_shell_from_downloads.ps1
#
# Optional:
# powershell -ExecutionPolicy Bypass -File .\tools\apply_card_design_studio_shell_from_downloads.ps1 -ZipPath "C:\Users\1\Downloads\muthobazar_card_design_studio_shell_patch.zip"

param(
  [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "MuthoBazar Card Design Studio Shell Patch" -ForegroundColor Cyan
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
  $Candidate = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_card_design_studio_shell_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if ($null -eq $Candidate) {
    throw "Could not find muthobazar_card_design_studio_shell_patch*.zip in Downloads."
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
$TempExtract = Join-Path $env:TEMP "muthobazar_card_design_studio_shell_$Timestamp"
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\card_design_studio_shell_$Timestamp"

$TargetFiles = @(
  "packages/shared_ui/lib/widgets/common/product_cards/design_studio/mb_card_design_studio.dart",
  "apps/customer_app/lib/features/chat/pages/chat_page.dart"
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

  $SharedUiBarrel = Join-Path $RepoRoot "packages\shared_ui\lib\shared_ui.dart"
  if (Test-Path -LiteralPath $SharedUiBarrel) {
    $Backup = Join-Path $BackupRoot "packages\shared_ui\lib\shared_ui.dart"
    New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
    Copy-Item -LiteralPath $SharedUiBarrel -Destination $Backup -Force
    Add-ExportLine -FilePath $SharedUiBarrel -ExportLine "export 'widgets/common/product_cards/design_studio/mb_card_design_studio.dart';"
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
