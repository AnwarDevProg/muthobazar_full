# MuthoBazar - Apply Home Grid Tuning Patch V2 From Downloads
# ----------------------------------------------------------
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_home_grid_tuning_from_downloads.ps1
#
# Optional custom ZIP:
# powershell -ExecutionPolicy Bypass -File .\tools\apply_home_grid_tuning_from_downloads.ps1 -ZipPath "C:\Users\1\Downloads\muthobazar_home_grid_tuning_patch_auto_v2.zip"

param(
  [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "MuthoBazar Home Grid Tuning Auto Installer V2" -ForegroundColor Cyan
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

  $Candidates = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_home_grid_tuning_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending

  if ($Candidates.Count -eq 0) {
    throw "No matching ZIP found in Downloads. Expected: muthobazar_home_grid_tuning_patch_auto_v2.zip"
  }

  return $Candidates[0].FullName
}

$PatchZip = Resolve-PatchZip -CustomZipPath $ZipPath
Write-Host "Patch ZIP: $PatchZip" -ForegroundColor Yellow

$TempExtractDir = Join-Path $env:TEMP "muthobazar_home_grid_tuning_patch_v2_$Timestamp"

if (Test-Path -LiteralPath $TempExtractDir) {
  Remove-Item -LiteralPath $TempExtractDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $TempExtractDir | Out-Null

try {
  Write-Host ""
  Write-Host "Extracting ZIP..." -ForegroundColor Yellow
  Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempExtractDir -Force

  $InnerScript = Join-Path $TempExtractDir "tools\patch_home_grid_tuning_params.ps1"

  if (!(Test-Path -LiteralPath $InnerScript)) {
    throw "Inner patch script not found inside ZIP: tools\patch_home_grid_tuning_params.ps1"
  }

  $RepoTools = Join-Path $RepoRoot "tools"
  New-Item -ItemType Directory -Force -Path $RepoTools | Out-Null

  Write-Host "Copying patch tools into repo..." -ForegroundColor Yellow

  $ExtractedTools = Join-Path $TempExtractDir "tools"
  Copy-Item -LiteralPath (Join-Path $ExtractedTools "*") -Destination $RepoTools -Recurse -Force

  $RepoInnerScript = Join-Path $RepoTools "patch_home_grid_tuning_params.ps1"

  if (!(Test-Path -LiteralPath $RepoInnerScript)) {
    throw "Copied inner patch script not found: $RepoInnerScript"
  }

  Write-Host ""
  Write-Host "Running patch script from repo tools..." -ForegroundColor Yellow
  & powershell -ExecutionPolicy Bypass -File $RepoInnerScript

  if ($LASTEXITCODE -ne 0) {
    throw "Inner patch script failed with exit code $LASTEXITCODE"
  }

  Write-Host ""
  Write-Host "Auto patch completed successfully." -ForegroundColor Green
  Write-Host ""
  Write-Host "Next command:" -ForegroundColor Cyan
  Write-Host "flutter analyze"
}
finally {
  if (Test-Path -LiteralPath $TempExtractDir) {
    Write-Host ""
    Write-Host "Cleaning temporary extract folder..." -ForegroundColor Yellow
    Remove-Item -LiteralPath $TempExtractDir -Recurse -Force
  }
}
