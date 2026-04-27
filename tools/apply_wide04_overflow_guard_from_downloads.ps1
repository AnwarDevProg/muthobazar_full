# MuthoBazar - Apply wide04 overflow guard patch
# ------------------------------------------------
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_wide04_overflow_guard_from_downloads.ps1
#
# Optional:
# powershell -ExecutionPolicy Bypass -File .\tools\apply_wide04_overflow_guard_from_downloads.ps1 -ZipPath "C:\Users\1\Downloads\muthobazar_wide04_overflow_guard_patch.zip"

param(
  [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "MuthoBazar wide04 overflow guard patch" -ForegroundColor Cyan
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

  $Candidates = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_wide04_overflow_guard_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending

  if ($Candidates.Count -eq 0) {
    throw "No matching ZIP found in Downloads. Expected: muthobazar_wide04_overflow_guard_patch.zip"
  }

  return $Candidates[0].FullName
}

$PatchZip = Resolve-PatchZip -CustomZipPath $ZipPath
$TempExtractDir = Join-Path $env:TEMP "muthobazar_wide04_overflow_guard_$Timestamp"
$BackupDir = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\wide04_overflow_guard_$Timestamp"

$ResolverRel = "packages\shared_ui\lib\widgets\common\product_cards\system\mb_product_card_layout_resolver.dart"
$ResolverPath = Join-Path $RepoRoot $ResolverRel

try {
  Write-Host "Patch ZIP: $PatchZip" -ForegroundColor Yellow

  if (!(Test-Path -LiteralPath $ResolverPath)) {
    throw "Resolver file not found: $ResolverPath"
  }

  Remove-Item -LiteralPath $TempExtractDir -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $TempExtractDir | Out-Null
  New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

  Write-Host ""
  Write-Host "Extracting ZIP..." -ForegroundColor Yellow
  Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempExtractDir -Force

  Write-Host "Creating backup outside repo..." -ForegroundColor Yellow
  $Backup = Join-Path $BackupDir $ResolverRel
  New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
  Copy-Item -LiteralPath $ResolverPath -Destination $Backup -Force
  Write-Host "  $Backup"

  $Content = [System.IO.File]::ReadAllText($ResolverPath)
  $Original = $Content

  # Patch only the wide-family safe-layout block. The previous guard capped
  # wide04 at 360, which can give the actual inner Column around 358 px after
  # decoration/padding rounding. That produced a tiny 0.0914 px overflow.
  #
  # New cap gives 8 px safety headroom while keeping wide cards controlled.
  $Content = $Content -replace "aspectRatio:\s*1\.16,\s*`r?`n\s*fallbackPreferredHeight:\s*310,\s*`r?`n\s*minContentHeight:\s*260,\s*`r?`n\s*maxContentHeight:\s*360,", "aspectRatio: 1.16,`r`n        fallbackPreferredHeight: 318,`r`n        minContentHeight: 260,`r`n        maxContentHeight: 368,"

  if ($Content -eq $Original) {
    # Fallback for slightly different formatting.
    $Pattern = "(?s)(if\s*\(family\s*==\s*'wide'\s*\|\|\s*variant\.startsWith\('wide'\)\)\s*\{\s*return\s+_byWidth\(\s*aspectRatio:\s*1\.16,\s*fallbackPreferredHeight:\s*)\d+(\s*,\s*minContentHeight:\s*)\d+(\s*,\s*maxContentHeight:\s*)\d+"
    $Content = [regex]::Replace(
      $Content,
      $Pattern,
      {
        param($m)
        return $m.Groups[1].Value + "318" + $m.Groups[2].Value + "260" + $m.Groups[3].Value + "368"
      },
      1
    )
  }

  if ($Content -eq $Original) {
    Write-Host ""
    Write-Host "Could not find the wide04/wide safe-layout block to patch." -ForegroundColor Red
    Write-Host "Please inspect this file manually:" -ForegroundColor Yellow
    Write-Host "  $ResolverPath"
    exit 1
  }

  [System.IO.File]::WriteAllText($ResolverPath, $Content, [System.Text.UTF8Encoding]::new($false))

  Write-Host ""
  Write-Host "Patch completed." -ForegroundColor Green
  Write-Host "Changed wide safe layout:" -ForegroundColor Cyan
  Write-Host "  fallbackPreferredHeight: 310 -> 318"
  Write-Host "  maxContentHeight:       360 -> 368"
  Write-Host ""
  Write-Host "Backup folder:" -ForegroundColor Yellow
  Write-Host "  $BackupDir"
  Write-Host ""
  Write-Host "Now run:" -ForegroundColor Cyan
  Write-Host "flutter analyze"
  Write-Host ""
  Write-Host "Then full restart customer app and check [CARD_LAYOUT_DEBUG] for Potato/wide04."
  Write-Host "Expected resolved height should move from 360.0 to 368.0."
}
finally {
  if (Test-Path -LiteralPath $TempExtractDir) {
    Write-Host ""
    Write-Host "Cleaning temporary extract folder..." -ForegroundColor Yellow
    Remove-Item -LiteralPath $TempExtractDir -Recurse -Force
  }
}
