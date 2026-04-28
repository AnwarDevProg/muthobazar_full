# MuthoBazar - Fix Palette Live Preview Bridge
# --------------------------------------------
# Fixes: palette JSON is saved, palette controls update, but preview/card still
# renders with old orange colors.
#
# Cause:
# Some renderer paths still read colors only from the template/default config.
# This patch adds an inherited palette scope and wraps:
# - New Design Studio preview
# - Saved design runtime card
#
# Then template resolves palette from the scope first, config metadata second.
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\fix_palette_live_preview_bridge.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\fix_palette_live_preview_bridge_$Timestamp"

$PalettePath = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_engine\mb_design_runtime_palette.dart"
$TemplatePath = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_engine\templates\hero_poster_circle_diagonal_v1.dart"
$StudioPath = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_studio\mb_card_design_studio.dart"
$SavedCardPath = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_engine\mb_saved_design_product_card.dart"

Write-Host ""
Write-Host "MuthoBazar - Fix Palette Live Preview Bridge" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host ""

function Backup-File {
  param([string]$Path)

  if (!(Test-Path -LiteralPath $Path)) {
    throw "File not found: $Path"
  }

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

New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null

# 1) Add palette scope helper.
Backup-File -Path $PalettePath
$PaletteText = [System.IO.File]::ReadAllText($PalettePath)

if (!$PaletteText.Contains("class MBDesignRuntimePaletteScope")) {
  $ScopeBlock = @'

MBDesignRuntimePalette mbResolveDesignRuntimePalette(
  BuildContext context,
  MBCardDesignConfig config,
) {
  final scoped = MBDesignRuntimePaletteScope.maybeOf(context);
  return scoped ?? MBDesignRuntimePalette.fromConfig(config);
}

class MBDesignRuntimePaletteScope extends InheritedWidget {
  const MBDesignRuntimePaletteScope({
    super.key,
    required this.palette,
    required super.child,
  });

  final MBDesignRuntimePalette palette;

  static MBDesignRuntimePalette? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<MBDesignRuntimePaletteScope>();
    return scope?.palette;
  }

  @override
  bool updateShouldNotify(MBDesignRuntimePaletteScope oldWidget) {
    return palette != oldWidget.palette;
  }
}
'@

  $PaletteText = $PaletteText.TrimEnd() + [Environment]::NewLine + $ScopeBlock + [Environment]::NewLine
  Save-Text -Path $PalettePath -Content $PaletteText
  Write-Host "Added MBDesignRuntimePaletteScope helper." -ForegroundColor Green
} else {
  Write-Host "Palette scope already exists." -ForegroundColor DarkGray
}

# 2) Make template resolve scoped palette first.
Backup-File -Path $TemplatePath
$TemplateText = [System.IO.File]::ReadAllText($TemplatePath)

$OldPaletteLine = "    final palette = MBDesignRuntimePalette.fromConfig(contextData.config);"
$NewPaletteLine = "    final palette = mbResolveDesignRuntimePalette(context, contextData.config);"

if ($TemplateText.Contains($OldPaletteLine)) {
  $TemplateText = $TemplateText.Replace($OldPaletteLine, $NewPaletteLine)
  Save-Text -Path $TemplatePath -Content $TemplateText
  Write-Host "Template now resolves scoped palette first." -ForegroundColor Green
} elseif ($TemplateText.Contains($NewPaletteLine)) {
  Write-Host "Template palette resolver already patched." -ForegroundColor DarkGray
} else {
  throw "Could not find palette resolver line in template."
}

# 3) Wrap studio preview renderer with palette scope.
Backup-File -Path $StudioPath
$StudioText = [System.IO.File]::ReadAllText($StudioPath)

$OldStudioBlock = @'
                Positioned.fill(
                  child: MBDesignCardRenderer(
                    product: _selectedProduct,
                    config: _config,
                    onTap: _showSnack('Product tapped'),
                    onPrimaryCtaTap: _showSnack('Primary CTA tapped'),
                    onSecondaryCtaTap: _showSnack('Secondary CTA tapped'),
                  ),
                ),
'@

$NewStudioBlock = @'
                Positioned.fill(
                  child: MBDesignRuntimePaletteScope(
                    palette: MBDesignRuntimePalette.fromMap(_paletteMap),
                    child: MBDesignCardRenderer(
                      product: _selectedProduct,
                      config: _config,
                      onTap: _showSnack('Product tapped'),
                      onPrimaryCtaTap: _showSnack('Primary CTA tapped'),
                      onSecondaryCtaTap: _showSnack('Secondary CTA tapped'),
                    ),
                  ),
                ),
'@

if ($StudioText.Contains($OldStudioBlock)) {
  $StudioText = $StudioText.Replace($OldStudioBlock, $NewStudioBlock)
  Save-Text -Path $StudioPath -Content $StudioText
  Write-Host "Studio preview wrapped with live palette scope." -ForegroundColor Green
} elseif ($StudioText.Contains("palette: MBDesignRuntimePalette.fromMap(_paletteMap)")) {
  Write-Host "Studio preview palette scope already patched." -ForegroundColor DarkGray
} else {
  throw "Could not find studio preview renderer block. Send _buildInteractiveCardPreview() if this fails."
}

# 4) Wrap saved runtime renderer with palette scope.
Backup-File -Path $SavedCardPath
$SavedText = [System.IO.File]::ReadAllText($SavedCardPath)

if (!$SavedText.Contains("import 'mb_design_runtime_palette.dart';")) {
  $SavedText = $SavedText.Replace(
    "import 'mb_design_card_renderer.dart';",
    "import 'mb_design_card_renderer.dart';`r`nimport 'mb_design_runtime_palette.dart';"
  )
}

$OldSavedBlock = @'
          child: MBDesignCardRenderer(
            product: product,
            config: config,
            onTap: onTap,
            onPrimaryCtaTap: onPrimaryCtaTap,
            onSecondaryCtaTap: onSecondaryCtaTap,
          ),
'@

$NewSavedBlock = @'
          child: MBDesignRuntimePaletteScope(
            palette: MBDesignRuntimePalette.fromConfig(config),
            child: MBDesignCardRenderer(
              product: product,
              config: config,
              onTap: onTap,
              onPrimaryCtaTap: onPrimaryCtaTap,
              onSecondaryCtaTap: onSecondaryCtaTap,
            ),
          ),
'@

if ($SavedText.Contains($OldSavedBlock)) {
  $SavedText = $SavedText.Replace($OldSavedBlock, $NewSavedBlock)
  Save-Text -Path $SavedCardPath -Content $SavedText
  Write-Host "Saved runtime card wrapped with palette scope." -ForegroundColor Green
} elseif ($SavedText.Contains("palette: MBDesignRuntimePalette.fromConfig(config)")) {
  Save-Text -Path $SavedCardPath -Content $SavedText
  Write-Host "Saved runtime palette scope already patched." -ForegroundColor DarkGray
} else {
  throw "Could not find saved runtime renderer block."
}

Write-Host ""
Write-Host "Patch completed." -ForegroundColor Green
Write-Host "Backup folder:" -ForegroundColor Yellow
Write-Host "  $BackupRoot"
Write-Host ""
Write-Host "Verify:" -ForegroundColor Cyan
Write-Host 'Select-String -Path .\packages\shared_ui\lib\widgets\common\product_cards\design_engine\templates\hero_poster_circle_diagonal_v1.dart -Pattern "mbResolveDesignRuntimePalette"'
Write-Host 'Select-String -Path .\packages\shared_ui\lib\widgets\common\product_cards\design_studio\mb_card_design_studio.dart -Pattern "MBDesignRuntimePaletteScope|fromMap\(_paletteMap\)"'
Write-Host ""
Write-Host "Then run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host "flutter run"
