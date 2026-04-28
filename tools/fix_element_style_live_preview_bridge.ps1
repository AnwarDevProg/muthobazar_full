# MuthoBazar - Fix Element Style Live Preview Bridge
# -------------------------------------------------
# Fixes: elementStyles can be edited/saved, but element color/style does not
# reflect in the preview/runtime card.
#
# Cause:
# Some renderer paths only read elementStyles from config.metadata. In live
# studio/runtime bridge this can be stale or stripped by intermediate config
# paths. This patch adds an InheritedWidget scope for element styles and makes
# the hero template resolve styles in this order:
#
# 1. Live scoped element styles
# 2. config.metadata['elementStyles']
# 3. empty fallback
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\fix_element_style_live_preview_bridge.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\fix_element_style_live_preview_bridge_$Timestamp"

$StylePath = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_engine\mb_design_element_runtime_style.dart"
$TemplatePath = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_engine\templates\hero_poster_circle_diagonal_v1.dart"
$StudioPath = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_studio\mb_card_design_studio.dart"
$SavedCardPath = Join-Path $RepoRoot "packages\shared_ui\lib\widgets\common\product_cards\design_engine\mb_saved_design_product_card.dart"

Write-Host ""
Write-Host "MuthoBazar - Fix Element Style Live Preview Bridge" -ForegroundColor Cyan
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

# 1) Add style scope helper.
Backup-File -Path $StylePath
$StyleText = [System.IO.File]::ReadAllText($StylePath)

if (!$StyleText.Contains("class MBDesignElementRuntimeStyleScope")) {
  $ScopeBlock = @'

MBDesignElementRuntimeStyles mbResolveDesignElementRuntimeStyles(
  BuildContext context,
  MBCardDesignConfig config,
) {
  final scoped = MBDesignElementRuntimeStyleScope.maybeOf(context);
  return scoped ?? MBDesignElementRuntimeStyles.fromConfig(config);
}

class MBDesignElementRuntimeStyleScope extends InheritedWidget {
  const MBDesignElementRuntimeStyleScope({
    super.key,
    required this.styles,
    required super.child,
  });

  final MBDesignElementRuntimeStyles styles;

  static MBDesignElementRuntimeStyles? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<MBDesignElementRuntimeStyleScope>();
    return scope?.styles;
  }

  @override
  bool updateShouldNotify(MBDesignElementRuntimeStyleScope oldWidget) {
    return styles != oldWidget.styles;
  }
}
'@

  $StyleText = $StyleText.TrimEnd() + [Environment]::NewLine + $ScopeBlock + [Environment]::NewLine
  Save-Text -Path $StylePath -Content $StyleText
  Write-Host "Added MBDesignElementRuntimeStyleScope helper." -ForegroundColor Green
} else {
  Write-Host "Element style scope already exists." -ForegroundColor DarkGray
}

# 2) Template resolves style scope first.
Backup-File -Path $TemplatePath
$TemplateText = [System.IO.File]::ReadAllText($TemplatePath)

$OldStyleLine = "    final elementStyles = MBDesignElementRuntimeStyles.fromConfig(contextData.config);"
$NewStyleLine = "    final elementStyles = mbResolveDesignElementRuntimeStyles(context, contextData.config);"

if ($TemplateText.Contains($OldStyleLine)) {
  $TemplateText = $TemplateText.Replace($OldStyleLine, $NewStyleLine)
  Save-Text -Path $TemplatePath -Content $TemplateText
  Write-Host "Template now resolves scoped element styles first." -ForegroundColor Green
} elseif ($TemplateText.Contains($NewStyleLine)) {
  Write-Host "Template element-style resolver already patched." -ForegroundColor DarkGray
} else {
  throw "Could not find element-style resolver line in template."
}

# 3) Studio preview wraps renderer with style scope.
Backup-File -Path $StudioPath
$StudioText = [System.IO.File]::ReadAllText($StudioPath)

# If palette scope already exists from previous patch, insert style scope inside it.
$OldStudioPaletteBlock = @'
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
'@

$NewStudioPaletteBlock = @'
                  child: MBDesignRuntimePaletteScope(
                    palette: MBDesignRuntimePalette.fromMap(_paletteMap),
                    child: MBDesignElementRuntimeStyleScope(
                      styles: MBDesignElementRuntimeStyles.fromMap(
                        _cleanElementStyleOverrides(),
                      ),
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

$OldStudioPlainBlock = @'
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

$NewStudioPlainBlock = @'
                Positioned.fill(
                  child: MBDesignElementRuntimeStyleScope(
                    styles: MBDesignElementRuntimeStyles.fromMap(
                      _cleanElementStyleOverrides(),
                    ),
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

if ($StudioText.Contains("MBDesignElementRuntimeStyleScope(")) {
  Write-Host "Studio preview style scope already patched." -ForegroundColor DarkGray
} elseif ($StudioText.Contains($OldStudioPaletteBlock)) {
  $StudioText = $StudioText.Replace($OldStudioPaletteBlock, $NewStudioPaletteBlock)
  Save-Text -Path $StudioPath -Content $StudioText
  Write-Host "Studio preview wrapped with live element-style scope inside palette scope." -ForegroundColor Green
} elseif ($StudioText.Contains($OldStudioPlainBlock)) {
  $StudioText = $StudioText.Replace($OldStudioPlainBlock, $NewStudioPlainBlock)
  Save-Text -Path $StudioPath -Content $StudioText
  Write-Host "Studio preview wrapped with live element-style scope." -ForegroundColor Green
} else {
  throw "Could not find studio preview renderer block. Send _buildInteractiveCardPreview() if this fails."
}

# 4) Saved runtime card wraps renderer with style scope.
Backup-File -Path $SavedCardPath
$SavedText = [System.IO.File]::ReadAllText($SavedCardPath)

if (!$SavedText.Contains("import 'mb_design_element_runtime_style.dart';")) {
  $SavedText = $SavedText.Replace(
    "import 'mb_design_card_renderer.dart';",
    "import 'mb_design_card_renderer.dart';`r`nimport 'mb_design_element_runtime_style.dart';"
  )
}

$OldSavedPaletteBlock = @'
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

$NewSavedPaletteBlock = @'
          child: MBDesignRuntimePaletteScope(
            palette: MBDesignRuntimePalette.fromConfig(config),
            child: MBDesignElementRuntimeStyleScope(
              styles: MBDesignElementRuntimeStyles.fromConfig(config),
              child: MBDesignCardRenderer(
                product: product,
                config: config,
                onTap: onTap,
                onPrimaryCtaTap: onPrimaryCtaTap,
                onSecondaryCtaTap: onSecondaryCtaTap,
              ),
            ),
          ),
'@

$OldSavedPlainBlock = @'
          child: MBDesignCardRenderer(
            product: product,
            config: config,
            onTap: onTap,
            onPrimaryCtaTap: onPrimaryCtaTap,
            onSecondaryCtaTap: onSecondaryCtaTap,
          ),
'@

$NewSavedPlainBlock = @'
          child: MBDesignElementRuntimeStyleScope(
            styles: MBDesignElementRuntimeStyles.fromConfig(config),
            child: MBDesignCardRenderer(
              product: product,
              config: config,
              onTap: onTap,
              onPrimaryCtaTap: onPrimaryCtaTap,
              onSecondaryCtaTap: onSecondaryCtaTap,
            ),
          ),
'@

if ($SavedText.Contains("MBDesignElementRuntimeStyleScope(")) {
  Save-Text -Path $SavedCardPath -Content $SavedText
  Write-Host "Saved runtime style scope already patched." -ForegroundColor DarkGray
} elseif ($SavedText.Contains($OldSavedPaletteBlock)) {
  $SavedText = $SavedText.Replace($OldSavedPaletteBlock, $NewSavedPaletteBlock)
  Save-Text -Path $SavedCardPath -Content $SavedText
  Write-Host "Saved runtime card wrapped with element-style scope inside palette scope." -ForegroundColor Green
} elseif ($SavedText.Contains($OldSavedPlainBlock)) {
  $SavedText = $SavedText.Replace($OldSavedPlainBlock, $NewSavedPlainBlock)
  Save-Text -Path $SavedCardPath -Content $SavedText
  Write-Host "Saved runtime card wrapped with element-style scope." -ForegroundColor Green
} else {
  throw "Could not find saved runtime renderer block."
}

Write-Host ""
Write-Host "Patch completed." -ForegroundColor Green
Write-Host "Backup folder:" -ForegroundColor Yellow
Write-Host "  $BackupRoot"
Write-Host ""
Write-Host "Verify:" -ForegroundColor Cyan
Write-Host 'Select-String -Path .\packages\shared_ui\lib\widgets\common\product_cards\design_engine\templates\hero_poster_circle_diagonal_v1.dart -Pattern "mbResolveDesignElementRuntimeStyles"'
Write-Host 'Select-String -Path .\packages\shared_ui\lib\widgets\common\product_cards\design_studio\mb_card_design_studio.dart -Pattern "MBDesignElementRuntimeStyleScope|fromMap\(_cleanElementStyleOverrides"'
Write-Host ""
Write-Host "Then run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host "flutter run"
