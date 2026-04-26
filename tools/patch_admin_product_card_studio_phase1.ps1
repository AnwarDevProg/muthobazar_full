# MuthoBazar Admin Product Card Studio Integration Patch - Phase 1
# Run from repo root:
# powershell -ExecutionPolicy Bypass -File .\tools\patch_admin_product_card_studio_phase1.ps1
#
# What this patch does:
# 1. Adds the new Card Studio dialog file under admin_web.
# 2. Imports it in admin_product_form_dialog.dart.
# 3. Keeps current product-form state and replaces the old card picker/settings flow
#    with the new side-by-side Card Studio dialog.
# 4. Stores the returned MBCardInstanceConfig so saving uses the new cardConfig.

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$DialogPath = Join-Path $RepoRoot "apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart"
$StudioPath = Join-Path $RepoRoot "apps\admin_web\lib\features\products\widgets\card_studio\admin_product_card_studio_dialog.dart"

if (!(Test-Path $DialogPath)) {
  throw "admin_product_form_dialog.dart not found: $DialogPath"
}

if (!(Test-Path (Split-Path $StudioPath))) {
  New-Item -ItemType Directory -Force -Path (Split-Path $StudioPath) | Out-Null
}

# Write the studio file from the adjacent patch source file.
$SourceStudioPath = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "admin_product_card_studio_dialog.dart"
if (!(Test-Path $SourceStudioPath)) {
  throw "Missing patch source file: $SourceStudioPath"
}

Copy-Item -LiteralPath $SourceStudioPath -Destination $StudioPath -Force
Write-Host "Installed Card Studio dialog:" -ForegroundColor Green
Write-Host $StudioPath

$Backup = "$DialogPath.bak_card_studio_phase1_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item -LiteralPath $DialogPath -Destination $Backup -Force
Write-Host "Backup created:" -ForegroundColor Yellow
Write-Host $Backup

$Content = [System.IO.File]::ReadAllText($DialogPath)

# 1) Add import.
if ($Content -notmatch "card_studio/admin_product_card_studio_dialog\.dart") {
  if ($Content -match "import 'admin_product_card_settings_dialog\.dart';") {
    $Content = $Content -replace "import 'admin_product_card_settings_dialog\.dart';", "import 'admin_product_card_settings_dialog.dart';`r`nimport 'card_studio/admin_product_card_studio_dialog.dart';"
  } elseif ($Content -match "import 'admin_product_form_support\.dart';") {
    $Content = $Content -replace "import 'admin_product_form_support\.dart';", "import 'admin_product_form_support.dart';`r`nimport 'card_studio/admin_product_card_studio_dialog.dart';"
  } else {
    $Content = "import 'card_studio/admin_product_card_studio_dialog.dart';`r`n$Content"
  }
}

# 2) Add new card config draft field.
if ($Content -notmatch "MBCardInstanceConfig\?\s+_cardConfigDraft;") {
  $Content = $Content -replace "AdminProductCardSettingsResult\?\s+_cardSettingsDraft;", "AdminProductCardSettingsResult? _cardSettingsDraft;`r`n  MBCardInstanceConfig? _cardConfigDraft;"
}

# 3) Initialize card config draft from initial product config.
if ($Content -notmatch "_cardConfigDraft\s*=\s*initialCardConfig;") {
  $Content = $Content -replace "_cardSettingsDraft\s*=\s*_cardSettingsDraftFromConfig\(initialCardConfig\);", "_cardSettingsDraft = _cardSettingsDraftFromConfig(initialCardConfig);`r`n    _cardConfigDraft = initialCardConfig;"
}

# 4) Replace selected-card instance getter so final save uses the new studio config if present.
$GetterPattern = "MBCardInstanceConfig get _selectedCardInstanceConfig \{.*?\}\s*Future _openCardPickerDialog"
$GetterReplacement = @'
MBCardInstanceConfig get _selectedCardInstanceConfig {
    final variant = _selectedAdminCardVariant;
    final configDraft = _cardConfigDraft?.normalized();

    if (configDraft != null && configDraft.variant == variant) {
      return configDraft;
    }

    return MBCardInstanceConfig(
      family: variant.family,
      variant: variant,
      settings: _buildCardSettingsOverride(),
    ).normalized();
  }

  Future _openCardPickerDialog
'@
$Content = [System.Text.RegularExpressions.Regex]::Replace(
  $Content,
  $GetterPattern,
  $GetterReplacement,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

# 5) Replace old picker method with new Card Studio launcher.
$PickerPattern = "Future _openCardPickerDialog\(BuildContext context\) async \{.*?\}\s*MBCardSettingsOverride _buildCardSettingsOverride"
$PickerReplacement = @'
Future _openCardPickerDialog(BuildContext context) async {
    await _openCardStudioDialog(
      context,
      initialMode: AdminProductCardStudioMode.select,
    );
  }

  Future _openCardStudioDialog(
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

  MBCardSettingsOverride _buildCardSettingsOverride
'@
$Content = [System.Text.RegularExpressions.Regex]::Replace(
  $Content,
  $PickerPattern,
  $PickerReplacement,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

# 6) Replace old selected settings dialog method with Card Studio configure mode.
$SettingsPattern = "Future _openSelectedCardSettingsDialog\(BuildContext context\) async \{.*?\}\s*String\? _findDuplicateAttributeMessage"
$SettingsReplacement = @'
Future _openSelectedCardSettingsDialog(BuildContext context) async {
    await _openCardStudioDialog(
      context,
      initialMode: AdminProductCardStudioMode.configure,
    );
  }

  String? _findDuplicateAttributeMessage
'@
$Content = [System.Text.RegularExpressions.Regex]::Replace(
  $Content,
  $SettingsPattern,
  $SettingsReplacement,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

# 7) If old settings mapper is still used, prefer full config draft first.
if ($Content -notmatch "final configDraft = _cardConfigDraft\?\.normalized\(\);") {
  $Content = $Content -replace "final selectedVariant = _selectedAdminCardVariant;", "final selectedVariant = _selectedAdminCardVariant;`r`n    final configDraft = _cardConfigDraft?.normalized();`r`n    if (configDraft != null && configDraft.variant == selectedVariant) {`r`n      return configDraft.settings;`r`n    }"
}

# 8) Replace the product-dialog Card Style section with a clean summary + buttons only.
$CardStylePattern = "Widget _buildCardStyleSection\(BuildContext context\) \{.*?\}\s*Widget _buildAuditSection"
$CardStyleReplacement = @'
Widget _buildCardStyleSection(BuildContext context) {
    final selectedVariant = _selectedAdminCardVariant;
    final hasCustomConfig =
        _cardConfigDraft?.normalized().settings.isNotEmpty == true ||
        (_cardSettingsDraft != null &&
            _cardSettingsDraft!.variantId == selectedVariant.id);

    return SectionCard(
      title: 'Customer App Card Style',
      subtitle:
          'Select the product-card variant and tune its settings in the Card Studio. The studio shows a persistent live mobile preview.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              buildInfoChip('family: ${selectedVariant.family.label}'),
              buildInfoChip('variant: ${selectedVariant.id}'),
              buildInfoChip(
                selectedVariant.isFullWidth
                    ? 'footprint: full'
                    : 'footprint: half',
              ),
              if (hasCustomConfig) buildInfoChip('custom settings: on'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Text(
              'The product dialog now keeps this section clean. Use Card Studio for side-by-side family/variant selection and live phone preview.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openCardPickerDialog(context),
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('Select card'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openSelectedCardSettingsDialog(context),
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Edit card'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditSection
'@
$Content = [System.Text.RegularExpressions.Regex]::Replace(
  $Content,
  $CardStylePattern,
  $CardStyleReplacement,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

# 9) Write file.
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($DialogPath, $Content, $Utf8NoBom)

Write-Host ""
Write-Host "Patched admin_product_form_dialog.dart" -ForegroundColor Green
Write-Host ""
Write-Host "Now run:" -ForegroundColor Yellow
Write-Host "flutter analyze"
