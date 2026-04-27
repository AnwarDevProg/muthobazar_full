# MuthoBazar - Fix duplicate Dropdown value "center"
# --------------------------------------------------
# Fixes runtime assertion:
# There should be exactly one item with [DropdownButton]'s value: center.
#
# Cause:
# ChatPage _alignmentOptions contains "center" twice.
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\fix_dropdown_duplicate_center.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$TargetRel = "apps\customer_app\lib\features\chat\pages\chat_page.dart"
$Target = Join-Path $RepoRoot $TargetRel
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\fix_dropdown_duplicate_center_$Timestamp"
$Backup = Join-Path $BackupRoot $TargetRel

Write-Host ""
Write-Host "MuthoBazar Fix Dropdown Duplicate Center" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host ""

if (!(Test-Path -LiteralPath $Target)) {
  throw "Target file not found: $Target"
}

New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
Copy-Item -LiteralPath $Target -Destination $Backup -Force

$Content = [System.IO.File]::ReadAllText($Target)

$Pattern = "static const List<String> _alignmentOptions = <String>\[\]\s*;"
# Not used; kept for readability.

$BlockPattern = "static const List<String> _alignmentOptions = <String>\[\]\s*;"

$Regex = [regex]"static const List<String> _alignmentOptions = <String>\[\]\s*;"
$Replacement = ""

# Replace the actual multiline _alignmentOptions block.
$MultiRegex = [regex]"static const List<String> _alignmentOptions = <String>\[\]\s*;"
# Fallback not used.

$NewAlignmentBlock = @'
  static const List<String> _alignmentOptions = <String>[
    'start',
    'center',
    'end',
    'topLeft',
    'topCenter',
    'topRight',
    'centerLeft',
    'centerRight',
    'bottomLeft',
    'bottomCenter',
    'bottomRight',
  ];
'@

$BlockRegex = [regex]"  static const List<String> _alignmentOptions = <String>\[\s*'start',\s*'center',\s*'end',\s*'topLeft',\s*'topCenter',\s*'topRight',\s*'centerLeft',\s*'center',\s*'centerRight',\s*'bottomLeft',\s*'bottomCenter',\s*'bottomRight',\s*\];"

if ($BlockRegex.IsMatch($Content)) {
  $Content = $BlockRegex.Replace($Content, $NewAlignmentBlock, 1)
  [System.IO.File]::WriteAllText($Target, $Content, [System.Text.UTF8Encoding]::new($false))

  Write-Host "Patched duplicate 'center' in _alignmentOptions." -ForegroundColor Green
  Write-Host "Backup:" -ForegroundColor Yellow
  Write-Host "  $Backup"
  Write-Host ""
  Write-Host "Now run:" -ForegroundColor Cyan
  Write-Host "flutter analyze"
  Write-Host "Then stop and rerun the app."
  exit 0
}

# More tolerant fallback: find alignment block and remove duplicate center after centerLeft.
$FallbackRegex = [regex]"(?s)  static const List<String> _alignmentOptions = <String>\[\s*(.*?)\s*  \];"
$Match = $FallbackRegex.Match($Content)

if (!$Match.Success) {
  throw "Could not find _alignmentOptions block in chat_page.dart"
}

$Block = $Match.Value
$FixedBlock = $Block -replace "\s*'center',\s*(\r?\n\s*'centerRight',)", "`r`n    `$1"

if ($FixedBlock -eq $Block) {
  throw "Found _alignmentOptions block but could not remove duplicate center safely."
}

$Content = $Content.Substring(0, $Match.Index) + $FixedBlock + $Content.Substring($Match.Index + $Match.Length)
[System.IO.File]::WriteAllText($Target, $Content, [System.Text.UTF8Encoding]::new($false))

Write-Host "Patched duplicate 'center' in _alignmentOptions using fallback." -ForegroundColor Green
Write-Host "Backup:" -ForegroundColor Yellow
Write-Host "  $Backup"
Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host "Then stop and rerun the app."
