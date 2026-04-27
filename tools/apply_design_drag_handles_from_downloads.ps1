# MuthoBazar - Apply Design Drag Handles Patch From Downloads
# ----------------------------------------------------------
# Adds visual drag handles to the Chat design lab preview.
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_design_drag_handles_from_downloads.ps1
#
# Optional:
# powershell -ExecutionPolicy Bypass -File .\tools\apply_design_drag_handles_from_downloads.ps1 -ZipPath "C:\Users\1\Downloads\muthobazar_design_drag_handles_patch.zip"

param(
  [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "MuthoBazar Design Drag Handles Patch" -ForegroundColor Cyan
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
  $Candidate = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_design_drag_handles_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if ($null -eq $Candidate) {
    throw "Could not find muthobazar_design_drag_handles_patch*.zip in Downloads."
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

$PatchZip = Resolve-PatchZip -CustomZipPath $ZipPath
$TempExtract = Join-Path $env:TEMP "muthobazar_design_drag_handles_$Timestamp"
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\design_drag_handles_$Timestamp"

$TargetRel = "apps/customer_app/lib/features/chat/pages/chat_page.dart"
$Target = Join-Path $RepoRoot $TargetRel.Replace("/", "\")

try {
  Write-Host "Patch ZIP: $PatchZip" -ForegroundColor Yellow

  Remove-Item -LiteralPath $TempExtract -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $TempExtract | Out-Null
  New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null

  Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempExtract -Force
  $PayloadRoot = Resolve-PayloadRoot -ExtractRoot $TempExtract

  $Source = Join-Path $PayloadRoot ("payload\" + $TargetRel.Replace("/", "\"))
  $Backup = Join-Path $BackupRoot $TargetRel.Replace("/", "\")

  if (!(Test-Path -LiteralPath $Source)) {
    throw "Payload file missing: $Source"
  }

  if (Test-Path -LiteralPath $Target) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
    Copy-Item -LiteralPath $Target -Destination $Backup -Force
  }

  New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
  Copy-Item -LiteralPath $Source -Destination $Target -Force

  Write-Host ""
  Write-Host "Patched:" -ForegroundColor Green
  Write-Host "  $TargetRel"
  Write-Host ""
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
