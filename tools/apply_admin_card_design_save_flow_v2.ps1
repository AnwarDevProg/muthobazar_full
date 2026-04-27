# MuthoBazar - Admin Card Design Save Flow Patch V2
# -------------------------------------------------
# Fixes the previous script failure caused by a missing exact UI chip anchor.
#
# This V2 patches only the admin form side and is tolerant of small UI differences.
# MBProduct was already patched by the previous script; this script verifies it.
#
# Patches:
# apps/admin_web/lib/features/products/widgets/admin_product_form_dialog.dart
#
# Required:
# apps/admin_web/lib/features/products/widgets/card_design/admin_card_design_studio_dialog.dart
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\apply_admin_card_design_save_flow_v2.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\admin_card_design_save_flow_v2_$Timestamp"

$ProductModelPath = Join-Path $RepoRoot "packages\shared_models\lib\catalog\mb_product.dart"
$AdminFormPath = Join-Path $RepoRoot "apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart"
$AdminStudioDialogPath = Join-Path $RepoRoot "apps\admin_web\lib\features\products\widgets\card_design\admin_card_design_studio_dialog.dart"

Write-Host ""
Write-Host "MuthoBazar Admin Card Design Save Flow Patch V2" -ForegroundColor Cyan
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

$ProductText = [System.IO.File]::ReadAllText($ProductModelPath)
if (!$ProductText.Contains("cardDesignJson")) {
  throw "MBProduct does not contain cardDesignJson. Re-run the previous save-flow patch or restore and apply full patch again."
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

function Add-Import {
  param([string]$Content)

  $ImportLine = "import 'card_design/admin_card_design_studio_dialog.dart';"

  if ($Content.Contains($ImportLine)) {
    Write-Host "Already patched: admin design studio import" -ForegroundColor DarkGray
    return $Content
  }

  if ($Content.Contains("import 'admin_product_card_settings_dialog.dart';")) {
    return $Content.Replace(
      "import 'admin_product_card_settings_dialog.dart';",
      "import 'admin_product_card_settings_dialog.dart';`r`n$ImportLine"
    )
  }

  $ImportMatches = [regex]::Matches($Content, "(?m)^import\s+['""][^'""]+['""];\s*$")
  if ($ImportMatches.Count -eq 0) {
    throw "Could not add import. No import lines found."
  }

  $Last = $ImportMatches[$ImportMatches.Count - 1]
  return $Content.Substring(0, $Last.Index + $Last.Length) +
    [Environment]::NewLine + $ImportLine +
    $Content.Substring($Last.Index + $Last.Length)
}

function Add-State {
  param([string]$Content)

  if ($Content.Contains("String? _cardDesignJson;")) {
    Write-Host "Already patched: _cardDesignJson state" -ForegroundColor DarkGray
    return $Content
  }

  $StateBlock = @'

  /// New design-family card JSON returned from MBCardDesignStudio.
  ///
  /// This lives beside the old cardConfig while the new design engine is
  /// being rolled out.
  String? _cardDesignJson;

  bool get _hasCardDesignJson {
    final value = _cardDesignJson;
    return value != null && value.trim().isNotEmpty;
  }
'@

  $Pattern = [regex]"(?m)^(\s*AdminProductCardSettingsResult\?\s+_cardSettingsDraft;\s*)$"
  $Match = $Pattern.Match($Content)

  if ($Match.Success) {
    return $Content.Substring(0, $Match.Index + $Match.Length) +
      $StateBlock +
      $Content.Substring($Match.Index + $Match.Length)
  }

  $InitPattern = [regex]"(?m)^\s*@override\s*$"
  $InitMatch = $InitPattern.Match($Content)
  if ($InitMatch.Success) {
    Write-Host "Warning: _cardSettingsDraft anchor missing; inserted state before first @override." -ForegroundColor Yellow
    return $Content.Substring(0, $InitMatch.Index) +
      $StateBlock + [Environment]::NewLine +
      $Content.Substring($InitMatch.Index)
  }

  throw "Could not insert _cardDesignJson state."
}

function Add-Init {
  param([string]$Content)

  if ($Content.Contains("_cardDesignJson = _source.cardDesignJson;")) {
    Write-Host "Already patched: _cardDesignJson init" -ForegroundColor DarkGray
    return $Content
  }

  $Needle = "    _cardSettingsDraft = _cardSettingsDraftFromConfig(initialCardConfig);"
  if ($Content.Contains($Needle)) {
    return $Content.Replace(
      $Needle,
      $Needle + [Environment]::NewLine + "    _cardDesignJson = _source.cardDesignJson;"
    )
  }

  throw "Could not insert _cardDesignJson init. Expected _cardSettingsDraftFromConfig(initialCardConfig) line."
}

function Add-Methods {
  param([string]$Content)

  if ($Content.Contains("Future<void> _openCardDesignStudioDialog")) {
    Write-Host "Already patched: design studio methods" -ForegroundColor DarkGray
    return $Content
  }

  $Methods = @'

  Future<void> _openCardDesignStudioDialog(BuildContext context) async {
    final result = await AdminCardDesignStudioDialog.show(
      context,
      previewProduct: _source,
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

  Widget _buildCardDesignInfoChip(
    BuildContext context,
    String label,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildCardDesignStudioBridgePanel(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _hasCardDesignJson
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _hasCardDesignJson
              ? theme.colorScheme.primary.withValues(alpha: 0.35)
              : theme.dividerColor.withValues(alpha: 0.70),
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
                _buildCardDesignInfoChip(context, 'saved design JSON'),
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

  $Needle = "  Future<void> _openCardPickerDialog(BuildContext context) async {"
  if ($Content.Contains($Needle)) {
    return $Content.Replace($Needle, $Methods + $Needle)
  }

  throw "Could not insert design studio methods. _openCardPickerDialog anchor missing."
}

function Add-Panel {
  param([string]$Content)

  if ($Content.Contains("_buildCardDesignStudioBridgePanel(context),")) {
    Write-Host "Already patched: design studio panel in form" -ForegroundColor DarkGray
    return $Content
  }

  $Insert = "          _buildCardDesignStudioBridgePanel(context),`r`n          const SizedBox(height: 12),`r`n"

  $Pattern1 = [regex]"          _buildSelectedCardPreview\(context\),\s*\r?\n\s*const SizedBox\(height:\s*12\),"
  $Match1 = $Pattern1.Match($Content)

  if ($Match1.Success) {
    return $Content.Substring(0, $Match1.Index + $Match1.Length) +
      [Environment]::NewLine + $Insert +
      $Content.Substring($Match1.Index + $Match1.Length)
  }

  $Needle = "          _buildSelectedCardPreview(context),"
  if ($Content.Contains($Needle)) {
    return $Content.Replace($Needle, $Needle + [Environment]::NewLine + $Insert)
  }

  Write-Host "Warning: could not find _buildSelectedCardPreview(context). Panel was not inserted into UI." -ForegroundColor Yellow
  return $Content
}

function Add-Save {
  param([string]$Content)

  if ($Content.Contains("cardDesignJson: _cardDesignJson")) {
    Write-Host "Already patched: save cardDesignJson" -ForegroundColor DarkGray
    return $Content
  }

  $Insert = @"
      cardDesignJson: _cardDesignJson?.trim().isEmpty ?? true
          ? null
          : _cardDesignJson!.trim(),
      clearCardDesignJson: _cardDesignJson?.trim().isEmpty ?? true,
"@

  $Needle = "      cardConfig: selectedCardConfig,"
  if ($Content.Contains($Needle)) {
    return $Content.Replace(
      $Needle,
      $Needle + [Environment]::NewLine + $Insert.TrimEnd()
    )
  }

  $Pattern = [regex]"(?m)^(\s*cardConfig:\s*selectedCardConfig,\s*)$"
  $Match = $Pattern.Match($Content)
  if ($Match.Success) {
    return $Content.Substring(0, $Match.Index + $Match.Length) +
      [Environment]::NewLine + $Insert +
      $Content.Substring($Match.Index + $Match.Length)
  }

  throw "Could not insert save fields. Expected line not found: cardConfig: selectedCardConfig,"
}

New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
Backup-File -Path $AdminFormPath

$Text = [System.IO.File]::ReadAllText($AdminFormPath)

$Text = Add-Import -Content $Text
$Text = Add-State -Content $Text
$Text = Add-Init -Content $Text
$Text = Add-Methods -Content $Text
$Text = Add-Panel -Content $Text
$Text = Add-Save -Content $Text

Save-Text -Path $AdminFormPath -Content $Text

Write-Host ""
Write-Host "Admin product form patched successfully." -ForegroundColor Green
Write-Host "Backup folder:" -ForegroundColor Yellow
Write-Host "  $BackupRoot"
Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host ""
Write-Host "Then test:"
Write-Host "1. Open admin product create/edit."
Write-Host "2. Open New Design Studio."
Write-Host "3. Use this design."
Write-Host "4. Save product."
Write-Host "5. Check Firestore product doc has cardDesignJson."
