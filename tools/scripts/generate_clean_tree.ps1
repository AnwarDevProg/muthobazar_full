param(
    [string]$RootPath = ".",
    [string]$OutputFile = "clean_structure.txt",
    [switch]$FoldersOnly = $false
)

$ErrorActionPreference = "Stop"

$ExcludedDirs = @(
    ".git",
    ".dart_tool",
    ".idea",
    ".vscode",
    ".gradle",
    ".github",
    "build",
    ".symlinks",
    ".plugin_symlinks",
    "Pods",
    "DerivedData",
    "ephemeral",
    "node_modules"
)

$ExcludedFiles = @(
    "*.iml",
    "*.log",
    "*.tmp",
    "*.lock",
    "pubspec.lock",
    ".DS_Store",
    "Thumbs.db",
    ".flutter-plugins",
    ".flutter-plugins-dependencies",
    "generated_plugin_registrant.dart",
    "GeneratedPluginRegistrant.*",
    "flutter_export_environment.sh",
    "Flutter-Generated.xcconfig",
    "Generated.xcconfig"
)

function Should-ExcludeDirectory {
    param([System.IO.DirectoryInfo]$Item)

    return $ExcludedDirs -contains $Item.Name
}

function Should-ExcludeFile {
    param([System.IO.FileInfo]$Item)

    foreach ($pattern in $ExcludedFiles) {
        if ($Item.Name -like $pattern) {
            return $true
        }
    }

    return $false
}

function Get-VisibleChildren {
    param([string]$Path)

    $children = Get-ChildItem -LiteralPath $Path -Force

    $visible = foreach ($child in $children) {
        if ($child.PSIsContainer) {
            if (-not (Should-ExcludeDirectory -Item $child)) {
                $child
            }
        }
        else {
            if (-not $FoldersOnly -and -not (Should-ExcludeFile -Item $child)) {
                $child
            }
        }
    }

    return $visible | Sort-Object @{ Expression = { -not $_.PSIsContainer } }, Name
}

function Write-Tree {
    param(
        [string]$CurrentPath,
        [string]$Prefix = ""
    )

    $items = @(Get-VisibleChildren -Path $CurrentPath)

    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $isLast = ($i -eq $items.Count - 1)

        $connector = if ($isLast) { "\---" } else { "+---" }
        Add-Content -LiteralPath $OutputFile -Value ("{0}{1}{2}" -f $Prefix, $connector, $item.Name)

        if ($item.PSIsContainer) {
            $childPrefix = if ($isLast) { "$Prefix    " } else { "$Prefix|   " }
            Write-Tree -CurrentPath $item.FullName -Prefix $childPrefix
        }
    }
}

$resolvedRoot = Resolve-Path -LiteralPath $RootPath
$rootItem = Get-Item -LiteralPath $resolvedRoot

if (Test-Path -LiteralPath $OutputFile) {
    Remove-Item -LiteralPath $OutputFile -Force
}

Set-Content -LiteralPath $OutputFile -Value "Folder PATH listing"
Add-Content -LiteralPath $OutputFile -Value ("Path: {0}" -f $rootItem.FullName)
Add-Content -LiteralPath $OutputFile -Value ("{0}." -f $rootItem.FullName.Substring(0,1))
Write-Tree -CurrentPath $rootItem.FullName

Write-Host ""
Write-Host "Clean structure generated:" -ForegroundColor Green
Write-Host (Resolve-Path -LiteralPath $OutputFile) -ForegroundColor Yellow

#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\generate_clean_tree.ps1" -OutputFile "repo_structure_clean.txt"
#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\generate_clean_tree.ps1" -RootPath ".\apps\customer_app\lib" -OutputFile "customer_lib_structure_clean.txt"
#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\generate_clean_tree.ps1" -RootPath ".\apps\admin_web\lib" -OutputFile "adminWeb_lib_structure_clean.txt"
#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\generate_clean_tree.ps1" -RootPath ".\packages" -OutputFile "packages_structure_clean.txt"