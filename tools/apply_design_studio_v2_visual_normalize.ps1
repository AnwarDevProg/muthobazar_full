# MuthoBazar - Apply Design Studio V2 Visual Normalize Patch
# ----------------------------------------------------------
# Fixes abnormal V2 preview where price/button/delivery nodes can look like
# giant bubbles because old imported sizes are not safe for node rendering.
#
# Replaces:
# packages/shared_ui/lib/widgets/common/product_cards/design_studio_v2/panels/mb_design_canvas_panel.dart
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_design_studio_v2_visual_normalize.ps1
# flutter analyze

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$TempRoot = Join-Path $env:TEMP "muthobazar_design_studio_v2_visual_normalize_$Timestamp"
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\design_studio_v2_visual_normalize_$Timestamp"

Write-Host ""
Write-Host "MuthoBazar Design Studio V2 Visual Normalize Patch" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host ""

function Find-PatchZip {
  $Downloads = Join-Path $env:USERPROFILE "Downloads"
  $Candidate = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_design_studio_v2_visual_normalize_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if ($null -eq $Candidate) {
    throw "Could not find muthobazar_design_studio_v2_visual_normalize_patch*.zip in Downloads."
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

$PatchZip = Find-PatchZip
Write-Host "Patch ZIP: $PatchZip" -ForegroundColor Yellow

Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null
New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null

try {
  Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempRoot -Force
  $PayloadRoot = Resolve-PayloadRoot -ExtractRoot $TempRoot

  $RelativePath = "packages/shared_ui/lib/widgets/common/product_cards/design_studio_v2/panels/mb_design_canvas_panel.dart"
  $Source = Join-Path $PayloadRoot ("payload\" + $RelativePath.Replace("/","\"))
  $Target = Join-Path $RepoRoot $RelativePath.Replace("/","\")

  if (!(Test-Path -LiteralPath $Source)) {
    throw "Payload file missing: $Source"
  }

  Backup-File -Path $Target
  New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
  Copy-Item -LiteralPath $Source -Destination $Target -Force
  Write-Host "Patched: $RelativePath" -ForegroundColor Green

  Write-Host ""
  Write-Host "Patch completed." -ForegroundColor Green
  Write-Host "Backup folder:" -ForegroundColor Yellow
  Write-Host "  $BackupRoot"
  Write-Host ""
  Write-Host "Now run:" -ForegroundColor Cyan
  Write-Host "flutter analyze"
  Write-Host ""
  Write-Host "Then fully restart admin web."
  Write-Host ""
  Write-Host "Verify:"
  Write-Host 'Select-String -Path .\packages\shared_ui\lib\widgets\common\product_cards\design_studio_v2\panels\mb_design_canvas_panel.dart -Pattern "Visual Normalized Canvas|_CardBasePainter|_sizeLimits"'
}
finally {
  Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
}
