# Fix missing _openCardStudioDialog method in admin_product_form_dialog.dart
#
# Run from repo root:
# powershell -ExecutionPolicy Bypass -File .\tools\fix_missing_open_card_studio_dialog_method.ps1
#
# Problem:
# The previous wire script replaced _openCardPickerDialog and
# _openSelectedCardSettingsDialog so they call _openCardStudioDialog(...),
# but the helper method itself was not inserted.

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$DialogPath = Join-Path $RepoRoot "apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart"

if (!(Test-Path $DialogPath)) {
  throw "File not found: $DialogPath"
}

$Backup = "$DialogPath.bak_fix_missing_card_studio_method_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item -LiteralPath $DialogPath -Destination $Backup -Force

$Content = [System.IO.File]::ReadAllText($DialogPath)

# Check for a real method declaration, not just method calls.
$HasMethodDeclaration = [System.Text.RegularExpressions.Regex]::IsMatch(
  $Content,
  "(?m)^\s*Future<\s*void\s*>\s+_openCardStudioDialog\s*\("
) -or [System.Text.RegularExpressions.Regex]::IsMatch(
  $Content,
  "(?m)^\s*Future\s+_openCardStudioDialog\s*\("
)

if ($HasMethodDeclaration) {
  Write-Host "_openCardStudioDialog method already exists. No insert needed." -ForegroundColor Cyan
} else {
  $MethodBlock = @'
  Future<void> _openCardStudioDialog(
    BuildContext context, {
    required AdminProductCardStudioMode initialMode,
  }) async {
    final result = await AdminProductCardStudioDialog.show(
      context,
      initialMode: initialMode,
      initialConfig: _selectedCardInstanceConfig,
      previewProductBuilder: _buildProductForCardStudioPreview,
    );

    if (!mounted || result == null) {
      return;
    }

    final normalized = result.cardConfig.normalized();

    setState(() {
      _cardLayoutType = normalized.variantId;
      _cardConfigDraft = normalized;
      _cardSettingsDraft = _cardSettingsDraftFromConfig(normalized);
    });
  }

  MBProduct _buildProductForCardStudioPreview(
    MBCardInstanceConfig cardConfig,
  ) {
    final normalized = cardConfig.normalized();

    return _buildProductFromForm().copyWith(
      cardLayoutType: normalized.variantId,
      cardConfig: normalized,
    );
  }

'@

  $Anchor = "MBCardSettingsOverride _buildCardSettingsOverride()"

  $AnchorIndex = $Content.IndexOf($Anchor)
  if ($AnchorIndex -lt 0) {
    throw "Could not find anchor method: $Anchor"
  }

  # Insert before the _buildCardSettingsOverride method.
  $LineStart = $Content.LastIndexOf("`n", [Math]::Max(0, $AnchorIndex))
  if ($LineStart -lt 0) {
    $LineStart = 0
  } else {
    $LineStart = $LineStart + 1
  }

  $Content = $Content.Substring(0, $LineStart) + $MethodBlock + $Content.Substring($LineStart)
  Write-Host "Inserted _openCardStudioDialog and _buildProductForCardStudioPreview." -ForegroundColor Green
}

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($DialogPath, $Content, $Utf8NoBom)

Write-Host ""
Write-Host "Backup:" -ForegroundColor Yellow
Write-Host $Backup
Write-Host ""
Write-Host "Fixed:" -ForegroundColor Green
Write-Host $DialogPath
Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
