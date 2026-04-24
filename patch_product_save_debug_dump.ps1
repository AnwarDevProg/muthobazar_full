# Patch: Product Save Debug Dump
#
# Run from repo root:
#   powershell -ExecutionPolicy Bypass -File .\tools\patch_product_save_debug_dump.ps1
#
# It patches:
#   apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart
#
# Result:
#   Every Save Product click downloads a .txt file BEFORE saveProduct(...)
#   so we can see exactly what the form is sending.

param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$target = Join-Path $RepoRoot "apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart"

if (-not (Test-Path $target)) {
  throw "Target file not found: $target"
}

$source = [System.IO.File]::ReadAllText($target)

if ($source -notmatch "class\s+AdminProductFormDialog\s+extends\s+StatefulWidget") {
  throw "Wrong file: $target"
}

$backup = "$target.bak_save_debug_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
[System.IO.File]::WriteAllText($backup, $source)
Write-Host "Backup created: $backup" -ForegroundColor Cyan

# Add imports.
if ($source -notmatch "import\s+'dart:convert';") {
  $source = "import 'dart:convert';`r`n" + $source
  Write-Host "Added dart:convert" -ForegroundColor Green
}

if ($source -notmatch "import\s+'dart:html'\s+as\s+html;") {
  $source = $source -replace "import\s+'dart:convert';", "import 'dart:convert';`r`n// ignore: avoid_web_libraries_in_flutter`r`nimport 'dart:html' as html;"
  Write-Host "Added dart:html as html" -ForegroundColor Green
}

$helper = @'
  Future<void> _downloadProductSaveDebugFile(MBProduct product) async {
    final now = DateTime.now();
    final mode = _source.id.trim().isEmpty ? 'create' : 'edit';
    final idPart = _safeDebugFileNamePart(
      product.id.trim().isEmpty ? 'new_product' : product.id.trim(),
    );
    final timestamp = _safeDebugFileNamePart(now.toIso8601String());
    final fileName = 'muthobazar_product_save_${mode}_${idPart}_$timestamp.txt';

    final selectedVariant = _selectedAdminCardVariant;
    final selectedCardConfig = _selectedCardInstanceConfig.normalized();
    final productCardConfig = product.effectiveCardConfig.normalized();

    final dump = <String, Object?>{
      'debugPurpose':
          'Generated before AdminProductController.saveProduct(...) from Save Product button.',
      'generatedAt': now.toIso8601String(),
      'mode': mode,
      'sourceProductId': _source.id,
      'productIdBeforeSave': product.id,
      'controller': <String, Object?>{
        'isSaving': _controller.isSaving.value,
        'errorMessage': _controller.errorMessage.value,
      },
      'cardStateFromDialog': <String, Object?>{
        'rawState_cardLayoutType': _cardLayoutType,
        'selectedVariantId': selectedVariant.id,
        'selectedFamilyName': selectedVariant.family.name,
        'selectedFamilyLabel': selectedVariant.family.label,
        'selectedIsFullWidth': selectedVariant.isFullWidth,
        'hasCardSettingsDraft': _cardSettingsDraft != null,
        'cardSettingsDraft': _cardSettingsDraft?.toMap(),
        'selectedCardInstanceConfig': selectedCardConfig.toMap(),
        'buildCardSettingsOverride': _buildCardSettingsOverride().toMap(),
      },
      'cardStateFromBuiltProduct': <String, Object?>{
        'product.cardLayoutType': product.cardLayoutType,
        'product.effectiveCardVariantId': product.effectiveCardVariantId,
        'product.effectiveCardFamilyId': product.effectiveCardFamilyId,
        'product.effectiveCardConfig': productCardConfig.toMap(),
      },
      'importantFormState': <String, Object?>{
        'productType': _productType,
        'isVariableProduct': _isVariableProduct,
        'selectedCategoryId': _selectedCategoryId,
        'selectedBrandId': _selectedBrandId,
        'isFeatured': _isFeatured,
        'isFlashSale': _isFlashSale,
        'isEnabled': _isEnabled,
        'isNewArrival': _isNewArrival,
        'isBestSeller': _isBestSeller,
        'mediaItemsCount': _mediaItems.length,
        'attributesCount': _attributes.length,
        'variationsCount': _variations.length,
        'purchaseOptionsCount': _purchaseOptions.length,
        'effectiveThumbnailUrl': _effectiveThumbnailUrl,
        'effectiveImageUrls': _effectiveImageUrls,
      },
      'editorCollections': <String, Object?>{
        'mediaItems': _mediaItems.map((item) => item.toMap()).toList(),
        'attributes': _attributes.map((item) => item.toMap()).toList(),
        'variations': _variations.map((item) => item.toMap()).toList(),
        'purchaseOptions': _purchaseOptions.map((item) => item.toMap()).toList(),
      },
      'productToMapBeforeSave': product.toMap(),
    };

    final content = const JsonEncoder.withIndent('  ').convert(
      _debugJsonSafe(dump),
    );

    final bytes = utf8.encode(content);
    final blob = html.Blob(<Object>[bytes], 'text/plain;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  Object? _debugJsonSafe(Object? value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is DateTime) return value.toIso8601String();
    if (value is Enum) return value.name;
    if (value is Map) {
      final output = <String, Object?>{};
      value.forEach((key, item) {
        output[key.toString()] = _debugJsonSafe(item);
      });
      return output;
    }
    if (value is Iterable) {
      return value.map(_debugJsonSafe).toList();
    }
    return value.toString();
  }

  String _safeDebugFileNamePart(String value) {
    final normalized = value.trim().replaceAll(
          RegExp(r'[^a-zA-Z0-9._-]+'),
          '_',
        );
    if (normalized.isEmpty) return 'empty';
    if (normalized.length <= 80) return normalized;
    return normalized.substring(0, 80);
  }


'@

# Insert helper before _handleSave().
if ($source -notmatch "Future<void>\s+_downloadProductSaveDebugFile\s*\(") {
  $needle = "  Future<void> _handleSave() async {"
  if (-not $source.Contains($needle)) {
    throw "Could not find _handleSave() in target file."
  }
  $source = $source.Replace($needle, $helper + $needle)
  Write-Host "Inserted debug helper methods" -ForegroundColor Green
} else {
  Write-Host "Debug helper already exists" -ForegroundColor Yellow
}

# Insert call after product is built.
if ($source -notmatch "await\s+_downloadProductSaveDebugFile\(product\);") {
  $pattern = "(final\s+product\s*=\s*_buildProductFromForm\(\);\s*)(var\s+saved\s*=\s*await\s+_controller\.saveProduct\()"
  $replacement = "`$1await _downloadProductSaveDebugFile(product);`r`n    `$2"

  $patched = [regex]::Replace(
    $source,
    $pattern,
    $replacement,
    [System.Text.RegularExpressions.RegexOptions]::Singleline
  )

  if ($patched -eq $source) {
    throw "Could not insert debug download call after _buildProductFromForm()."
  }

  $source = $patched
  Write-Host "Inserted debug download call in _handleSave()" -ForegroundColor Green
} else {
  Write-Host "Debug download call already exists" -ForegroundColor Yellow
}

[System.IO.File]::WriteAllText($target, $source)

Write-Host ""
Write-Host "Patch completed." -ForegroundColor Green
Write-Host "Updated: $target"
Write-Host ""
Write-Host "Next commands:"
Write-Host "  flutter analyze"
Write-Host "  flutter run -d web-server --web-hostname localhost --web-port 8080"
Write-Host ""
Write-Host "On Save Product click, browser will download:"
Write-Host "  muthobazar_product_save_<create-or-edit>_<product-id>_<timestamp>.txt"
