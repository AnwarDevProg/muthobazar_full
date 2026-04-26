# Fix Admin Product Form Dialog after Card Studio patch inserted card-config return
# into _downloadProductSaveDebugFile().
#
# Run from repo root:
# powershell -ExecutionPolicy Bypass -File .\tools\fix_admin_product_form_debug_return.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$DialogPath = Join-Path $RepoRoot "apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart"

if (!(Test-Path $DialogPath)) {
  throw "File not found: $DialogPath"
}

$Backup = "$DialogPath.bak_fix_debug_return_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item -LiteralPath $DialogPath -Destination $Backup -Force

$Content = [System.IO.File]::ReadAllText($DialogPath)

# This block was incorrectly inserted into _downloadProductSaveDebugFile(),
# which has return type Future<void>. It must not return MBCardSettingsOverride.
$WrongBlock = @'
    final selectedVariant = _selectedAdminCardVariant;
    final configDraft = _cardConfigDraft?.normalized();
    if (configDraft != null && configDraft.variant == selectedVariant) {
      return configDraft.settings;
    }

'@

if ($Content.Contains($WrongBlock)) {
  $Content = $Content.Replace($WrongBlock, "")
  Write-Host "Removed wrong MBCardSettingsOverride return block from debug method." -ForegroundColor Green
} else {
  Write-Host "Wrong block not found as exact text. Trying regex cleanup..." -ForegroundColor Yellow

  $Pattern = "(\s*)final selectedVariant = _selectedAdminCardVariant;\r?\n\s*final configDraft = _cardConfigDraft\?\.normalized\(\);\r?\n\s*if \(configDraft != null && configDraft\.variant == selectedVariant\) \{\r?\n\s*return configDraft\.settings;\r?\n\s*\}\r?\n"
  $Content = [System.Text.RegularExpressions.Regex]::Replace($Content, $Pattern, "`r`n")
}

# Put the same logic only inside MBCardSettingsOverride _buildCardSettingsOverride().
$Marker = "MBCardSettingsOverride _buildCardSettingsOverride() {"
$CorrectBlock = @'
    final selectedVariant = _selectedAdminCardVariant;
    final configDraft = _cardConfigDraft?.normalized();

    if (configDraft != null && configDraft.variant == selectedVariant) {
      return configDraft.settings;
    }

'@

if ($Content -match [System.Text.RegularExpressions.Regex]::Escape($Marker)) {
  $MethodIndex = $Content.IndexOf($Marker)
  $MethodPreviewLength = [Math]::Min(1200, $Content.Length - $MethodIndex)
  $MethodPreview = $Content.Substring($MethodIndex, $MethodPreviewLength)

  if ($MethodPreview -notmatch "return configDraft\.settings;") {
    $InsertPos = $MethodIndex + $Marker.Length
    $Content = $Content.Insert($InsertPos, "`r`n$CorrectBlock")
    Write-Host "Inserted configDraft guard into _buildCardSettingsOverride()." -ForegroundColor Green
  } else {
    Write-Host "_buildCardSettingsOverride() already contains configDraft guard." -ForegroundColor Cyan
  }
} else {
  Write-Host "Could not find _buildCardSettingsOverride(). No insert applied." -ForegroundColor Yellow
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
