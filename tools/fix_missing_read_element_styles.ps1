# MuthoBazar - Fix Missing _readElementStyles
# -------------------------------------------
# Fixes compile error:
# The method '_readElementStyles' isn't defined for the type '_MBCardDesignStudioState'.
#
# Cause:
# Element Style Tuning patch added import usage in _tryImportDesignJson()
# but missed the helper method.
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\fix_missing_read_element_styles.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$TargetRel = "packages\shared_ui\lib\widgets\common\product_cards\design_studio\mb_card_design_studio.dart"
$Target = Join-Path $RepoRoot $TargetRel
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\fix_missing_read_element_styles_$Timestamp"
$Backup = Join-Path $BackupRoot $TargetRel

Write-Host ""
Write-Host "MuthoBazar - Fix Missing _readElementStyles" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host ""

if (!(Test-Path -LiteralPath $Target)) {
  throw "Target file not found: $Target"
}

New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
Copy-Item -LiteralPath $Target -Destination $Backup -Force

$Text = [System.IO.File]::ReadAllText($Target)

if ($Text.Contains("static Map<String, Map<String, Object?>> _readElementStyles(")) {
  Write-Host "_readElementStyles already exists. Nothing to patch." -ForegroundColor Yellow
  Write-Host "Backup:" -ForegroundColor Yellow
  Write-Host "  $Backup"
  exit 0
}

$Needle = @'
  static final MBProduct _fallbackProduct = MBProduct.fromMap(
'@

if (!$Text.Contains($Needle)) {
  throw "Could not find insertion point: static final MBProduct _fallbackProduct"
}

$Method = @'
  static Map<String, Map<String, Object?>> _readElementStyles(Object? value) {
    final map = _readMap(value);
    final result = <String, Map<String, Object?>>{};

    for (final entry in map.entries) {
      final elementId = entry.key.toString().trim();
      final rawStyle = entry.value;

      if (elementId.isEmpty || rawStyle is! Map) {
        continue;
      }

      final style = <String, Object?>{};
      final rawMap = _readMap(rawStyle);

      for (final styleEntry in rawMap.entries) {
        final key = styleEntry.key.toString().trim();
        final item = styleEntry.value;

        if (key.isEmpty) {
          continue;
        }

        if (item == null) {
          continue;
        }

        if (item is String && item.trim().isEmpty) {
          continue;
        }

        style[key] = item;
      }

      if (style.isNotEmpty) {
        result[elementId] = style;
      }
    }

    return result;
  }

'@

$Text = $Text.Replace($Needle, $Method + $Needle)

[System.IO.File]::WriteAllText($Target, $Text, [System.Text.UTF8Encoding]::new($false))

Write-Host "Patched successfully." -ForegroundColor Green
Write-Host "Added _readElementStyles helper." -ForegroundColor Green
Write-Host ""
Write-Host "Backup:" -ForegroundColor Yellow
Write-Host "  $Backup"
Write-Host ""
Write-Host "Verify:" -ForegroundColor Cyan
Write-Host 'Select-String -Path .\packages\shared_ui\lib\widgets\common\product_cards\design_studio\mb_card_design_studio.dart -Pattern "_readElementStyles"'
Write-Host ""
Write-Host "Then run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host "flutter run -d web-server --web-hostname localhost --web-port 8080"
