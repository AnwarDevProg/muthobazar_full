# MuthoBazar - Admin Card Design Save Flow Patch
# ----------------------------------------------
# This patch wires the reusable design studio into admin product create/edit
# and persists the returned design JSON through MBProduct.toMap().
#
# It patches:
# 1. packages/shared_models/lib/catalog/mb_product.dart
# 2. apps/admin_web/lib/features/products/widgets/admin_product_form_dialog.dart
#
# Required previous patch:
# - AdminCardDesignStudioDialog must already exist at:
#   apps/admin_web/lib/features/products/widgets/card_design/admin_card_design_studio_dialog.dart
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_admin_card_design_save_flow.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\admin_card_design_save_flow_$Timestamp"

$ProductModelPath = Join-Path $RepoRoot "packages\shared_models\lib\catalog\mb_product.dart"
$AdminFormPath = Join-Path $RepoRoot "apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart"
$AdminStudioDialogPath = Join-Path $RepoRoot "apps\admin_web\lib\features\products\widgets\card_design\admin_card_design_studio_dialog.dart"

Write-Host ""
Write-Host "MuthoBazar Admin Card Design Save Flow Patch" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host ""

if (!(Test-Path -LiteralPath $ProductModelPath)) {
  throw "MBProduct model not found: $ProductModelPath"
}

if (!(Test-Path -LiteralPath $AdminFormPath)) {
  throw "Admin product form not found: $AdminFormPath"
}

if (!(Test-Path -LiteralPath $AdminStudioDialogPath)) {
  throw "AdminCardDesignStudioDialog not found. Apply the bridge patch first: $AdminStudioDialogPath"
}

function Backup-File {
  param([string]$Path)

  $Relative = $Path.Substring($RepoRoot.Length).TrimStart('\')
  $Backup = Join-Path $BackupRoot $Relative
  New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
  Copy-Item -LiteralPath $Path -Destination $Backup -Force
  Write-Host "Backup: $Backup" -ForegroundColor DarkGray
}

function Save-Text {
  param(
    [string]$Path,
    [string]$Content
  )

  [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

function Insert-After {
  param(
    [string]$Content,
    [string]$Needle,
    [string]$Insert,
    [string]$Name
  )

  if ($Content.Contains($Insert.Trim())) {
    Write-Host "Already patched: $Name" -ForegroundColor DarkGray
    return $Content
  }

  if (!$Content.Contains($Needle)) {
    throw "Could not patch $Name. Needle not found:`n$Needle"
  }

  return $Content.Replace($Needle, $Needle + $Insert)
}

function Insert-Before {
  param(
    [string]$Content,
    [string]$Needle,
    [string]$Insert,
    [string]$Name
  )

  if ($Content.Contains($Insert.Trim())) {
    Write-Host "Already patched: $Name" -ForegroundColor DarkGray
    return $Content
  }

  if (!$Content.Contains($Needle)) {
    throw "Could not patch $Name. Needle not found:`n$Needle"
  }

  return $Content.Replace($Needle, $Insert + $Needle)
}

function Patch-MBProduct {
  Write-Host ""
  Write-Host "Patching MBProduct model..." -ForegroundColor Yellow

  Backup-File -Path $ProductModelPath

  $Text = [System.IO.File]::ReadAllText($ProductModelPath)

  $Text = Insert-After `
    -Content $Text `
    -Needle "  final MBCardInstanceConfig cardConfig;" `
    -Insert @"

  /// New design-family card studio JSON.
  ///
  /// This is the first persistence bridge for the free-design renderer.
  /// It stores the exported design-state JSON from MBCardDesignStudio.
  /// The old cardConfig remains untouched for legacy/variant fallback.
  final String? cardDesignJson;

  bool get hasCardDesignJson {
    final value = cardDesignJson;
    return value != null && value.trim().isNotEmpty;
  }
"@ `
    -Name "MBProduct.cardDesignJson field"

  $Text = Insert-After `
    -Content $Text `
    -Needle "    this.cardConfig = _defaultCardConfig," `
    -Insert @"
    this.cardDesignJson,
"@ `
    -Name "MBProduct constructor cardDesignJson"

  $Text = Insert-After `
    -Content $Text `
    -Needle "    MBCardInstanceConfig? cardConfig," `
    -Insert @"
    String? cardDesignJson,
    bool clearCardDesignJson = false,
"@ `
    -Name "MBProduct.copyWith cardDesignJson parameter"

  $Text = Insert-After `
    -Content $Text `
    -Needle "      cardConfig: nextCardConfig.normalized()," `
    -Insert @"
      cardDesignJson: clearCardDesignJson
          ? null
          : (cardDesignJson ?? this.cardDesignJson),
"@ `
    -Name "MBProduct.copyWith return cardDesignJson"

  $Text = Insert-After `
    -Content $Text `
    -Needle "      'cardConfig': normalizedConfig.toMap()," `
    -Insert @"
      if (cardDesignJson?.trim().isNotEmpty ?? false)
        'cardDesignJson': cardDesignJson!.trim(),
"@ `
    -Name "MBProduct.toMap cardDesignJson"

  $Text = Insert-After `
    -Content $Text `
    -Needle "      cardConfig: cardConfig," `
    -Insert @"
      cardDesignJson: _asNullableString(
        map['cardDesignJson'] ?? map['cardDesignJsonV1'],
      ),
"@ `
    -Name "MBProduct.fromMap cardDesignJson"

  $Text = Insert-Before `
    -Content $Text `
    -Needle "List<String> _asStringList(dynamic value) {" `
    -Insert @"
String? _asNullableString(dynamic value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

"@ `
    -Name "MBProduct _asNullableString helper"

  Save-Text -Path $ProductModelPath -Content $Text
  Write-Host "MBProduct patched." -ForegroundColor Green
}

function Patch-AdminProductForm {
  Write-Host ""
  Write-Host "Patching admin product form..." -ForegroundColor Yellow

  Backup-File -Path $AdminFormPath

  $Text = [System.IO.File]::ReadAllText($AdminFormPath)

  $Text = Insert-After `
    -Content $Text `
    -Needle "import 'admin_product_card_settings_dialog.dart';" `
    -Insert @"
import 'card_design/admin_card_design_studio_dialog.dart';
"@ `
    -Name "Admin form design studio import"

  $Text = Insert-After `
    -Content $Text `
    -Needle "  AdminProductCardSettingsResult? _cardSettingsDraft;" `
    -Insert @"

  /// New design-family card JSON returned from MBCardDesignStudio.
  ///
  /// This lives beside the old cardConfig while the new design engine is
  /// being rolled out.
  String? _cardDesignJson;

  bool get _hasCardDesignJson {
    final value = _cardDesignJson;
    return value != null && value.trim().isNotEmpty;
  }
"@ `
    -Name "Admin form cardDesignJson state"

  $Text = Insert-After `
    -Content $Text `
    -Needle "    _cardSettingsDraft = _cardSettingsDraftFromConfig(initialCardConfig);" `
    -Insert @"
    _cardDesignJson = _source.cardDesignJson;
"@ `
    -Name "Admin form cardDesignJson init"

  $Methods = @'

  Future<void> _openCardDesignStudioDialog(BuildContext context) async {
    final previewProduct = _buildProductFromForm();

    final result = await AdminCardDesignStudioDialog.show(
      context,
      previewProduct: previewProduct,
      initialDesignJson: _cardDesignJson,
      title: 'Product Card Design Studio',
    );

    if (result == null) {
      return;
    }

    setState(() {
      _cardDesignJson = result.designJson.trim().isEmpty
          ? null
          : result.designJson.trim();
    });
  }

  Widget _buildCardDesignStudioBridgePanel(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _hasCardDesignJson
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.32)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _hasCardDesignJson
              ? theme.colorScheme.primary.withValues(alpha: 0.35)
              : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.design_services_rounded,
                color: _hasCardDesignJson
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'New Design Studio',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_hasCardDesignJson)
                buildInfoChip('saved design JSON'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _hasCardDesignJson
                ? 'A free-design card layout is attached to this product. Open the studio to edit, drag, resize, copy, or paste the design JSON.'
                : 'Open the new design-family studio to create a free-position card design. This is saved beside the legacy cardConfig.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => _openCardDesignStudioDialog(context),
                icon: const Icon(Icons.brush_rounded),
                label: Text(
                  _hasCardDesignJson
                      ? 'Edit Design Studio'
                      : 'Open Design Studio',
                ),
              ),
              if (_hasCardDesignJson)
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _cardDesignJson = null);
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Clear design JSON'),
                ),
            ],
          ),
        ],
      ),
    );
  }

'@

  $Text = Insert-Before `
    -Content $Text `
    -Needle "  Future<void> _openCardPickerDialog(BuildContext context) async {" `
    -Insert $Methods `
    -Name "Admin form design studio methods"

  $Text = Insert-After `
    -Content $Text `
    -Needle "                buildInfoChip('custom settings: on')," `
    -Insert @"
              if (_hasCardDesignJson)
                buildInfoChip('new design: on'),
"@ `
    -Name "Admin form new design chip"

  $Text = Insert-After `
    -Content $Text `
    -Needle "          _buildSelectedCardPreview(context),
          const SizedBox(height: 12),
" `
    -Insert @"
          _buildCardDesignStudioBridgePanel(context),
          const SizedBox(height: 12),
"@ `
    -Name "Admin form design studio bridge panel"

  $Text = Insert-After `
    -Content $Text `
    -Needle "      cardConfig: selectedCardConfig," `
    -Insert @"
      cardDesignJson: _cardDesignJson?.trim().isEmpty ?? true
          ? null
          : _cardDesignJson!.trim(),
      clearCardDesignJson: _cardDesignJson?.trim().isEmpty ?? true,
"@ `
    -Name "Admin form save cardDesignJson"

  Save-Text -Path $AdminFormPath -Content $Text
  Write-Host "Admin product form patched." -ForegroundColor Green
}

New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null

Patch-MBProduct
Patch-AdminProductForm

Write-Host ""
Write-Host "Patch completed successfully." -ForegroundColor Green
Write-Host "Backup folder:" -ForegroundColor Yellow
Write-Host "  $BackupRoot"
Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host ""
Write-Host "Then test:"
Write-Host "1. Open admin product create/edit."
Write-Host "2. Open New Design Studio."
Write-Host "3. Drag/resize/tune."
Write-Host "4. Use this design."
Write-Host "5. Save product."
Write-Host "6. Check Firestore product doc has cardDesignJson."
