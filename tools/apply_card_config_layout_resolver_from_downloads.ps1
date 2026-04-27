# MuthoBazar - Apply Card Config Layout Resolver Patch From Downloads
# ------------------------------------------------------------------
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_card_config_layout_resolver_from_downloads.ps1
#
# Optional:
# powershell -ExecutionPolicy Bypass -File .\tools\apply_card_config_layout_resolver_from_downloads.ps1 -ZipPath "C:\Users\1\Downloads\muthobazar_card_config_layout_resolver_patch.zip"

param(
  [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "MuthoBazar Card Config Layout Resolver Auto Installer" -ForegroundColor Cyan
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

  $Candidates = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_card_config_layout_resolver_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending

  if ($Candidates.Count -eq 0) {
    throw "No matching ZIP found in Downloads. Expected: muthobazar_card_config_layout_resolver_patch.zip"
  }

  return $Candidates[0].FullName
}

$PatchZip = Resolve-PatchZip -CustomZipPath $ZipPath
Write-Host "Patch ZIP: $PatchZip" -ForegroundColor Yellow

$TempExtractDir = Join-Path $env:TEMP "muthobazar_card_config_layout_resolver_$Timestamp"

if (Test-Path -LiteralPath $TempExtractDir) {
  Remove-Item -LiteralPath $TempExtractDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $TempExtractDir | Out-Null

try {
  Write-Host ""
  Write-Host "Extracting ZIP..." -ForegroundColor Yellow
  Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempExtractDir -Force

  $InnerScript = Join-Path $TempExtractDir "tools\patch_card_config_layout_resolver.ps1"

  if (!(Test-Path -LiteralPath $InnerScript)) {
    throw "Inner patch script not found inside ZIP."
  }

  Write-Host ""
  Write-Host "Running patch..." -ForegroundColor Yellow
  & powershell -ExecutionPolicy Bypass -File $InnerScript -RepoRoot $RepoRoot

  if ($LASTEXITCODE -ne 0) {
    throw "Inner patch failed with exit code $LASTEXITCODE"
  }

  Write-Host ""
  Write-Host "Auto patch completed successfully." -ForegroundColor Green
  Write-Host ""
  Write-Host "Next:" -ForegroundColor Cyan
  Write-Host "flutter analyze"
}
finally {
  if (Test-Path -LiteralPath $TempExtractDir) {
    Write-Host ""
    Write-Host "Cleaning temporary extract folder..." -ForegroundColor Yellow
    Remove-Item -LiteralPath $TempExtractDir -Recurse -Force
  }
}
