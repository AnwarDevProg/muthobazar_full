# MuthoBazar Admin Card Studio Wire Patch
# Purpose:
# Your screenshots still show the old "Pick a card" and separate "Edit card" dialogs.
# This script wires admin_product_form_dialog.dart to the new single Card Studio
# with one persistent right-side phone preview.
#
# Run from repo root:
# powershell -ExecutionPolicy Bypass -File .\tools\wire_admin_card_studio_persistent_preview.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$DialogPath = Join-Path $RepoRoot "apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart"
$StudioTargetPath = Join-Path $RepoRoot "apps\admin_web\lib\features\products\widgets\card_studio\admin_product_card_studio_dialog.dart"
$StudioSourcePath = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "admin_product_card_studio_dialog.dart"

if (!(Test-Path $DialogPath)) {
  throw "admin_product_form_dialog.dart not found: $DialogPath"
}

if (!(Test-Path $StudioSourcePath)) {
  throw "Patch source studio file not found: $StudioSourcePath"
}

if (!(Test-Path (Split-Path $StudioTargetPath))) {
  New-Item -ItemType Directory -Force -Path (Split-Path $StudioTargetPath) | Out-Null
}

Copy-Item -LiteralPath $StudioSourcePath -Destination $StudioTargetPath -Force
Write-Host "Installed persistent-preview Card Studio:" -ForegroundColor Green
Write-Host $StudioTargetPath

$Backup = "$DialogPath.bak_wire_card_studio_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item -LiteralPath $DialogPath -Destination $Backup -Force

$Content = [System.IO.File]::ReadAllText($DialogPath)

function Add-ImportIfMissing {
  param(
    [string]$Content,
    [string]$ImportLine
  )

  if ($Content.Contains($ImportLine)) {
    return $Content
  }

  $ImportMatches = [System.Text.RegularExpressions.Regex]::Matches($Content, "(?m)^import\s+['""][^'""]+['""];\s*$")
  if ($ImportMatches.Count -gt 0) {
    $Last = $ImportMatches[$ImportMatches.Count - 1]
    return $Content.Insert($Last.Index + $Last.Length, "`r`n$ImportLine")
  }

  return "$ImportLine`r`n$Content"
}

function Find-MatchingBraceIndex {
  param(
    [string]$Text,
    [int]$OpenBraceIndex
  )

  $Depth = 0
  for ($i = $OpenBraceIndex; $i -lt $Text.Length; $i++) {
    $ch = $Text[$i]
    if ($ch -eq '{') {
      $Depth++
    } elseif ($ch -eq '}') {
      $Depth--
      if ($Depth -eq 0) {
        return $i
      }
    }
  }

  return -1
}

function Replace-DartMethod {
  param(
    [string]$Content,
    [string]$MethodName,
    [string]$Replacement
  )

  $MethodIndex = $Content.IndexOf($MethodName)
  if ($MethodIndex -lt 0) {
    Write-Host "Method not found for replacement: $MethodName" -ForegroundColor Yellow
    return $Content
  }

  # Start at beginning of the line where the method name is found.
  $Start = $Content.LastIndexOf("`n", [Math]::Max(0, $MethodIndex))
  if ($Start -lt 0) {
    $Start = 0
  } else {
    $Start = $Start + 1
  }

  $OpenBrace = $Content.IndexOf("{", $MethodIndex)
  if ($OpenBrace -lt 0) {
    throw "Could not find opening brace for method: $MethodName"
  }

  $CloseBrace = Find-MatchingBraceIndex -Text $Content -OpenBraceIndex $OpenBrace
  if ($CloseBrace -lt 0) {
    throw "Could not find closing brace for method: $MethodName"
  }

  # Include trailing whitespace/newlines after method.
  $End = $CloseBrace + 1
  while ($End -lt $Content.Length -and [char]::IsWhiteSpace($Content[$End])) {
    $End++
    if ($End -lt $Content.Length -and $Content[$End - 1] -eq "`n") {
      break
    }
  }

  return $Content.Substring(0, $Start) + $Replacement.TrimEnd() + "`r`n`r`n" + $Content.Substring($End)
}

function Insert-BeforeMethod {
  param(
    [string]$Content,
    [string]$BeforeMethodName,
    [string]$InsertText
  )

  if ($Content.Contains("_openCardStudioDialog(")) {
    return $Content
  }

  $Index = $Content.IndexOf($BeforeMethodName)
  if ($Index -lt 0) {
    Write-Host "Could not find insertion anchor: $BeforeMethodName" -ForegroundColor Yellow
    return $Content + "`r`n`r`n" + $InsertText
  }

  $Start = $Content.LastIndexOf("`n", [Math]::Max(0, $Index))
  if ($Start -lt 0) {
    $Start = 0
  } else {
    $Start = $Start + 1
  }

  return $Content.Substring(0, $Start) + $InsertText.TrimEnd() + "`r`n`r`n" + $Content.Substring($Start)
}

# 1. Import the new studio.
$Content = Add-ImportIfMissing `
  -Content $Content `
  -ImportLine "import 'card_studio/admin_product_card_studio_dialog.dart';"

# 2. Ensure _cardConfigDraft exists.
if ($Content -notmatch "MBCardInstanceConfig\?\s+_cardConfigDraft;") {
  if ($Content -match "AdminProductCardSettingsResult\?\s+_cardSettingsDraft;") {
    $Content = $Content -replace "AdminProductCardSettingsResult\?\s+_cardSettingsDraft;", "AdminProductCardSettingsResult? _cardSettingsDraft;`r`n  MBCardInstanceConfig? _cardConfigDraft;"
  } elseif ($Content -match "String\s+_cardLayoutType\s*=") {
    $Content = $Content -replace "(String\s+_cardLayoutType\s*=[^;]+;)", "`$1`r`n  MBCardInstanceConfig? _cardConfigDraft;"
  } else {
    Write-Host "Could not automatically place _cardConfigDraft field." -ForegroundColor Yellow
  }
}

# 3. Initialize _cardConfigDraft from initialCardConfig if possible.
if ($Content -notmatch "_cardConfigDraft\s*=\s*initialCardConfig;") {
  if ($Content -match "_cardSettingsDraft\s*=\s*_cardSettingsDraftFromConfig\(initialCardConfig\);") {
    $Content = $Content -replace "_cardSettingsDraft\s*=\s*_cardSettingsDraftFromConfig\(initialCardConfig\);", "_cardSettingsDraft = _cardSettingsDraftFromConfig(initialCardConfig);`r`n    _cardConfigDraft = initialCardConfig;"
  } elseif ($Content -match "_cardLayoutType\s*=\s*initialCardConfig\.variantId;") {
    $Content = $Content -replace "_cardLayoutType\s*=\s*initialCardConfig\.variantId;", "_cardLayoutType = initialCardConfig.variantId;`r`n    _cardConfigDraft = initialCardConfig;"
  }
}

# 4. Replace the old picker method. Buttons already call this method in your dialog.
$PickerReplacement = @'
  Future<void> _openCardPickerDialog(BuildContext context) async {
    await _openCardStudioDialog(
      context,
      initialMode: AdminProductCardStudioMode.pick,
    );
  }
'@

$Content = Replace-DartMethod `
  -Content $Content `
  -MethodName "_openCardPickerDialog" `
  -Replacement $PickerReplacement

# 5. Replace the old edit/settings method. Buttons already call this method too.
$SettingsReplacement = @'
  Future<void> _openSelectedCardSettingsDialog(BuildContext context) async {
    await _openCardStudioDialog(
      context,
      initialMode: AdminProductCardStudioMode.edit,
    );
  }
'@

$Content = Replace-DartMethod `
  -Content $Content `
  -MethodName "_openSelectedCardSettingsDialog" `
  -Replacement $SettingsReplacement

# 6. Insert the shared studio launcher and preview builder.
$StudioMethods = @'
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

$Content = Insert-BeforeMethod `
  -Content $Content `
  -BeforeMethodName "_buildCardSettingsOverride" `
  -InsertText $StudioMethods

# 7. Prefer full Card Studio config when saving card settings.
$BuildSettingsMethodIndex = $Content.IndexOf("_buildCardSettingsOverride")
if ($BuildSettingsMethodIndex -ge 0) {
  $PreviewLength = [Math]::Min(1400, $Content.Length - $BuildSettingsMethodIndex)
  $Preview = $Content.Substring($BuildSettingsMethodIndex, $PreviewLength)

  if ($Preview -notmatch "return configDraft\.settings;") {
    $BraceIndex = $Content.IndexOf("{", $BuildSettingsMethodIndex)
    if ($BraceIndex -ge 0) {
      $Guard = @'

    final selectedVariant = _selectedAdminCardVariant;
    final configDraft = _cardConfigDraft?.normalized();

    if (configDraft != null && configDraft.variant == selectedVariant) {
      return configDraft.settings;
    }
'@
      $Content = $Content.Insert($BraceIndex + 1, $Guard)
      Write-Host "Inserted _cardConfigDraft guard into _buildCardSettingsOverride()." -ForegroundColor Green
    }
  }
}

# 8. Prefer Card Studio config when building selected instance.
$SelectedInstanceIndex = $Content.IndexOf("_selectedCardInstanceConfig")
if ($SelectedInstanceIndex -ge 0) {
  $PreviewLength = [Math]::Min(1200, $Content.Length - $SelectedInstanceIndex)
  $Preview = $Content.Substring($SelectedInstanceIndex, $PreviewLength)

  if ($Preview -notmatch "configDraft != null && configDraft\.variant") {
    $BraceIndex = $Content.IndexOf("{", $SelectedInstanceIndex)
    if ($BraceIndex -ge 0) {
      $Guard = @'

    final configDraft = _cardConfigDraft?.normalized();
    if (configDraft != null &&
        configDraft.variant == _selectedAdminCardVariant) {
      return configDraft;
    }
'@
      $Content = $Content.Insert($BraceIndex + 1, $Guard)
      Write-Host "Inserted _cardConfigDraft guard into _selectedCardInstanceConfig." -ForegroundColor Green
    }
  }
}

# 9. Write back.
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($DialogPath, $Content, $Utf8NoBom)

Write-Host ""
Write-Host "Backup:" -ForegroundColor Yellow
Write-Host $Backup
Write-Host ""
Write-Host "Wired admin product form to the persistent-preview Card Studio." -ForegroundColor Green
Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
