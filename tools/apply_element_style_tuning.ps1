# MuthoBazar - Element Style Tuning Patch
# --------------------------------------
# Adds per-element style tuning to the New Design Studio.
#
# New JSON key:
#   elementStyles
#
# Supported style fields:
# - textColorHex
# - backgroundHex
# - borderHex
# - shadowHex
# - fontSize
# - fontWeight
# - fontStyle
# - textAlign
# - borderRadius
# - borderWidth
# - paddingX / paddingY
# - shadowOpacity / shadowBlur / shadowDy
# - ringWidth
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_element_style_tuning.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$TempRoot = Join-Path $env:TEMP "muthobazar_element_style_tuning_$Timestamp"
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\element_style_tuning_$Timestamp"

Write-Host ""
Write-Host "MuthoBazar Element Style Tuning Patch" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host ""

function Find-PatchZip {
  $Downloads = Join-Path $env:USERPROFILE "Downloads"
  $Candidate = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_element_style_tuning_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if ($null -eq $Candidate) {
    throw "Could not find muthobazar_element_style_tuning_patch*.zip in Downloads."
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

  throw "Payload folder not found."
}

function Backup-File {
  param([string]$Path)

  if (!(Test-Path -LiteralPath $Path)) {
    return
  }

  $Relative = $Path.Substring($RepoRoot.Length).TrimStart('\')
  $Backup = Join-Path $BackupRoot $Relative
  New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
  Copy-Item -LiteralPath $Path -Destination $Backup -Force
  Write-Host "Backup: $Backup" -ForegroundColor DarkGray
}

function Add-ExportLine {
  param([string]$FilePath, [string]$ExportLine)

  if (!(Test-Path -LiteralPath $FilePath)) {
    return
  }

  $Content = [System.IO.File]::ReadAllText($FilePath)

  if ($Content.Contains($ExportLine)) {
    Write-Host "Export already exists: $ExportLine" -ForegroundColor DarkGray
    return
  }

  Backup-File -Path $FilePath
  $NewContent = $Content.TrimEnd() + [Environment]::NewLine + $ExportLine + [Environment]::NewLine
  [System.IO.File]::WriteAllText($FilePath, $NewContent, [System.Text.UTF8Encoding]::new($false))
  Write-Host "Added export: $ExportLine" -ForegroundColor Yellow
}

$PatchZip = Find-PatchZip
Write-Host "Patch ZIP: $PatchZip" -ForegroundColor Yellow

Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null
New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null

try {
  Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempRoot -Force
  $PayloadRoot = Resolve-PayloadRoot -ExtractRoot $TempRoot

  $TargetFiles = @(
    "packages/shared_ui/lib/widgets/common/product_cards/design_engine/mb_design_element_runtime_style.dart",
    "packages/shared_ui/lib/widgets/common/product_cards/design_engine/mb_saved_design_card_config_resolver.dart",
    "packages/shared_ui/lib/widgets/common/product_cards/design_engine/elements/mb_design_text_element.dart",
    "packages/shared_ui/lib/widgets/common/product_cards/design_engine/elements/mb_design_cta_element.dart",
    "packages/shared_ui/lib/widgets/common/product_cards/design_engine/elements/mb_design_badge_element.dart",
    "packages/shared_ui/lib/widgets/common/product_cards/design_engine/elements/mb_design_price_element.dart",
    "packages/shared_ui/lib/widgets/common/product_cards/design_engine/elements/mb_design_media_element.dart",
    "packages/shared_ui/lib/widgets/common/product_cards/design_engine/templates/hero_poster_circle_diagonal_v1.dart",
    "packages/shared_ui/lib/widgets/common/product_cards/design_studio/mb_card_design_studio.dart"
  )

  foreach ($RelativePath in $TargetFiles) {
    $Source = Join-Path $PayloadRoot ("payload\" + $RelativePath.Replace("/","\"))
    $Target = Join-Path $RepoRoot $RelativePath.Replace("/","\")

    if (!(Test-Path -LiteralPath $Source)) {
      throw "Payload file missing: $Source"
    }

    Backup-File -Path $Target
    New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Target -Force
    Write-Host "Patched: $RelativePath" -ForegroundColor Green
  }

  Add-ExportLine `
    -FilePath (Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_engine\mb_design_card_engine.dart") `
    -ExportLine "export 'mb_design_element_runtime_style.dart';"

  Add-ExportLine `
    -FilePath (Join-Path $RepoRoot "packages\shared_ui\lib\shared_ui.dart") `
    -ExportLine "export 'widgets/common/product_cards/design_engine/mb_design_element_runtime_style.dart';"

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
  Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
}
