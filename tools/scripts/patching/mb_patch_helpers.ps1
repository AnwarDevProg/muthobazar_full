<#
MuthoBazar Patch Helper Library

Purpose:
- Provide reusable backup, local-file collection, and patch application helpers.
- Keep future patch packages small and consistent.
- Use E-drive patch workflow paths requested for MuthoBazar.

Default paths:
- Repo: C:\Users\1\AndroidStudioProjects\MuthoBazar
- Backup replaced files: E:\MuthoBazar\BackUp_Files
- Local source copies: E:\MuthoBazar\Local_Files
- Patch ZIP/extract storage: E:\MuthoBazar\Patch_Files
#>

Set-StrictMode -Version Latest

$script:MBDefaultRepoPath = "C:\Users\1\AndroidStudioProjects\MuthoBazar"
$script:MBDefaultBackupRoot = "E:\MuthoBazar\BackUp_Files"
$script:MBDefaultLocalFilesRoot = "E:\MuthoBazar\Local_Files"
$script:MBDefaultPatchRoot = "E:\MuthoBazar\Patch_Files"

function Write-MBInfo {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-MBSuccess {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[OK]   $Message" -ForegroundColor Green
}

function Write-MBWarn {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-MBFail {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function New-MBTimestamp {
    return (Get-Date -Format "yyyyMMdd_HHmmss")
}

function Ensure-MBDirectory {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Resolve-MBRepoPath {
    param([string]$RepoPath = $script:MBDefaultRepoPath)

    if ([string]::IsNullOrWhiteSpace($RepoPath)) {
        $RepoPath = $script:MBDefaultRepoPath
    }

    return $RepoPath
}

function Assert-MBRepoPath {
    param([string]$RepoPath = $script:MBDefaultRepoPath)

    $ResolvedRepo = Resolve-MBRepoPath -RepoPath $RepoPath

    if (!(Test-Path $ResolvedRepo)) {
        throw "Repo path not found: $ResolvedRepo"
    }

    if (!(Test-Path (Join-Path $ResolvedRepo "pubspec.yaml")) -and !(Test-Path (Join-Path $ResolvedRepo "melos.yaml"))) {
        throw "This does not look like the MuthoBazar repo: $ResolvedRepo"
    }

    return $ResolvedRepo
}

function ConvertTo-MBSafeFileName {
    param([Parameter(Mandatory = $true)][string]$Text)
    return ($Text -replace '[\\/:*?"<>|]', '__')
}

function New-MBPatchBackupDir {
    param(
        [Parameter(Mandatory = $true)][string]$PatchName,
        [string]$BackupRoot = $script:MBDefaultBackupRoot
    )

    Ensure-MBDirectory -Path $BackupRoot
    $BackupDir = Join-Path $BackupRoot "$PatchName`_$(New-MBTimestamp)"
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    return $BackupDir
}

function Backup-MBFiles {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string]$BackupDir,
        [Parameter(Mandatory = $true)][string[]]$RelativePaths
    )

    foreach ($RelPath in $RelativePaths) {
        $Source = Join-Path $RepoPath $RelPath
        $Destination = Join-Path $BackupDir $RelPath
        $DestinationParent = Split-Path $Destination -Parent

        if (!(Test-Path $Source)) {
            Write-MBWarn "No existing file to back up: $RelPath"
            continue
        }

        Ensure-MBDirectory -Path $DestinationParent
        Copy-Item -Path $Source -Destination $Destination -Force
        Write-MBSuccess "Backed up: $RelPath"
    }
}

function Copy-MBPatchFiles {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][array]$FileMap
    )

    foreach ($Item in $FileMap) {
        $Source = $Item.Source
        $Target = $Item.Target

        if ([string]::IsNullOrWhiteSpace($Source) -or [string]::IsNullOrWhiteSpace($Target)) {
            throw "Invalid patch file map item. Source and Target are required."
        }

        if (!(Test-Path $Source)) {
            throw "Patch source file not found: $Source"
        }

        $TargetPath = Join-Path $RepoPath $Target
        $TargetParent = Split-Path $TargetPath -Parent
        Ensure-MBDirectory -Path $TargetParent

        Copy-Item -Path $Source -Destination $TargetPath -Force
        Write-MBSuccess "Patched: $Target"
    }
}

function Invoke-MBPatchApply {
    param(
        [Parameter(Mandatory = $true)][string]$PatchName,
        [Parameter(Mandatory = $true)][array]$FileMap,
        [string]$RepoPath = $script:MBDefaultRepoPath,
        [string]$BackupRoot = $script:MBDefaultBackupRoot
    )

    $ResolvedRepo = Assert-MBRepoPath -RepoPath $RepoPath

    Write-MBInfo "Patch: $PatchName"
    Write-MBInfo "Repo: $ResolvedRepo"
    Write-MBInfo "Backup root: $BackupRoot"

    $BackupDir = New-MBPatchBackupDir -PatchName $PatchName -BackupRoot $BackupRoot
    Write-MBInfo "Backup folder: $BackupDir"

    $Targets = @()
    foreach ($Item in $FileMap) {
        $Targets += [string]$Item.Target
    }

    Backup-MBFiles -RepoPath $ResolvedRepo -BackupDir $BackupDir -RelativePaths $Targets
    Copy-MBPatchFiles -RepoPath $ResolvedRepo -FileMap $FileMap

    Write-MBSuccess "Patch completed: $PatchName"
    Write-MBInfo "Backup saved at: $BackupDir"
}

function Collect-MBLocalFiles {
    param(
        [Parameter(Mandatory = $true)][string]$PatchName,
        [Parameter(Mandatory = $true)][string[]]$RelativePaths,
        [string]$RepoPath = $script:MBDefaultRepoPath,
        [string]$LocalFilesRoot = $script:MBDefaultLocalFilesRoot
    )

    $ResolvedRepo = Assert-MBRepoPath -RepoPath $RepoPath
    Ensure-MBDirectory -Path $LocalFilesRoot

    $OutDir = Join-Path $LocalFilesRoot "$PatchName`_$(New-MBTimestamp)"
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

    $Manifest = Join-Path $OutDir "_source_paths.txt"
    @(
        "Patch source collection: $PatchName",
        "Collected from: $ResolvedRepo",
        "Collected at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
        "Output: $OutDir",
        "",
        "Flatten rule: copied files are stored in this single folder using safe names.",
        ""
    ) | Out-File $Manifest -Encoding UTF8

    $UsedNames = @{}

    foreach ($RelPath in $RelativePaths) {
        if ([string]::IsNullOrWhiteSpace($RelPath)) {
            continue
        }

        $Source = Join-Path $ResolvedRepo $RelPath
        $SafeName = ConvertTo-MBSafeFileName -Text $RelPath

        if ($UsedNames.ContainsKey($SafeName)) {
            $UsedNames[$SafeName] = [int]$UsedNames[$SafeName] + 1
            $Extension = [System.IO.Path]::GetExtension($SafeName)
            $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($SafeName)
            $SafeName = "$BaseName`_$($UsedNames[$SafeName])$Extension"
        }
        else {
            $UsedNames[$SafeName] = 1
        }

        $Destination = Join-Path $OutDir $SafeName

        if (!(Test-Path $Source)) {
            Write-MBWarn "Missing: $RelPath"
            "MISSING: $RelPath" | Out-File $Manifest -Encoding UTF8 -Append
            continue
        }

        Copy-Item -Path $Source -Destination $Destination -Force
        Write-MBSuccess "Copied: $RelPath -> $SafeName"
        "$SafeName <= $RelPath" | Out-File $Manifest -Encoding UTF8 -Append
    }

    Write-MBSuccess "Local files copied to: $OutDir"
    return $OutDir
}

function Invoke-MBPatchZipFromDownloads {
    param(
        [Parameter(Mandatory = $true)][string]$PatchName,
        [string]$DownloadsDir = (Join-Path $env:USERPROFILE "Downloads"),
        [string]$PatchRoot = $script:MBDefaultPatchRoot
    )

    $ZipFromDownloads = Join-Path $DownloadsDir "$PatchName.zip"

    if (!(Test-Path $ZipFromDownloads)) {
        throw "Patch ZIP not found in Downloads: $ZipFromDownloads"
    }

    Ensure-MBDirectory -Path $PatchRoot

    $PatchWorkDir = Join-Path $PatchRoot $PatchName
    if (Test-Path $PatchWorkDir) {
        Remove-Item $PatchWorkDir -Recurse -Force
    }

    New-Item -ItemType Directory -Path $PatchWorkDir -Force | Out-Null

    $ZipInPatchDir = Join-Path $PatchWorkDir "$PatchName.zip"
    Copy-Item -Path $ZipFromDownloads -Destination $ZipInPatchDir -Force

    Expand-Archive -Path $ZipInPatchDir -DestinationPath $PatchWorkDir -Force

    $Apply = Get-ChildItem -Path $PatchWorkDir -Filter "apply.ps1" -Recurse | Select-Object -First 1
    if ($null -eq $Apply) {
        throw "apply.ps1 not found inside extracted patch folder: $PatchWorkDir"
    }

    Write-MBInfo "Running patch script: $($Apply.FullName)"
    powershell -ExecutionPolicy Bypass -File $Apply.FullName

    if ($LASTEXITCODE -ne 0) {
        throw "Patch script failed with exit code $LASTEXITCODE"
    }

    Write-MBSuccess "Patch ZIP workflow completed: $PatchName"
}
