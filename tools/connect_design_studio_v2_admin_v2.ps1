# MuthoBazar - Connect Design Studio V2 To Admin Product Dialog V2
# ----------------------------------------------------------------
# Fixes previous script failure:
# "Could not find existing Design Studio button block to patch."
#
# This V2 script uses a safer line-based insertion:
# - Adds _openCardDesignStudioV2Dialog(...) if missing.
# - Finds the existing _openCardDesignStudioDialog(context) button call.
# - Inserts "Open Studio V2" before the next "if (_hasCardDesignJson)" line.
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\connect_design_studio_v2_admin_v2.ps1
# flutter analyze

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$AdminRel = "apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart"
$AdminPath = Join-Path $RepoRoot $AdminRel

$SharedUiRel = "packages\shared_ui\lib\shared_ui.dart"
$SharedUiPath = Join-Path $RepoRoot $SharedUiRel

$V2MainRel = "packages\shared_ui\lib\widgets\common\product_cards\design_studio_v2\mb_card_design_studio_v2.dart"
$V2MainPath = Join-Path $RepoRoot $V2MainRel

$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\connect_design_studio_v2_admin_v2_$Timestamp"

Write-Host ""
Write-Host "MuthoBazar - Connect Design Studio V2 To Admin Product Dialog V2" -ForegroundColor Cyan
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

function Save-Utf8NoBom {
  param([string]$Path, [string]$Content)

  [System.IO.File]::WriteAllText(
    $Path,
    $Content,
    [System.Text.UTF8Encoding]::new($false)
  )
}

function Get-LeadingWhitespace {
  param([string]$Line)

  if ($Line -match '^(\s*)') {
    return $Matches[1]
  }

  return ""
}

if (!(Test-Path -LiteralPath $V2MainPath)) {
  throw "Design Studio V2 shell is missing. Apply Patch 1 first. Missing: $V2MainPath"
}

if (!(Test-Path -LiteralPath $AdminPath)) {
  throw "Admin product form file not found: $AdminPath"
}

New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null

# Ensure shared_ui exports the V2 shell.
if (Test-Path -LiteralPath $SharedUiPath) {
  $SharedUiText = [System.IO.File]::ReadAllText($SharedUiPath)
  $ExportLine = "export 'widgets/common/product_cards/design_studio_v2/mb_card_design_studio_v2_exports.dart';"

  if (!$SharedUiText.Contains($ExportLine)) {
    Backup-File -Path $SharedUiPath
    Save-Utf8NoBom -Path $SharedUiPath -Content ($SharedUiText.TrimEnd() + [Environment]::NewLine + $ExportLine + [Environment]::NewLine)
    Write-Host "Added Design Studio V2 export to shared_ui.dart." -ForegroundColor Green
  } else {
    Write-Host "Design Studio V2 export already exists." -ForegroundColor DarkGray
  }
}

Backup-File -Path $AdminPath
$Text = [System.IO.File]::ReadAllText($AdminPath)
$Original = $Text

# 1) Insert V2 open method.
if (!$Text.Contains("_openCardDesignStudioV2Dialog")) {
  $Method = @'
  Future<void> _openCardDesignStudioV2Dialog(BuildContext context) async {
    final previewProduct = _buildProductFromForm();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: SizedBox(
            width: size.width * 0.96,
            height: size.height * 0.92,
            child: MBCardDesignStudioV2(
              products: [previewProduct],
              initialProductIndex: 0,
              initialDesignJson: _cardDesignJson,
              title: 'Product Card Design Studio V2',
              wrapWithScaffold: false,
              onSave: (json) {
                Navigator.of(dialogContext).pop(json);
              },
            ),
          ),
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    final normalized = result.trim();

    setState(() {
      _cardDesignJson = normalized.isEmpty ? null : normalized;
    });
  }

'@

  $PossibleNeedles = @(
    "  Widget _buildCardDesignStudioBridgePanel(BuildContext context) {",
    "  Widget _buildCardDesignInfoChip(",
    "  MBProduct _buildProductFromForm() {"
  )

  $InsertedMethod = $false

  foreach ($Needle in $PossibleNeedles) {
    if ($Text.Contains($Needle)) {
      $Text = $Text.Replace($Needle, $Method + $Needle)
      $InsertedMethod = $true
      Write-Host "Added _openCardDesignStudioV2Dialog() before marker: $Needle" -ForegroundColor Green
      break
    }
  }

  if (!$InsertedMethod) {
    throw "Could not find a safe method insertion point. Send nearby code around _openCardDesignStudioDialog."
  }
} else {
  Write-Host "_openCardDesignStudioV2Dialog already exists." -ForegroundColor DarkGray
}

# 2) Insert button by line scanning.
if (!$Text.Contains("Open Studio V2")) {
  $Lines = $Text -split "\r?\n"
  $OpenCallIndex = -1

  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i] -match "_openCardDesignStudioDialog\(context\)") {
      $OpenCallIndex = $i
      break
    }
  }

  if ($OpenCallIndex -lt 0) {
    throw "Could not find _openCardDesignStudioDialog(context) call."
  }

  $InsertIndex = -1

  for ($i = $OpenCallIndex + 1; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i] -match "^\s*if\s*\(_hasCardDesignJson\)") {
      $InsertIndex = $i
      break
    }

    # Safety: stop if we enter a clearly unrelated method.
    if ($Lines[$i] -match "^\s{2}(Future|Widget|void|String|bool|int|double|MBProduct)\s+_") {
      break
    }
  }

  if ($InsertIndex -lt 0) {
    # Fallback: insert right after the first widget close after the old studio button.
    # This searches for a line containing only ")," after the old button call.
    for ($i = $OpenCallIndex + 1; $i -lt [Math]::Min($Lines.Count, $OpenCallIndex + 30); $i++) {
      if ($Lines[$i] -match "^\s*\),\s*$") {
        $InsertIndex = $i + 1
        break
      }
    }
  }

  if ($InsertIndex -lt 0) {
    throw "Could not find button insertion point after _openCardDesignStudioDialog(context)."
  }

  $Indent = Get-LeadingWhitespace -Line $Lines[$InsertIndex]

  $ButtonLines = @(
    "$Indent" + "OutlinedButton.icon(",
    "$Indent" + "  onPressed: () => _openCardDesignStudioV2Dialog(context),",
    "$Indent" + "  icon: const Icon(Icons.dashboard_customize_rounded),",
    "$Indent" + "  label: const Text('Open Studio V2'),",
    "$Indent" + "),"
  )

  $NewLines = New-Object System.Collections.Generic.List[string]

  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($i -eq $InsertIndex) {
      foreach ($ButtonLine in $ButtonLines) {
        $NewLines.Add($ButtonLine)
      }
    }

    $NewLines.Add($Lines[$i])
  }

  $Text = [string]::Join([Environment]::NewLine, $NewLines)
  Write-Host "Added Open Studio V2 button near existing Design Studio button." -ForegroundColor Green
} else {
  Write-Host "Open Studio V2 button already exists." -ForegroundColor DarkGray
}

if ($Text -ne $Original) {
  Save-Utf8NoBom -Path $AdminPath -Content $Text
  Write-Host "Admin product form patched." -ForegroundColor Green
} else {
  Write-Host "No admin file changes were required." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Patch completed." -ForegroundColor Green
Write-Host "Backup folder:" -ForegroundColor Yellow
Write-Host "  $BackupRoot"
Write-Host ""
Write-Host "Verify:" -ForegroundColor Cyan
Write-Host 'Select-String -Path .\apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart -Pattern "_openCardDesignStudioV2Dialog|Open Studio V2|MBCardDesignStudioV2"'
Write-Host ""
Write-Host "Then run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
Write-Host "cd .\apps\admin_web"
Write-Host "flutter run -d web-server --web-hostname localhost --web-port 8080"
