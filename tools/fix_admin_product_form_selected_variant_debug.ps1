# Fix undefined selectedVariant inside admin product save-debug dump.
#
# Run from repo root:
# powershell -ExecutionPolicy Bypass -File .\tools\fix_admin_product_form_selected_variant_debug.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$DialogPath = Join-Path $RepoRoot "apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart"

if (!(Test-Path $DialogPath)) {
  throw "File not found: $DialogPath"
}

$Backup = "$DialogPath.bak_fix_selected_variant_debug_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item -LiteralPath $DialogPath -Destination $Backup -Force

$Content = [System.IO.File]::ReadAllText($DialogPath)

# In _downloadProductSaveDebugFile(), cardStateFromDialog references selectedVariant,
# but the local variable is missing. It should be based on selectedCardConfig.variant.
$Anchor = "final productCardConfig = product.effectiveCardConfig.normalized();"

if ($Content -notmatch "final selectedVariant\s*=\s*selectedCardConfig\.variant;") {
  if ($Content.Contains($Anchor)) {
    $Content = $Content.Replace(
      $Anchor,
      "$Anchor`r`n    final selectedVariant = selectedCardConfig.variant;"
    )
    Write-Host "Inserted: final selectedVariant = selectedCardConfig.variant;" -ForegroundColor Green
  } else {
    throw "Could not find anchor line: $Anchor"
  }
} else {
  Write-Host "selectedVariant local variable already exists. No insert needed." -ForegroundColor Cyan
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
