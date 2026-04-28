# MuthoBazar - Show New Design Studio Panel
# -----------------------------------------
# The previous save-flow patch added the methods/state, but the panel call
# was not inserted into _buildCardStyleSection().
#
# This script inserts:
#
#   _buildCardDesignStudioBridgePanel(context),
#   const SizedBox(height: 12),
#
# inside _buildCardStyleSection() as the first child of its Column.
#
# Run from repo root:
#
# cd C:\Users\1\AndroidStudioProjects\MuthoBazar
# powershell -ExecutionPolicy Bypass -File .\tools\show_new_design_studio_panel.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = (Get-Location).Path
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$TargetRel = "apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart"
$Target = Join-Path $RepoRoot $TargetRel
$BackupRoot = Join-Path (Split-Path $RepoRoot) "MuthoBazar_PatchBackups\show_new_design_studio_panel_$Timestamp"
$Backup = Join-Path $BackupRoot $TargetRel

Write-Host ""
Write-Host "MuthoBazar - Show New Design Studio Panel" -ForegroundColor Cyan
Write-Host "Repo root: $RepoRoot"
Write-Host ""

if (!(Test-Path -LiteralPath $Target)) {
  throw "Target file not found: $Target"
}

New-Item -ItemType Directory -Force -Path (Split-Path $Backup) | Out-Null
Copy-Item -LiteralPath $Target -Destination $Backup -Force

$Text = [System.IO.File]::ReadAllText($Target)

if (!$Text.Contains("Widget _buildCardDesignStudioBridgePanel(BuildContext context)")) {
  throw "Method _buildCardDesignStudioBridgePanel exists? Not found. Apply admin save-flow V2 first."
}

if (!$Text.Contains("Future<void> _openCardDesignStudioDialog(BuildContext context)")) {
  throw "Method _openCardDesignStudioDialog exists? Not found. Apply admin save-flow V2 first."
}

if ($Text.Contains("_buildCardDesignStudioBridgePanel(context),")) {
  Write-Host "Panel call already exists. Nothing to patch." -ForegroundColor Yellow
  Write-Host "Backup still created:" -ForegroundColor Yellow
  Write-Host "  $Backup"
  exit 0
}

$FunctionStart = $Text.IndexOf("Widget _buildCardStyleSection(BuildContext context)")
if ($FunctionStart -lt 0) {
  throw "Could not find _buildCardStyleSection(BuildContext context)."
}

$FunctionText = $Text.Substring($FunctionStart)

# Insert immediately after the first `children: [` inside _buildCardStyleSection.
$Pattern = [regex]"(?s)(Widget\s+_buildCardStyleSection\s*\(\s*BuildContext\s+context\s*\).*?children:\s*\[\s*)"
$Match = $Pattern.Match($FunctionText)

if (!$Match.Success) {
  throw "Could not find children: [ inside _buildCardStyleSection()."
}

$Insert = @"
          _buildCardDesignStudioBridgePanel(context),
          const SizedBox(height: 12),

"@

$GlobalInsertIndex = $FunctionStart + $Match.Index + $Match.Length
$NewText = $Text.Substring(0, $GlobalInsertIndex) + $Insert + $Text.Substring($GlobalInsertIndex)

[System.IO.File]::WriteAllText($Target, $NewText, [System.Text.UTF8Encoding]::new($false))

Write-Host "Patched successfully." -ForegroundColor Green
Write-Host "Inserted panel call into _buildCardStyleSection()." -ForegroundColor Green
Write-Host ""
Write-Host "Backup:" -ForegroundColor Yellow
Write-Host "  $Backup"
Write-Host ""
Write-Host "Verify:" -ForegroundColor Cyan
Write-Host 'Select-String -Path .\apps\admin_web\lib\features\products\widgets\admin_product_form_dialog.dart -Pattern "_buildCardDesignStudioBridgePanel\(context\)"'
Write-Host ""
Write-Host "Then run:" -ForegroundColor Cyan
Write-Host "flutter analyze"
