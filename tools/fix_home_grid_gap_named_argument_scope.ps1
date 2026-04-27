# MuthoBazar - Fix wrongly patched named argument gap: columnGap
# ----------------------------------------------------------------
# Run from repo root:
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\fix_home_grid_gap_named_argument_scope.ps1
#
# Problem:
# flutter analyze reports:
# Undefined name 'columnGap'
# apps/customer_app/lib/features/home/widgets/sections/mb_home_product_grid_section.dart
#
# Cause:
# In the nested _buildRow(...) method, the code should pass the method parameter:
#   gap: gap,
#
# But a previous broad regex patch may have changed it to:
#   gap: columnGap,
#
# columnGap only exists in _ProductCardFlow.build(), not inside _buildRow().

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Target = Join-Path $RepoRoot "apps\customer_app\lib\features\home\widgets\sections\mb_home_product_grid_section.dart"

if (!(Test-Path -LiteralPath $Target)) {
  throw "Target file not found: $Target"
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupDir = Join-Path $RepoRoot "tools\backups\fix_home_grid_gap_named_argument_scope_$Timestamp"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

$Backup = Join-Path $BackupDir "mb_home_product_grid_section.dart.bak"
Copy-Item -LiteralPath $Target -Destination $Backup -Force

$Content = [System.IO.File]::ReadAllText($Target)

# Show all remaining columnGap locations before patch.
Write-Host ""
Write-Host "Existing columnGap references before patch:" -ForegroundColor Yellow
$MatchesBefore = Select-String -LiteralPath $Target -Pattern "columnGap" -AllMatches
if ($MatchesBefore) {
  $MatchesBefore | ForEach-Object {
    Write-Host ("  Line {0}: {1}" -f $_.LineNumber, $_.Line.Trim())
  }
} else {
  Write-Host "  No columnGap references found."
}

$Original = $Content

# 1) Fix the specific wrong call in _buildRow where _HalfWidthPairRow receives gap.
# This intentionally keeps the valid parent call:
#   gap: columnGap,
# inside _ProductCardFlow.build().
$Pattern = "(?s)(_HalfWidthPairRow\s*\([\s\S]*?gap:\s*)columnGap(\s*,[\s\S]*?\))"
$Content = [regex]::Replace(
  $Content,
  $Pattern,
  {
    param($m)
    return $m.Groups[1].Value + "gap" + $m.Groups[2].Value
  },
  1
)

# 2) Safety fallback:
# If any function/method body still has "gap: columnGap," but there is no local
# "columnGap =" nearby above it and there is a "required double gap" parameter,
# replace only the first likely nested occurrence.
if ($Content -eq $Original) {
  $BuildRowStart = $Content.IndexOf("Widget _buildRow(")
  if ($BuildRowStart -ge 0) {
    $NextMarker = $Content.IndexOf("bool _isFullWidthProduct", $BuildRowStart)
    if ($NextMarker -lt 0) {
      $NextMarker = $Content.Length
    }

    $Before = $Content.Substring(0, $BuildRowStart)
    $Segment = $Content.Substring($BuildRowStart, $NextMarker - $BuildRowStart)
    $After = $Content.Substring($NextMarker)

    $SegmentNew = $Segment -replace "gap:\s*columnGap\s*,", "gap: gap,"

    $Content = $Before + $SegmentNew + $After
  }
}

if ($Content -eq $Original) {
  Write-Host ""
  Write-Host "No matching wrong 'gap: columnGap,' occurrence was changed." -ForegroundColor Red
  Write-Host "Please run this to inspect the exact location:" -ForegroundColor Cyan
  Write-Host "Select-String -Path `"$Target`" -Pattern `"columnGap`" -Context 4,4"
  exit 1
}

[System.IO.File]::WriteAllText($Target, $Content, [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "Backup created:" -ForegroundColor Yellow
Write-Host "  $Backup"

Write-Host ""
Write-Host "columnGap references after patch:" -ForegroundColor Green
$MatchesAfter = Select-String -LiteralPath $Target -Pattern "columnGap" -AllMatches
if ($MatchesAfter) {
  $MatchesAfter | ForEach-Object {
    Write-Host ("  Line {0}: {1}" -f $_.LineNumber, $_.Line.Trim())
  }
} else {
  Write-Host "  No columnGap references found."
}

Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
