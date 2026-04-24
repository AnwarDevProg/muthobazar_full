# Card layout upgrade verification script
# Run from MuthoBazar repo root:
#   powershell -ExecutionPolicy Bypass -File .\tools\verify_card_layout_upgrade.ps1

$ErrorActionPreference = 'Stop'

function MustContain($Path, $Pattern, $Message) {
  if (-not (Test-Path $Path)) { throw "Missing file: $Path" }
  $hit = Select-String -Path $Path -Pattern $Pattern -SimpleMatch -ErrorAction SilentlyContinue
  if (-not $hit) { throw "FAILED: $Message`nFile: $Path`nPattern: $Pattern" }
  Write-Host "OK: $Message" -ForegroundColor Green
}

function MustNotContain($Path, $Pattern, $Message) {
  if (-not (Test-Path $Path)) { throw "Missing file: $Path" }
  $hit = Select-String -Path $Path -Pattern $Pattern -SimpleMatch -ErrorAction SilentlyContinue
  if ($hit) { throw "FAILED: $Message`nFile: $Path`nPattern: $Pattern" }
  Write-Host "OK: $Message" -ForegroundColor Green
}

$mbProduct = 'packages\shared_models\lib\catalog\mb_product.dart'
$formDialog = 'apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart'
$renderer = 'packages\shared_ui\lib\widgets\common\product_cards\mb_product_card_renderer.dart'
$createFn = 'firebase\functions\src\products\admin_create_product.ts'
$updateFn = 'firebase\functions\src\products\admin_update_product.ts'

MustContain $mbProduct 'final MBCardInstanceConfig cardConfig;' 'MBProduct has cardConfig'
MustContain $mbProduct "final List<MBProductMedia> mediaItems;" 'MBProduct mediaItems is strongly typed'
MustContain $mbProduct "final List<MBProductAttribute> attributes;" 'MBProduct attributes is strongly typed'
MustContain $mbProduct "'cardLayoutType': normalizedConfig.variantId" 'MBProduct writes exact variant id to cardLayoutType'
MustContain $mbProduct "'cardConfig': normalizedConfig.toMap()" 'MBProduct writes cardConfig map'

MustContain $formDialog 'final selectedCardConfig = _selectedCardInstanceConfig;' 'Admin form builds selected card config'
MustContain $formDialog 'cardLayoutType: selectedCardConfig.variantId' 'Admin form saves exact variant id'
MustContain $formDialog 'cardConfig: selectedCardConfig' 'Admin form saves cardConfig'

MustContain $renderer 'product.effectiveCardConfig.normalized()' 'Renderer reads product.effectiveCardConfig'
MustContain $renderer 'settings: cardConfig.settings' 'Renderer applies saved card settings'

MustContain $createFn 'export const adminCreateProduct' 'Create function exports adminCreateProduct'
MustContain $createFn 'function normalizeCardVariantId' 'Create function has new card variant normalizer'
MustContain $createFn 'cardLayoutType: normalizedCardConfig.variantId' 'Create function writes exact variant id'
MustContain $createFn 'cardConfig: normalizedCardConfig' 'Create function writes cardConfig'
MustNotContain $createFn 'case "standard":`n      return normalized;' 'Create function no longer preserves old standard as final value'

MustContain $updateFn 'export const adminUpdateProduct' 'Update function exports adminUpdateProduct'
MustContain $updateFn 'function normalizeCardVariantId' 'Update function has new card variant normalizer'
MustContain $updateFn 'cardLayoutType: normalizedCardConfig.variantId' 'Update function writes exact variant id'
MustContain $updateFn 'cardConfig: normalizedCardConfig' 'Update function writes cardConfig'
MustNotContain $updateFn 'case "standard":`n      return normalized;' 'Update function no longer preserves old standard as final value'

Write-Host ''
Write-Host 'Card layout upgrade verification passed.' -ForegroundColor Green
Write-Host 'Now run:'
Write-Host '  flutter clean'
Write-Host '  flutter pub get'
Write-Host '  flutter analyze'
Write-Host '  cd firebase/functions'
Write-Host '  npm run build'
