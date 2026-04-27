param(
  [string]$ZipPath = ""
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\design_element_position_controls_$Timestamp"
$TempExtract = Join-Path $env:TEMP "muthobazar_design_element_position_controls_$Timestamp"

function Resolve-PatchZip {
  param([string]$CustomZipPath)

  if (![string]::IsNullOrWhiteSpace($CustomZipPath)) {
    if (!(Test-Path -LiteralPath $CustomZipPath)) {
      throw "ZIP not found: $CustomZipPath"
    }
    return (Resolve-Path -LiteralPath $CustomZipPath).Path
  }

  $Downloads = Join-Path $env:USERPROFILE "Downloads"
  $Candidate = Get-ChildItem -LiteralPath $Downloads -Filter "muthobazar_design_element_position_controls_patch*.zip" -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if ($null -eq $Candidate) {
    throw "Could not find muthobazar_design_element_position_controls_patch*.zip in Downloads."
  }

  return $Candidate.FullName
}

function Resolve-PayloadRoot {
  param([string]$ExtractRoot)

  $DirectPayload = Join-Path $ExtractRoot "payload"
  if (Test-Path -LiteralPath $DirectPayload) {
    return $ExtractRoot
  }

  $NestedPayload = Get-ChildItem -LiteralPath $ExtractRoot -Directory |
    ForEach-Object {
      $CandidatePayload = Join-Path $_.FullName "payload"
      if (Test-Path -LiteralPath $CandidatePayload) {
        $_.FullName
      }
    } |
    Select-Object -First 1

  if ($null -ne $NestedPayload) {
    return $NestedPayload
  }

  throw "Could not find a payload folder in extracted ZIP."
}

$PatchZip = Resolve-PatchZip -CustomZipPath $ZipPath

$Targets = @(
  "apps/customer_app/lib/features/chat/pages/chat_page.dart",
  "packages/shared_models/lib/product_cards/design/mb_card_element_position.dart"
)

Write-Host ""
Write-Host "Applying MuthoBazar design element position controls patch..." -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host "Patch ZIP: $PatchZip"
Write-Host ""

Remove-Item -LiteralPath $TempExtract -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
New-Item -ItemType Directory -Force -Path $TempExtract | Out-Null
Expand-Archive -LiteralPath $PatchZip -DestinationPath $TempExtract -Force

$PayloadRoot = Resolve-PayloadRoot -ExtractRoot $TempExtract
Write-Host "Payload root: $PayloadRoot" -ForegroundColor DarkGray

foreach ($RelativePath in $Targets) {
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
  Write-Host "Patched: $RelativePath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Backup folder: $BackupRoot" -ForegroundColor Yellow
Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host "flutter run"

Remove-Item -LiteralPath $TempExtract -Recurse -Force -ErrorAction SilentlyContinue
