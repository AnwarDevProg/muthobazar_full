# MuthoBazar Control Center - Tab UI Version
# Author: Md Anwar Hossain
#
# Purpose:
# - Local Windows-only dashboard for MuthoBazar development commands.
# - Tab-style UI based on the requested layout.
# - Runs Flutter, Firebase, backup, GitHub, and helper commands locally.
#
# Run command:
# powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -NoExit -File .\muthobazar_control_center.ps1
#
# Recommended launcher BAT:
# powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -NoExit -File "%~dp0muthobazar_control_center.ps1"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# -----------------------------
# Configuration
# -----------------------------
$RepoRoot = "C:\Users\1\AndroidStudioProjects\MuthoBazar"
$AdminWebPath = Join-Path $RepoRoot "apps\admin_web"
$CustomerAppPath = Join-Path $RepoRoot "apps\customer_app"
$StaffAppPath = Join-Path $RepoRoot "apps\staff_app"
$FirebasePath = Join-Path $RepoRoot "firebase"
$FunctionsPath = Join-Path $FirebasePath "functions"

$BackupRoot = "E:\MuthoBazar\BackUp_Files"
$ProjectBackupRoot = "E:\MuthoBazar\ProjectBackup"
$LocalFilesRoot = "E:\MuthoBazar\Local_Files"
$PatchFilesRoot = "E:\MuthoBazar\Patch_Files"
$LogRoot = "E:\MuthoBazar\ControlCenter_Logs"
$ToolsRoot = Join-Path $RepoRoot "tools"
$ScriptsPath = Join-Path $ToolsRoot "scripts"
$BackgroundRemoverPath = Join-Path $ToolsRoot "background_remover_service"

$DefaultAdminWebPort = 8080
$DefaultAdminWebHost = "localhost"
$DefaultAdminWebUrl = "http://$DefaultAdminWebHost`:$DefaultAdminWebPort"
$DefaultAdminWebWaitTimeoutSeconds = 180
$DefaultChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$DefaultChromePathX86 = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$AdminWebChromeProfileRoot = Join-Path $env:TEMP "MuthoBazar_Admin_Chrome_Profile"
$DefaultCommitMessage = "sync latest local work"

# -----------------------------
# Global UI objects
# -----------------------------
$script:ActiveTab = "Customer App"
$script:NavButtons = @{}
$script:ContentButtons = @()
$script:ContentControls = @()
$script:LogBox = $null
$script:TerminalBox = $null
$script:CommitMessageTextBox = $null
$script:FunctionComboBox = $null
$script:SelectedFunctionLabel = $null
$script:SelectedFunctionsListBox = $null
$script:AddFunctionButton = $null
$script:Form = $null
$script:ContentPanel = $null
$script:ActiveMainTab = "Apps"
$script:MainTabButtons = @{}
$script:RunningTerminals = @{}
$script:PsEditorBox = $null
$script:SkipAdminWebClean = $false
$script:SkipAdminWebCleanCheckBox = $null
$script:AdminWebServerProcess = $null
$script:AdminWebChromeProcess = $null
$script:AdminWebLogFile = $null

# -----------------------------
# Colors and fonts
# -----------------------------
$ColorHeader = [System.Drawing.Color]::FromArgb(78, 130, 186)
$ColorHeaderDark = [System.Drawing.Color]::FromArgb(47, 85, 128)
$ColorBg = [System.Drawing.Color]::White
$ColorCanvas = [System.Drawing.Color]::FromArgb(248, 250, 252)
$ColorTabSelected = [System.Drawing.Color]::FromArgb(242, 232, 204)
$ColorText = [System.Drawing.Color]::FromArgb(15, 23, 42)
$ColorBlueText = [System.Drawing.Color]::FromArgb(19, 89, 160)
$ColorGreen = [System.Drawing.Color]::FromArgb(0, 176, 80)
$ColorOrange = [System.Drawing.Color]::FromArgb(255, 112, 20)
$ColorBlue = [System.Drawing.Color]::FromArgb(83, 140, 210)
$ColorDeepBlue = [System.Drawing.Color]::FromArgb(37, 99, 235)
$ColorPurple = [System.Drawing.Color]::FromArgb(124, 58, 237)
$ColorRed = [System.Drawing.Color]::FromArgb(240, 0, 0)
$ColorSlate = [System.Drawing.Color]::FromArgb(71, 85, 105)
$ColorBlack = [System.Drawing.Color]::FromArgb(8, 8, 8)
$ColorLog = [System.Drawing.Color]::FromArgb(15, 23, 42)
$ColorWhite = [System.Drawing.Color]::White

$FontTitle = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$FontTab = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$FontButton = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$FontNormal = New-Object System.Drawing.Font("Segoe UI", 9)
$FontLarge = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Regular)
$FontLog = New-Object System.Drawing.Font("Consolas", 9)

# -----------------------------
# Helpers
# -----------------------------
function Ensure-Folder {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Get-TimeStamp {
    return (Get-Date).ToString("yyyyMMdd_HHmmss")
}

function Append-Log {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][AllowNull()][string]$Message)

    $time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$time] $Message"

    if ($null -ne $script:LogBox) {
        $script:LogBox.AppendText($line + [Environment]::NewLine)
        $script:LogBox.ScrollToCaret()
    }

    if ($null -ne $script:TerminalBox) {
        $script:TerminalBox.AppendText($Message + [Environment]::NewLine)
        $script:TerminalBox.ScrollToCaret()
    }

    [System.Windows.Forms.Application]::DoEvents()
}

function Confirm-Action {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $true)][string]$Title
    )

    $result = [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    return ($result -eq [System.Windows.Forms.DialogResult]::Yes)
}

function Test-RequiredPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Label
    )

    if (-not (Test-Path $Path)) {
        Append-Log "ERROR: $Label path not found: $Path"
        [System.Windows.Forms.MessageBox]::Show(
            "$Label path not found:`n$Path",
            "Path Missing",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
        return $false
    }

    return $true
}

function Invoke-LoggedCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$WorkingDirectory,
        [Parameter(Mandatory = $true)][string[]]$Commands
    )

    if (-not (Test-RequiredPath -Path $WorkingDirectory -Label $Title)) {
        return
    }

    Ensure-Folder -Path $LogRoot
    $stamp = Get-TimeStamp
    $safeTitle = ($Title -replace '[^a-zA-Z0-9_-]', '_')
    $logFile = Join-Path $LogRoot "$safeTitle`_$stamp.log"

    Append-Log "START: $Title"
    Append-Log "Path : $WorkingDirectory"
    Append-Log "Log  : $logFile"

    $commandText = @"
`$ErrorActionPreference = 'Continue'
Set-Location -LiteralPath '$WorkingDirectory'
$($Commands -join "`r`n")
exit `$LASTEXITCODE
"@

    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($commandText))

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo.FileName = "powershell.exe"
    $process.StartInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded"
    $process.StartInfo.WorkingDirectory = $WorkingDirectory
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true
    $process.StartInfo.CreateNoWindow = $true

    $null = $process.Start()

    while (-not $process.HasExited) {
        while (-not $process.StandardOutput.EndOfStream) {
            $output = $process.StandardOutput.ReadLine()
            if ($null -ne $output) {
                if (-not [string]::IsNullOrWhiteSpace($output)) {
                    Append-Log $output
                }
                Add-Content -Path $logFile -Value $output
            }
        }

        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 100
    }

    while (-not $process.StandardOutput.EndOfStream) {
        $output = $process.StandardOutput.ReadLine()
        if ($null -ne $output) {
            if (-not [string]::IsNullOrWhiteSpace($output)) {
                Append-Log $output
            }
            Add-Content -Path $logFile -Value $output
        }
    }

    while (-not $process.StandardError.EndOfStream) {
        $errorLine = $process.StandardError.ReadLine()
        Append-Log "ERROR: $errorLine"
        Add-Content -Path $logFile -Value "ERROR: $errorLine"
    }

    Append-Log "END: $Title | ExitCode: $($process.ExitCode)"

    if ($process.ExitCode -ne 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "$Title finished with errors. Check log:`n$logFile",
            "Command Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
    }
}

function Start-TerminalCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$WorkingDirectory,
        [Parameter(Mandatory = $true)][string[]]$Commands
    )

    if (-not (Test-RequiredPath -Path $WorkingDirectory -Label $Title)) {
        return
    }

    Append-Log "OPEN TERMINAL: $Title"
    Append-Log "Path: $WorkingDirectory"

    $commandText = @"
Set-Location -LiteralPath '$WorkingDirectory'
Write-Host '========================================'
Write-Host '$Title'
Write-Host 'Path: $WorkingDirectory'
Write-Host '========================================'
$($Commands -join "`r`n")
Write-Host ''
Write-Host 'Command finished or stopped. Press any key to close this window...'
`$null = `$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
"@

    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($commandText))
    $startedProcess = Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded" -WorkingDirectory $WorkingDirectory -PassThru

    if ($null -ne $startedProcess) {
        $script:RunningTerminals[$Title] = $startedProcess
        Append-Log "Started external terminal for '$Title'. PID: $($startedProcess.Id)"
    }
}


function Start-AutoCloseTerminalCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$WorkingDirectory,
        [Parameter(Mandatory = $true)][string[]]$Commands,
        [string]$RunnerPrefix = "command"
    )

    if (-not (Test-RequiredPath -Path $WorkingDirectory -Label $Title)) {
        return
    }

    Ensure-Folder -Path $LogRoot
    $runnerFolder = Join-Path $LogRoot "command_runners"
    Ensure-Folder -Path $runnerFolder

    $stamp = Get-TimeStamp
    $safePrefix = ($RunnerPrefix -replace '[^a-zA-Z0-9_-]', '_')
    $runnerScriptPath = Join-Path $runnerFolder "$safePrefix`_$stamp.ps1"
    $runnerLogFile = Join-Path $runnerFolder "$safePrefix`_$stamp.log"
    $commandBlock = $Commands -join "`r`n"

    $runnerScript = @"
`$ErrorActionPreference = 'Stop'
`$Host.UI.RawUI.WindowTitle = '$Title'

function Write-Step {
    param([string]`$Message)
    `$time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    `$line = "[`$time] `$Message"
    Write-Host `$line
    Add-Content -LiteralPath '$runnerLogFile' -Value `$line
}

try {
    Set-Location -LiteralPath '$WorkingDirectory'
    Write-Step 'START: $Title'
    Write-Step 'Path : $WorkingDirectory'
    Write-Step 'Log  : $runnerLogFile'

$commandBlock

    Write-Step 'SUCCESS: $Title completed.'
    Start-Sleep -Milliseconds 700
    exit 0
}
catch {
    Write-Step "FAILED: `$(`$_.Exception.Message)"
    Write-Step "FAILED TYPE: `$(`$_.Exception.GetType().FullName)"
    Write-Host ''
    Write-Host 'Process failed. This PowerShell window will stay open for troubleshooting.' -ForegroundColor Yellow
    Write-Host 'Check the log file above for details.' -ForegroundColor Yellow
    [void](Read-Host 'Press Enter to close this failed terminal')
    exit 1
}
"@

    Set-Content -LiteralPath $runnerScriptPath -Value $runnerScript -Encoding UTF8

    Append-Log "OPEN TERMINAL: $Title"
    Append-Log "Path: $WorkingDirectory"
    Append-Log "Runner: $runnerScriptPath"
    Append-Log "Log   : $runnerLogFile"
    Append-Log "Auto-close rule: success closes automatically; failure stays open."

    $startedProcess = Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$runnerScriptPath`"" `
        -WorkingDirectory $WorkingDirectory `
        -PassThru

    if ($null -ne $startedProcess) {
        Append-Log "Started auto-close terminal for '$Title'. PID: $($startedProcess.Id)"
    }
}

function Open-Folder {
    param([Parameter(Mandatory = $true)][string]$Path)

    Ensure-Folder -Path $Path
    Start-Process explorer.exe $Path
}

function Clear-ContentPanel {
    foreach ($control in @($script:ContentControls)) {
        try {
            $script:ContentPanel.Controls.Remove($control)
            $control.Dispose()
        } catch {
            # Ignore cleanup errors so tab switching never breaks the UI.
        }
    }

    # Extra safety: remove any dynamic control that was not tracked correctly.
    $script:ContentPanel.Controls.Clear()
    $script:ContentControls = @()
    $script:FunctionComboBox = $null
    $script:SelectedFunctionLabel = $null
    $script:SelectedFunctionsListBox = $null
    $script:AddFunctionButton = $null
    $script:SkipAdminWebCleanCheckBox = $null
}

function Add-ContentControl {
    param([Parameter(Mandatory = $true)]$Control)
    $script:ContentPanel.Controls.Add($Control)
    $script:ContentControls += $Control

    try {
        if ($Control -isnot [System.Windows.Forms.Panel]) {
            $Control.BringToFront()
        }
    } catch {
        # Ignore z-order errors.
    }
}

function New-ActionButton {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][int]$X,
        [Parameter(Mandatory = $true)][int]$Y,
        [Parameter(Mandatory = $true)][scriptblock]$OnClick,
        [int]$Width = 205,
        [int]$Height = 42,
        [System.Drawing.Color]$BackColor = $ColorBlue
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Size = New-Object System.Drawing.Size($Width, $Height)
    $button.Location = New-Object System.Drawing.Point($X, $Y)
    $button.Font = $FontButton
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.FlatAppearance.BorderSize = 0
    $button.ForeColor = [System.Drawing.Color]::White
    $button.BackColor = $BackColor
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $button.Add_Click($OnClick)

    Add-ContentControl -Control $button
    $button.BringToFront()
    return $button
}

function New-InfoLabel {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Text,
        [Parameter(Mandatory = $true)][int]$X,
        [Parameter(Mandatory = $true)][int]$Y,
        [int]$Width = 400,
        [int]$Height = 28,
        [System.Drawing.Font]$Font = $FontNormal,
        [System.Drawing.Color]$BackColor = $ColorBg,
        [System.Drawing.Color]$ForeColor = $ColorText,
        [System.Drawing.ContentAlignment]$Align = [System.Drawing.ContentAlignment]::MiddleLeft
    )

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.Location = New-Object System.Drawing.Point($X, $Y)
    $label.Size = New-Object System.Drawing.Size($Width, $Height)
    $label.Font = $Font
    $label.ForeColor = $ForeColor
    $label.BackColor = $BackColor
    $label.TextAlign = $Align
    Add-ContentControl -Control $label
    return $label
}

function New-BackgroundPanel {
    param(
        [Parameter(Mandatory = $true)][int]$X,
        [Parameter(Mandatory = $true)][int]$Y,
        [Parameter(Mandatory = $true)][int]$Width,
        [Parameter(Mandatory = $true)][int]$Height,
        [System.Drawing.Color]$BackColor = $ColorCanvas
    )

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point($X, $Y)
    $panel.Size = New-Object System.Drawing.Size($Width, $Height)
    $panel.BackColor = $BackColor
    Add-ContentControl -Control $panel
    $panel.SendToBack()
    return $panel
}


function Test-WebUrlReady {
    param([Parameter(Mandatory = $true)][string]$Url)

    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -Method Get -TimeoutSec 3
        return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500)
    } catch {
        return $false
    }
}

function Get-AdminChromePath {
    if (Test-Path -LiteralPath $DefaultChromePath) {
        return $DefaultChromePath
    }

    if (Test-Path -LiteralPath $DefaultChromePathX86) {
        return $DefaultChromePathX86
    }

    return $null
}

function Invoke-ControlCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$WorkingDirectory,
        [Parameter(Mandatory = $true)][string[]]$Commands
    )

    if (-not (Test-RequiredPath -Path $WorkingDirectory -Label $Title)) {
        return 1
    }

    Ensure-Folder -Path $LogRoot
    $stamp = Get-TimeStamp
    $safeTitle = ($Title -replace '[^a-zA-Z0-9_-]', '_')
    $stdoutFile = Join-Path $LogRoot "$safeTitle`_$stamp.out.log"
    $stderrFile = Join-Path $LogRoot "$safeTitle`_$stamp.err.log"

    Append-Log "START: $Title"
    Append-Log "Path : $WorkingDirectory"

    $commandText = @"
`$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath '$WorkingDirectory'
$($Commands -join "`r`n")
exit `$LASTEXITCODE
"@

    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($commandText))

    try {
        $process = Start-Process powershell.exe `
            -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-EncodedCommand", $encoded) `
            -WorkingDirectory $WorkingDirectory `
            -RedirectStandardOutput $stdoutFile `
            -RedirectStandardError $stderrFile `
            -WindowStyle Hidden `
            -Wait `
            -PassThru

        if (Test-Path -LiteralPath $stdoutFile) {
            foreach ($line in (Get-Content -LiteralPath $stdoutFile -ErrorAction SilentlyContinue)) {
                if (-not [string]::IsNullOrWhiteSpace($line)) {
                    Append-Log $line
                }
            }
        }

        if (Test-Path -LiteralPath $stderrFile) {
            foreach ($line in (Get-Content -LiteralPath $stderrFile -ErrorAction SilentlyContinue)) {
                if (-not [string]::IsNullOrWhiteSpace($line)) {
                    Append-Log "ERROR: $line"
                }
            }
        }

        Append-Log "END: $Title | ExitCode: $($process.ExitCode)"
        return [int]$process.ExitCode
    } catch {
        Append-Log "ERROR running '$Title': $($_.Exception.Message)"
        return 1
    }
}

function Stop-DedicatedAdminChrome {
    $profileMarker = $AdminWebChromeProfileRoot
    $stoppedCount = 0

    try {
        $chromeProcesses = @(Get-CimInstance Win32_Process -Filter "name = 'chrome.exe'" -ErrorAction SilentlyContinue | Where-Object {
            $null -ne $_.CommandLine -and $_.CommandLine.Contains($profileMarker)
        })

        foreach ($chrome in $chromeProcesses) {
            Append-Log "Closing MuthoBazar Chrome window. PID: $($chrome.ProcessId)"
            Stop-Process -Id $chrome.ProcessId -Force -ErrorAction SilentlyContinue
            $stoppedCount++
        }
    } catch {
        Append-Log "WARNING: Could not scan/close dedicated Chrome process: $($_.Exception.Message)"
    }

    if ($stoppedCount -eq 0 -and $null -ne $script:AdminWebChromeProcess) {
        try {
            $liveChrome = Get-Process -Id $script:AdminWebChromeProcess.Id -ErrorAction SilentlyContinue
            if ($null -ne $liveChrome) {
                Append-Log "Closing tracked MuthoBazar Chrome window. PID: $($liveChrome.Id)"
                Stop-Process -Id $liveChrome.Id -Force -ErrorAction SilentlyContinue
                $stoppedCount++
            }
        } catch {
            Append-Log "WARNING: Could not close tracked Chrome window: $($_.Exception.Message)"
        }
    }

    $script:AdminWebChromeProcess = $null

    if ($stoppedCount -gt 0) {
        Append-Log "Closed dedicated MuthoBazar Chrome process(es): $stoppedCount"
    }
}

function Open-DedicatedAdminChrome {
    param([Parameter(Mandatory = $true)][string]$Url)

    $chromePath = Get-AdminChromePath
    if ([string]::IsNullOrWhiteSpace($chromePath)) {
        Append-Log "Chrome not found. Opening URL with default browser: $Url"
        Start-Process $Url
        return
    }

    Ensure-Folder -Path $AdminWebChromeProfileRoot

    try {
        $chromeArgs = @(
            "--new-window",
            "--user-data-dir=$AdminWebChromeProfileRoot",
            "--disable-extensions",
            $Url
        )

        $process = Start-Process -FilePath $chromePath -ArgumentList $chromeArgs -PassThru
        $script:AdminWebChromeProcess = $process
        Append-Log "Opened dedicated Chrome window: $Url"
    } catch {
        Append-Log "ERROR opening Chrome: $($_.Exception.Message)"
        Start-Process $Url
    }
}

function Close-AdminWebServerConsole {
    $closed = $false

    if ($null -ne $script:AdminWebServerProcess) {
        try {
            $live = Get-Process -Id $script:AdminWebServerProcess.Id -ErrorAction SilentlyContinue
            if ($null -ne $live) {
                Append-Log "Closing Admin Web Server PowerShell window. PID: $($live.Id)"
                if ($live.MainWindowHandle -ne 0) {
                    [void]$live.CloseMainWindow()
                    Start-Sleep -Milliseconds 800
                }

                $live = Get-Process -Id $script:AdminWebServerProcess.Id -ErrorAction SilentlyContinue
                if ($null -ne $live) {
                    Stop-Process -Id $live.Id -Force -ErrorAction SilentlyContinue
                }
                $closed = $true
            }
        } catch {
            Append-Log "WARNING: Could not close Admin Web Server console: $($_.Exception.Message)"
        }
    }

    if ($script:RunningTerminals.ContainsKey("Admin Web Server")) {
        $script:RunningTerminals.Remove("Admin Web Server")
    }

    $script:AdminWebServerProcess = $null

    if ($closed) {
        Append-Log "Admin Web Server PowerShell window closed."
    }
}

function Open-AdminWebServer {
    $runnerScript = Join-Path $ScriptsPath "run_admin_web_chrome.ps1"

    if (-not (Test-RequiredPath -Path $ScriptsPath -Label "Tools Scripts Folder")) {
        return
    }

    if (-not (Test-Path -LiteralPath $runnerScript)) {
        Append-Log "ERROR: Admin web runner script not found: $runnerScript"
        [System.Windows.Forms.MessageBox]::Show(
            "Admin web runner script not found:`n$runnerScript",
            "Open Web Server Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
        return
    }

    $command = 'powershell -ExecutionPolicy Bypass -File ".\run_admin_web_chrome.ps1"'
    if ($script:SkipAdminWebClean) {
        $command = "$command -SkipClean"
        Append-Log "Open Web Server: calling existing run_admin_web_chrome.ps1 with -SkipClean."
    } else {
        Append-Log "Open Web Server: calling existing run_admin_web_chrome.ps1."
    }

    Start-TerminalCommand -Title "Open Web Server" -WorkingDirectory $ScriptsPath -Commands @($command)
}


# -----------------------------
# Commands
# -----------------------------
function Run-CustomerApp {
    Start-TerminalCommand -Title "Run Customer App" -WorkingDirectory $CustomerAppPath -Commands @("flutter run")
}

function Clean-CustomerApp {
    Invoke-LoggedCommand -Title "Clean Customer App" -WorkingDirectory $CustomerAppPath -Commands @("flutter clean")
}

function PubGet-CustomerApp {
    Invoke-LoggedCommand -Title "Pub Get Customer App" -WorkingDirectory $CustomerAppPath -Commands @("flutter pub get")
}

function Run-AdminWeb {
    Start-TerminalCommand -Title "Run Admin App" -WorkingDirectory $AdminWebPath -Commands @("flutter run -d web-server --web-hostname localhost --web-port $DefaultAdminWebPort")
}

function Clean-AdminWeb {
    Invoke-LoggedCommand -Title "Clean Admin Web" -WorkingDirectory $AdminWebPath -Commands @("flutter clean")
}

function PubGet-AdminWeb {
    Invoke-LoggedCommand -Title "Pub Get Admin Web" -WorkingDirectory $AdminWebPath -Commands @("flutter pub get")
}

function Open-AdminWebBrowser {
    Open-DedicatedAdminChrome -Url $DefaultAdminWebUrl
}

function Run-StaffApp {
    Start-TerminalCommand -Title "Run Staff App" -WorkingDirectory $StaffAppPath -Commands @("flutter run")
}

function Clean-StaffApp {
    Invoke-LoggedCommand -Title "Clean Staff App" -WorkingDirectory $StaffAppPath -Commands @("flutter clean")
}

function PubGet-StaffApp {
    Invoke-LoggedCommand -Title "Pub Get Staff App" -WorkingDirectory $StaffAppPath -Commands @("flutter pub get")
}

function Build-FirebaseFunctions {
    Invoke-LoggedCommand -Title "Build Firebase Functions" -WorkingDirectory $FunctionsPath -Commands @("npm run build")
}

function Deploy-AllFunctions {
    if (-not (Confirm-Action -Title "Deploy All Functions" -Message "This will build and deploy all Firebase Functions to the live Firebase project. Continue?")) {
        Append-Log "CANCELLED: Deploy All Functions"
        return
    }

    if (-not (Test-RequiredPath -Path $FunctionsPath -Label "Firebase Functions")) {
        return
    }

    if (-not (Test-RequiredPath -Path $FirebasePath -Label "Firebase Root")) {
        return
    }

    Ensure-Folder -Path $LogRoot
    $runnerFolder = Join-Path $LogRoot "firebase_runners"
    Ensure-Folder -Path $runnerFolder

    $stamp = Get-TimeStamp
    $logFile = Join-Path $runnerFolder "deploy_all_functions_$stamp.log"
    $runnerScriptPath = Join-Path $runnerFolder "deploy_all_functions_$stamp.ps1"

    $runnerScript = @"
`$ErrorActionPreference = 'Stop'
`$FunctionsPath = '$FunctionsPath'
`$FirebasePath = '$FirebasePath'
`$LogFile = '$logFile'
`$Host.UI.RawUI.WindowTitle = 'MuthoBazar Deploy All Functions'

function Write-Step {
    param([string]`$Message)
    `$time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    `$line = "[`$time] `$Message"
    Write-Host `$line
    Add-Content -LiteralPath `$LogFile -Value `$line
}

function Invoke-LoggedNativeCommand {
    param(
        [string]`$Title,
        [scriptblock]`$Command
    )

    Write-Step `$Title
    & `$Command 2>&1 | Tee-Object -FilePath `$LogFile -Append
    if (`$LASTEXITCODE -ne 0) {
        throw "Failed: `$Title. ExitCode: `$LASTEXITCODE"
    }
}

try {
    Write-Step 'START: Deploy All Firebase Functions'

    Set-Location -LiteralPath `$FunctionsPath
    Invoke-LoggedNativeCommand -Title 'npm run build' -Command { npm run build }

    Set-Location -LiteralPath `$FirebasePath
    Invoke-LoggedNativeCommand -Title 'firebase deploy --only functions' -Command { firebase deploy --only functions }

    Write-Step 'SUCCESS: Deploy All Firebase Functions completed.'
    Write-Host ''
    Write-Host 'Deploy completed successfully. This window will close automatically.' -ForegroundColor Green
    Start-Sleep -Milliseconds 1200
    exit 0
}
catch {
    Write-Step "FAILED: `$(`$_.Exception.Message)"
    Write-Host ''
    Write-Host 'Deploy failed. This PowerShell window will stay open for troubleshooting.' -ForegroundColor Yellow
    Write-Host "Log file: `$LogFile" -ForegroundColor Yellow
    [void](Read-Host 'Press Enter to close this failed terminal')
    exit 1
}
"@

    Set-Content -LiteralPath $runnerScriptPath -Value $runnerScript -Encoding UTF8

    Append-Log "START: Deploy All Functions launched in separate PowerShell."
    Append-Log "Runner: $runnerScriptPath"
    Append-Log "Log   : $logFile"
    Append-Log "Auto-close rule: success closes automatically; failure stays open."

    try {
        $process = Start-Process -FilePath "powershell.exe" `
            -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$runnerScriptPath`"" `
            -WorkingDirectory $FirebasePath `
            -PassThru

        if ($null -ne $process) {
            Append-Log "Started Firebase deploy terminal. PID: $($process.Id)"
        }
    }
    catch {
        Append-Log "ERROR: Failed to start Firebase deploy PowerShell: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to start Firebase deploy PowerShell:`n$($_.Exception.Message)",
            "Deploy Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}



function Deploy-SelectedFunction {
    $selectedNames = New-Object System.Collections.Generic.List[string]

    if ($null -ne $script:SelectedFunctionsListBox) {
        foreach ($item in $script:SelectedFunctionsListBox.Items) {
            $name = [string]$item
            if (-not [string]::IsNullOrWhiteSpace($name)) {
                $selectedNames.Add($name)
            }
        }
    }

    if ($selectedNames.Count -eq 0 -and $null -ne $script:FunctionComboBox -and $null -ne $script:FunctionComboBox.SelectedItem) {
        $selectedNames.Add([string]$script:FunctionComboBox.SelectedItem)
    }

    if ($selectedNames.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "Please select or add at least one function first.",
            "No Function Selected",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    $functionListText = ($selectedNames -join "`n")
    if (-not (Confirm-Action -Title "Deploy Selected Functions" -Message "Deploy these selected Firebase Functions?`n`n$functionListText")) {
        Append-Log "CANCELLED: Deploy Selected Functions"
        return
    }

    $targets = ($selectedNames | ForEach-Object { "functions:$_" }) -join ","
    Invoke-LoggedCommand -Title "Deploy Selected Firebase Functions" -WorkingDirectory $FunctionsPath -Commands @(
        "npm run build",
        "Set-Location -LiteralPath '$FirebasePath'",
        "firebase deploy --only `"$targets`""
    )
}

function Deploy-StorageRule {
    if (-not (Confirm-Action -Title "Deploy Storage Rules" -Message "This will deploy Firebase Storage rules. Continue?")) {
        Append-Log "CANCELLED: Deploy Storage Rules"
        return
    }

    Invoke-LoggedCommand -Title "Deploy Storage Rules" -WorkingDirectory $FirebasePath -Commands @("firebase deploy --only storage")
}

function Deploy-FirestoreRule {
    if (-not (Confirm-Action -Title "Deploy Firestore Rules" -Message "This will deploy Firestore rules/indexes if configured. Continue?")) {
        Append-Log "CANCELLED: Deploy Firestore Rules"
        return
    }

    Invoke-LoggedCommand -Title "Deploy Firestore Rules" -WorkingDirectory $FirebasePath -Commands @("firebase deploy --only firestore")
}

function Get-FirebaseFunctionNames {
    $indexFile = Join-Path $FunctionsPath "src\index.ts"
    $names = New-Object System.Collections.Generic.List[string]

    if (-not (Test-Path $indexFile)) {
        Append-Log "WARNING: Function index file not found: $indexFile"
        return $names
    }

    $content = Get-Content -Path $indexFile -Raw

    $patterns = @(
        'export\s*\{([^}]+)\}',
        'export\s+const\s+([A-Za-z0-9_]+)\s*=',
        'exports\.([A-Za-z0-9_]+)\s*='
    )

    foreach ($pattern in $patterns) {
        $matches = [regex]::Matches($content, $pattern)
        foreach ($m in $matches) {
            if ($pattern -eq 'export\s*\{([^}]+)\}') {
                $items = $m.Groups[1].Value -split ','
                foreach ($item in $items) {
                    $clean = ($item.Trim() -replace '\s+as\s+.*$', '').Trim()
                    if (-not [string]::IsNullOrWhiteSpace($clean) -and -not $names.Contains($clean)) {
                        $names.Add($clean)
                    }
                }
            } else {
                $clean = $m.Groups[1].Value.Trim()
                if (-not [string]::IsNullOrWhiteSpace($clean) -and -not $names.Contains($clean)) {
                    $names.Add($clean)
                }
            }
        }
    }

    return ($names | Sort-Object)
}

function Update-FunctionSelectionUi {
    if ($null -eq $script:FunctionComboBox) {
        return
    }

    $hasSelection = ($null -ne $script:FunctionComboBox.SelectedItem)

    if ($null -ne $script:AddFunctionButton) {
        $script:AddFunctionButton.Visible = $hasSelection
    }

    if ($null -ne $script:SelectedFunctionLabel) {
        if ($null -ne $script:SelectedFunctionsListBox -and $script:SelectedFunctionsListBox.Items.Count -gt 0) {
            $items = @()
            foreach ($item in $script:SelectedFunctionsListBox.Items) {
                $items += [string]$item
            }
            $script:SelectedFunctionLabel.Text = "Selected functions: " + ($items -join ", ")
        } elseif ($hasSelection) {
            $script:SelectedFunctionLabel.Text = "Selected function: " + [string]$script:FunctionComboBox.SelectedItem
        } else {
            $script:SelectedFunctionLabel.Text = "Select a function from the dropdown, then click Add."
        }
    }
}

function Add-SelectedFunctionToList {
    if ($null -eq $script:FunctionComboBox -or $null -eq $script:FunctionComboBox.SelectedItem) {
        return
    }

    if ($null -eq $script:SelectedFunctionsListBox) {
        return
    }

    $functionName = [string]$script:FunctionComboBox.SelectedItem

    $alreadyAdded = $false
    foreach ($item in $script:SelectedFunctionsListBox.Items) {
        if ([string]$item -eq $functionName) {
            $alreadyAdded = $true
            break
        }
    }

    if (-not $alreadyAdded) {
        [void]$script:SelectedFunctionsListBox.Items.Add($functionName)
        Append-Log "Added selected function: $functionName"
    } else {
        Append-Log "Function already added: $functionName"
    }

    Update-FunctionSelectionUi
}

function Remove-SelectedFunctionFromList {
    if ($null -eq $script:SelectedFunctionsListBox -or $null -eq $script:SelectedFunctionsListBox.SelectedItem) {
        return
    }

    $functionName = [string]$script:SelectedFunctionsListBox.SelectedItem
    $script:SelectedFunctionsListBox.Items.Remove($script:SelectedFunctionsListBox.SelectedItem)
    Append-Log "Removed selected function: $functionName"
    Update-FunctionSelectionUi
}

function Clear-SelectedFunctionsList {
    if ($null -eq $script:SelectedFunctionsListBox) {
        return
    }

    $script:SelectedFunctionsListBox.Items.Clear()
    Append-Log "Cleared selected function list."
    Update-FunctionSelectionUi
}

function Refresh-FunctionList {
    if ($null -eq $script:FunctionComboBox) {
        return
    }

    $script:FunctionComboBox.Items.Clear()
    if ($null -ne $script:SelectedFunctionsListBox) {
        $script:SelectedFunctionsListBox.Items.Clear()
    }

    $names = Get-FirebaseFunctionNames

    foreach ($name in $names) {
        [void]$script:FunctionComboBox.Items.Add($name)
    }

    if ($script:FunctionComboBox.Items.Count -gt 0) {
        $script:FunctionComboBox.SelectedIndex = -1
    }

    Update-FunctionSelectionUi
    Append-Log "Function list refreshed. Count: $($script:FunctionComboBox.Items.Count)"
}

function Backup-MuthoBazar {
    if (-not (Test-RequiredPath -Path $RepoRoot -Label "MuthoBazar Repo")) {
        return
    }

    Ensure-Folder -Path $ProjectBackupRoot
    Ensure-Folder -Path $LogRoot

    $runnerFolder = Join-Path $LogRoot "backup_runners"
    Ensure-Folder -Path $runnerFolder

    $stamp = Get-TimeStamp
    $backupPath = Join-Path $ProjectBackupRoot "MuthoBazar_$stamp"
    $logFile = Join-Path $LogRoot "Backup_MuthoBazar_Project_$stamp.log"
    $runnerScriptPath = Join-Path $runnerFolder "backup_muthobazar_$stamp.ps1"

    $runnerScript = @"
`$ErrorActionPreference = 'Stop'
`$ProgressPreference = 'SilentlyContinue'
`$Host.UI.RawUI.WindowTitle = 'MuthoBazar Backup - starting'

`$RepoRoot = '$RepoRoot'
`$BackupPath = '$backupPath'
`$LogFile = '$logFile'
`$BackgroundRemoverPath = '$BackgroundRemoverPath'

`$ExcludedDirNames = @(
    '.git',
    '.dart_tool',
    '.idea',
    '.vscode',
    '.gradle',
    '.github',
    '.firebase',
    'build',
    '.symlinks',
    '.plugin_symlinks',
    'Pods',
    'DerivedData',
    'ephemeral',
    'node_modules'
)

`$ExcludedFullDirs = @(
    `$BackgroundRemoverPath
)

`$ExcludedFiles = @(
    '*.tmp',
    '*.log',
    '*.lock',
    'pubspec.lock',
    '*.iml',
    '.DS_Store',
    'Thumbs.db',
    '.flutter-plugins',
    '.flutter-plugins-dependencies',
    'generated_plugin_registrant.dart',
    'GeneratedPluginRegistrant.*',
    'flutter_export_environment.sh',
    'Flutter-Generated.xcconfig',
    'Generated.xcconfig'
)

function Write-Step {
    param([string]`$Message)
    `$time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    `$line = "[`$time] `$Message"
    Add-Content -LiteralPath `$LogFile -Value `$line
}

function Write-StatusLine {
    param(
        [int]`$Percent,
        [string]`$Status,
        [int]`$Current = 0,
        [int]`$Total = 0
    )

    if (`$Percent -lt 0) { `$Percent = 0 }
    if (`$Percent -gt 100) { `$Percent = 100 }

    `$left = 100 - `$Percent
    `$barWidth = 34
    `$done = [int][Math]::Floor((`$Percent / 100.0) * `$barWidth)
    if (`$done -lt 0) { `$done = 0 }
    if (`$done -gt `$barWidth) { `$done = `$barWidth }

    `$bar = '[' + ('#' * `$done) + ('-' * (`$barWidth - `$done)) + ']'
    `$line = "`$bar `$Percent% complete | `$left% left | `$Status"
    if (`$Total -gt 0) {
        `$line = "`$line | `$Current / `$Total"
    }

    `$Host.UI.RawUI.WindowTitle = "MuthoBazar Backup - `$Percent% complete, `$left% left"

    try {
        `$width = [Console]::WindowWidth
        if (`$width -gt 10) {
            `$max = `$width - 1
            if (`$line.Length -gt `$max) {
                `$line = `$line.Substring(0, `$max)
            }
            else {
                `$line = `$line.PadRight(`$max)
            }
        }
    }
    catch { }

    try {
        `$raw = `$Host.UI.RawUI
        `$old = `$raw.CursorPosition
        `$top = `$raw.WindowPosition.Y
        `$pos = New-Object System.Management.Automation.Host.Coordinates 0, `$top
        `$raw.CursorPosition = `$pos
        Write-Host `$line -NoNewline -ForegroundColor Green
        `$raw.CursorPosition = `$old
    }
    catch {
        Write-Host `$line -ForegroundColor Green
    }
}

function Initialize-BackupConsole {
    try { Clear-Host } catch { }
    Write-Host ''
    Write-Host 'MuthoBazar backup is running. Progress is fixed on the first console line.' -ForegroundColor Cyan
    Write-Host 'No per-file output is printed, so the progress line stays visible.' -ForegroundColor DarkGray
    Write-Host ''
    Write-StatusLine -Percent 0 -Status 'Starting backup'
}

function Test-ExcludedFile {
    param([string]`$Name)

    foreach (`$pattern in `$ExcludedFiles) {
        if (`$Name -like `$pattern) {
            return `$true
        }
    }

    return `$false
}

function Test-ExcludedPath {
    param([string]`$FullPath)

    `$normalizedPath = [System.IO.Path]::GetFullPath(`$FullPath).TrimEnd('\')
    `$normalizedRepo = [System.IO.Path]::GetFullPath(`$RepoRoot).TrimEnd('\')

    foreach (`$excludedFull in `$ExcludedFullDirs) {
        if ([string]::IsNullOrWhiteSpace(`$excludedFull)) { continue }
        `$normalizedExcluded = [System.IO.Path]::GetFullPath(`$excludedFull).TrimEnd('\')
        if (`$normalizedPath.StartsWith(`$normalizedExcluded, [System.StringComparison]::OrdinalIgnoreCase)) {
            return `$true
        }
    }

    `$relativePath = `$normalizedPath
    if (`$normalizedPath.StartsWith(`$normalizedRepo, [System.StringComparison]::OrdinalIgnoreCase)) {
        `$relativePath = `$normalizedPath.Substring(`$normalizedRepo.Length).TrimStart('\')
    }

    `$parts = `$relativePath -split '[\\/]+'
    foreach (`$part in `$parts) {
        if (`$ExcludedDirNames -contains `$part) {
            return `$true
        }
    }

    return `$false
}

function Add-BackupFilesFromDirectory {
    param(
        [string]`$Path,
        [System.Collections.Generic.List[System.IO.FileInfo]]`$Files
    )

    `$children = @(Get-ChildItem -LiteralPath `$Path -Force -ErrorAction SilentlyContinue)

    foreach (`$child in `$children) {
        if (`$child.PSIsContainer) {
            if (-not (Test-ExcludedPath -FullPath `$child.FullName)) {
                Add-BackupFilesFromDirectory -Path `$child.FullName -Files `$Files
            }
        }
        else {
            if (-not (Test-ExcludedFile -Name `$child.Name)) {
                [void]`$Files.Add(`$child)
            }
        }
    }
}

try {
    Initialize-BackupConsole

    Write-Step 'START: Backup MuthoBazar Project'
    Write-Step "Source: `$RepoRoot"
    Write-Step "Target: `$BackupPath"
    Write-Step "Log   : `$LogFile"
    Write-Step 'Mode  : Silent custom copy. Robocopy output disabled by design.'
    Write-Step 'Clean : Skipped. Generated/cache/build folders are excluded from backup.'
    Write-Step 'PubGet: Not required because flutter clean is skipped.'
    Write-Step 'Ignore: tools\background_remover_service is excluded from this project backup.'

    New-Item -ItemType Directory -Path `$BackupPath -Force | Out-Null

    Write-StatusLine -Percent 2 -Status 'Scanning source files'
    Write-Step 'Scanning files. Excluded folders are skipped during traversal.'

    `$files = New-Object System.Collections.Generic.List[System.IO.FileInfo]
    Add-BackupFilesFromDirectory -Path `$RepoRoot -Files `$files

    `$totalFiles = `$files.Count
    if (`$totalFiles -le 0) {
        throw 'No files found for backup after applying exclusions.'
    }

    Write-Step "Files to copy: `$totalFiles"
    Write-StatusLine -Percent 5 -Status 'Copying files' -Current 0 -Total `$totalFiles

    `$copiedFiles = 0
    `$lastPercent = -1

    foreach (`$file in `$files) {
        `$copiedFiles++
        `$relativePath = `$file.FullName.Substring(`$RepoRoot.Length).TrimStart('\')
        `$destinationFile = Join-Path `$BackupPath `$relativePath
        `$destinationDir = Split-Path -Path `$destinationFile -Parent

        if (-not (Test-Path -LiteralPath `$destinationDir)) {
            New-Item -ItemType Directory -Path `$destinationDir -Force | Out-Null
        }

        Copy-Item -LiteralPath `$file.FullName -Destination `$destinationFile -Force -ErrorAction Stop

        `$percent = [int](5 + ((`$copiedFiles / [double]`$totalFiles) * 90))
        if (`$percent -gt 95) { `$percent = 95 }

        if ((`$percent -ne `$lastPercent) -or (`$copiedFiles -eq `$totalFiles) -or (`$copiedFiles % 25 -eq 0)) {
            Write-StatusLine -Percent `$percent -Status 'Copying files' -Current `$copiedFiles -Total `$totalFiles
            `$lastPercent = `$percent
        }
    }

    Write-StatusLine -Percent 98 -Status 'Writing backup summary' -Current `$totalFiles -Total `$totalFiles

    `$summaryFile = Join-Path `$BackupPath 'backup_summary.txt'
    `$summary = @(
        'MuthoBazar Backup Summary',
        "CreatedAt : `$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))",
        "Source    : `$RepoRoot",
        "Target    : `$BackupPath",
        "Files     : `$totalFiles",
        'CopyMode  : Silent custom copy',
        'Clean     : Skipped',
        'Pub Get   : Not required because clean was skipped',
        'Excluded  : generated/cache/build folders and tools\background_remover_service'
    )
    Set-Content -LiteralPath `$summaryFile -Value `$summary -Encoding UTF8

    Write-StatusLine -Percent 100 -Status 'Backup completed' -Current `$totalFiles -Total `$totalFiles
    Write-Step "SUCCESS: Backup completed. Files copied: `$totalFiles"
    Write-Step "Backup target: `$BackupPath"
    Write-Step "Summary file : `$summaryFile"

    Write-Host ''
    Write-Host 'Backup completed successfully. This window will close automatically.' -ForegroundColor Green
    Start-Sleep -Milliseconds 1200
    exit 0
}
catch {
    Write-StatusLine -Percent 0 -Status 'Backup failed'
    Write-Step "FAILED: `$(`$_.Exception.Message)"
    Write-Step "FAILED TYPE: `$(`$_.Exception.GetType().FullName)"
    Write-Host ''
    Write-Host 'Backup failed. This PowerShell window will stay open for troubleshooting.' -ForegroundColor Yellow
    Write-Host "Log file: `$LogFile" -ForegroundColor Yellow
    [void](Read-Host 'Press Enter to close this failed terminal')
    exit 1
}
"@

    Set-Content -LiteralPath $runnerScriptPath -Value $runnerScript -Encoding UTF8

    Append-Log "START: Backup MuthoBazar Project launched in separate PowerShell."
    Append-Log "Runner: $runnerScriptPath"
    Append-Log "Source: $RepoRoot"
    Append-Log "Target: $backupPath"
    Append-Log "Log   : $logFile"
    Append-Log "Mode  : Silent custom copy, no Robocopy console output."
    Append-Log "Clean : Skipped because generated/cache folders are excluded."
    Append-Log "Ignore: tools\background_remover_service excluded."
    Append-Log "Progress: fixed first console line + window title. Success auto-closes; failure stays open."

    try {
        $process = Start-Process -FilePath "powershell.exe" `
            -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$runnerScriptPath`"" `
            -WorkingDirectory $RepoRoot `
            -PassThru

        if ($null -ne $process) {
            Append-Log "Started backup terminal. PID: $($process.Id)"
        }
    }
    catch {
        Append-Log "ERROR: Failed to start backup PowerShell: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to start backup PowerShell:`n$($_.Exception.Message)",
            "Backup Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}



function Start-BackgroundRemoverService {
    if (-not (Test-RequiredPath -Path $BackgroundRemoverPath -Label "Background Remover Service")) {
        return
    }

    $runScript = Join-Path $BackgroundRemoverPath "run_windows.ps1"
    if (-not (Test-Path $runScript)) {
        Append-Log "ERROR: run_windows.ps1 not found: $runScript"
        [System.Windows.Forms.MessageBox]::Show(
            "Background remover run script not found:`n$runScript",
            "Missing Script",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
        return
    }

    Start-TerminalCommand -Title "Start Background Remover Service" -WorkingDirectory $BackgroundRemoverPath -Commands @(
        ".\run_windows.ps1"
    )
}

function Git-Status {
    Invoke-LoggedCommand -Title "Git Status" -WorkingDirectory $RepoRoot -Commands @(
        "git status --short",
        "git branch --show-current",
        "git remote -v"
    )
}

function Sync-ToGitHub {
    if (-not (Confirm-Action -Title "Sync to GitHub" -Message "This will run git add, commit, and push from your local repo. Continue?")) {
        Append-Log "CANCELLED: Sync to GitHub"
        return
    }

    $message = $DefaultCommitMessage
    if ($null -ne $script:CommitMessageTextBox) {
        $message = $script:CommitMessageTextBox.Text.Trim()
    }

    if ([string]::IsNullOrWhiteSpace($message)) {
        $message = "sync latest local work $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    }

    Ensure-Folder -Path $LogRoot
    $runnerFolder = Join-Path $LogRoot "git_runners"
    Ensure-Folder -Path $runnerFolder

    $stamp = Get-TimeStamp
    $logFile = Join-Path $runnerFolder "sync_to_github_$stamp.log"
    $runnerScriptPath = Join-Path $runnerFolder "sync_to_github_$stamp.ps1"
    $safeMessage = $message.Replace("'", "''")

    $runnerScript = @"
`$ErrorActionPreference = 'Stop'
`$RepoRoot = '$RepoRoot'
`$LogFile = '$logFile'
`$CommitMessage = '$safeMessage'
`$Host.UI.RawUI.WindowTitle = 'MuthoBazar Git Sync'

function Write-Step {
    param([string]`$Message)
    `$time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    `$line = "[`$time] `$Message"
    Write-Host `$line
    Add-Content -LiteralPath `$LogFile -Value `$line
}

function Invoke-Git {
    param([string[]]`$Args)
    Write-Step ("git " + (`$Args -join ' '))
    & git @Args 2>&1 | Tee-Object -FilePath `$LogFile -Append
    if (`$LASTEXITCODE -ne 0) {
        throw "git command failed: git `$(`$Args -join ' ')"
    }
}

try {
    Set-Location -LiteralPath `$RepoRoot
    Write-Step 'START: Sync to GitHub'
    Write-Step "Repo: `$RepoRoot"
    Write-Step "Commit message: `$CommitMessage"

    & git status 2>&1 | Tee-Object -FilePath `$LogFile -Append
    if (`$LASTEXITCODE -ne 0) { throw 'git status failed.' }

    Invoke-Git @('add', '.')

    `$changes = (& git status --porcelain) -join [Environment]::NewLine
    Add-Content -LiteralPath `$LogFile -Value '--- git status --porcelain after git add ---'
    Add-Content -LiteralPath `$LogFile -Value `$changes

    if ([string]::IsNullOrWhiteSpace(`$changes)) {
        Write-Step 'NOTHING TO COMMIT: Working tree is clean.'
        Write-Host ''
        Write-Host 'Nothing to commit. This window will close automatically.' -ForegroundColor Green
        Start-Sleep -Milliseconds 1200
        exit 0
    }

    Invoke-Git @('commit', '-m', `$CommitMessage)
    Invoke-Git @('push', 'origin', 'main')

    Write-Step 'SUCCESS: Git sync completed.'
    Write-Host ''
    Write-Host 'Git sync completed successfully. This window will close automatically.' -ForegroundColor Green
    Start-Sleep -Milliseconds 1200
    exit 0
}
catch {
    Write-Step "FAILED: `$(`$_.Exception.Message)"
    Write-Host ''
    Write-Host 'Git sync failed. This PowerShell window will stay open for troubleshooting.' -ForegroundColor Yellow
    Write-Host "Log file: `$LogFile" -ForegroundColor Yellow
    [void](Read-Host 'Press Enter to close this failed terminal')
    exit 1
}
"@

    Set-Content -LiteralPath $runnerScriptPath -Value $runnerScript -Encoding UTF8

    Append-Log "START: Sync to GitHub launched in separate PowerShell."
    Append-Log "Runner: $runnerScriptPath"
    Append-Log "Log   : $logFile"
    Append-Log "Auto-close rule: success or nothing-to-commit closes automatically; failure stays open."

    try {
        $process = Start-Process -FilePath "powershell.exe" `
            -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$runnerScriptPath`"" `
            -WorkingDirectory $RepoRoot `
            -PassThru

        if ($null -ne $process) {
            Append-Log "Started Git sync terminal. PID: $($process.Id)"
        }
    }
    catch {
        Append-Log "ERROR: Failed to start Git sync PowerShell: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to start Git sync PowerShell:`n$($_.Exception.Message)",
            "Git Sync Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}




# -----------------------------
# Additional commands for 3-page UI
# -----------------------------
function Stop-TrackedTerminal {
    param([Parameter(Mandatory = $true)][string]$Title)

    if (-not $script:RunningTerminals.ContainsKey($Title)) {
        Append-Log "No tracked terminal is running for: $Title"
        return
    }

    $process = $script:RunningTerminals[$Title]
    if ($null -eq $process) {
        $script:RunningTerminals.Remove($Title)
        Append-Log "Tracked process was empty for: $Title"
        return
    }

    try {
        $live = Get-Process -Id $process.Id -ErrorAction SilentlyContinue
        if ($null -eq $live) {
            $script:RunningTerminals.Remove($Title)
            Append-Log "Tracked terminal already stopped for: $Title"
            return
        }

        Append-Log "Stopping terminal for '$Title'. PID: $($process.Id)"
        if ($live.MainWindowHandle -ne 0) {
            [void]$live.CloseMainWindow()
            Start-Sleep -Milliseconds 800
        }

        $live = Get-Process -Id $process.Id -ErrorAction SilentlyContinue
        if ($null -ne $live) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }

        $script:RunningTerminals.Remove($Title)
        Append-Log "Stopped: $Title"
    } catch {
        Append-Log "ERROR stopping '$Title': $($_.Exception.Message)"
    }
}

function Stop-CustomerApp {
    Stop-TrackedTerminal -Title "Run Customer App"
}

function Stop-AdminApp {
    Stop-TrackedTerminal -Title "Run Admin App"
    Stop-WebServer
}

function Stop-StaffApp {
    Stop-TrackedTerminal -Title "Run Staff App"
}

function Stop-WebServer {
    Append-Log "Stopping admin web server, dedicated Chrome window, and port $DefaultAdminWebPort."

    Stop-DedicatedAdminChrome
    Close-AdminWebServerConsole

    if ($script:RunningTerminals.ContainsKey("Open Web Server")) {
        Stop-TrackedTerminal -Title "Open Web Server"
    }

    if ($script:RunningTerminals.ContainsKey("Run Admin App")) {
        Stop-TrackedTerminal -Title "Run Admin App"
    }

    try {
        $connections = @(Get-NetTCPConnection -LocalPort $DefaultAdminWebPort -State Listen -ErrorAction SilentlyContinue)
        if ($connections.Count -eq 0) {
            Append-Log "No web server listener found on port $DefaultAdminWebPort."
        } else {
            $pids = $connections | Select-Object -ExpandProperty OwningProcess -Unique
            foreach ($processId in $pids) {
                if ($processId -gt 0) {
                    Append-Log "Stopping web server process on port $DefaultAdminWebPort. PID: $processId"
                    Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
                }
            }
        }
    } catch {
        Append-Log "ERROR stopping web server: $($_.Exception.Message)"
    }
}

function Reload-WebServer {
    $url = $DefaultAdminWebUrl
    Append-Log "Reload requested for admin web URL: $url"

    if (-not (Test-WebUrlReady -Url $url)) {
        Append-Log "Admin web URL is not responding. Use Open Web Server first: $url"
        [System.Windows.Forms.MessageBox]::Show(
            "Admin web server is not responding.`nUse Open Web Server first.`n`n$url",
            "Web Server Not Ready",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    Stop-DedicatedAdminChrome
    Start-Sleep -Milliseconds 700
    Open-DedicatedAdminChrome -Url $url
    Append-Log "Reload completed by reopening the dedicated Chrome window."
}

function Restart-WebServer {
    Append-Log "Restarting admin web server."
    Stop-WebServer
    Start-Sleep -Seconds 1
    Open-AdminWebServer
}

function Open-LogsFolder {
    Open-Folder -Path $LogRoot
}

function Convert-ToPowerShellSingleQuotedLiteral {
    param([AllowNull()][string]$Value)

    if ($null -eq $Value) {
        return "''"
    }

    return "'" + ($Value -replace "'", "''") + "'"
}

function Start-FolderBackupWithProgress {
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$BackupPath,
        [Parameter(Mandatory = $true)][string]$LogFile,
        [Parameter(Mandatory = $true)][string]$RunnerScriptPath,
        [string[]]$ExcludeFullDirs = @()
    )

    if (-not (Test-RequiredPath -Path $SourcePath -Label $Title)) {
        return
    }

    Ensure-Folder -Path (Split-Path -Path $BackupPath -Parent)
    Ensure-Folder -Path (Split-Path -Path $LogFile -Parent)
    Ensure-Folder -Path (Split-Path -Path $RunnerScriptPath -Parent)

    $excludedFullDirLiteral = ''
    if ($null -ne $ExcludeFullDirs -and $ExcludeFullDirs.Count -gt 0) {
        $excludedFullDirLiteral = ($ExcludeFullDirs | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object {
            '    ' + (Convert-ToPowerShellSingleQuotedLiteral $_)
        }) -join ",`r`n"
    }

    $runnerTemplate = @'
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$Title = __TITLE_LITERAL__
$SourcePath = __SOURCE_PATH_LITERAL__
$BackupPath = __BACKUP_PATH_LITERAL__
$LogFile = __LOG_FILE_LITERAL__
$ExcludedFullDirs = @(
__EXCLUDED_FULL_DIRS_LITERAL__
)

$Host.UI.RawUI.WindowTitle = "$Title - starting"

function Write-Step {
    param([string]$Message)
    $time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $line = "[$time] $Message"
    Add-Content -LiteralPath $LogFile -Value $line
}

function Write-StatusLine {
    param(
        [int]$Percent,
        [string]$Status,
        [int]$Current = 0,
        [int]$Total = 0
    )

    if ($Percent -lt 0) { $Percent = 0 }
    if ($Percent -gt 100) { $Percent = 100 }

    $left = 100 - $Percent
    $barWidth = 34
    $done = [int][Math]::Floor(($Percent / 100.0) * $barWidth)
    if ($done -lt 0) { $done = 0 }
    if ($done -gt $barWidth) { $done = $barWidth }

    $bar = '[' + ('#' * $done) + ('-' * ($barWidth - $done)) + ']'
    $line = "$bar $Percent% complete | $left% left | $Status"
    if ($Total -gt 0) {
        $line = "$line | $Current / $Total"
    }

    $Host.UI.RawUI.WindowTitle = "$Title - $Percent% complete, $left% left"

    try {
        $width = [Console]::WindowWidth
        if ($width -gt 10) {
            $max = $width - 1
            if ($line.Length -gt $max) {
                $line = $line.Substring(0, $max)
            }
            else {
                $line = $line.PadRight($max)
            }
        }
    }
    catch { }

    try {
        $raw = $Host.UI.RawUI
        $old = $raw.CursorPosition
        $top = $raw.WindowPosition.Y
        $pos = New-Object System.Management.Automation.Host.Coordinates 0, $top
        $raw.CursorPosition = $pos
        Write-Host $line -NoNewline -ForegroundColor Green
        $raw.CursorPosition = $old
    }
    catch {
        Write-Host $line -ForegroundColor Green
    }
}

function Initialize-BackupConsole {
    try { Clear-Host } catch { }
    Write-Host ''
    Write-Host "$Title is running. Progress is fixed on the first console line." -ForegroundColor Cyan
    Write-Host 'No per-file output is printed, so the progress line stays visible.' -ForegroundColor DarkGray
    Write-Host ''
    Write-StatusLine -Percent 0 -Status 'Starting backup'
}

function Test-ExcludedPath {
    param([string]$FullPath)

    if ($null -eq $ExcludedFullDirs -or $ExcludedFullDirs.Count -le 0) {
        return $false
    }

    $normalizedPath = [System.IO.Path]::GetFullPath($FullPath).TrimEnd('\')

    foreach ($excludedFull in $ExcludedFullDirs) {
        if ([string]::IsNullOrWhiteSpace($excludedFull)) { continue }
        $normalizedExcluded = [System.IO.Path]::GetFullPath($excludedFull).TrimEnd('\')
        if ($normalizedPath.Equals($normalizedExcluded, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
        if ($normalizedPath.StartsWith($normalizedExcluded + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

function Add-BackupFilesFromDirectory {
    param(
        [string]$Path,
        [System.Collections.Generic.List[System.IO.FileInfo]]$Files
    )

    $children = @(Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue)

    foreach ($child in $children) {
        if ($child.PSIsContainer) {
            if (-not (Test-ExcludedPath -FullPath $child.FullName)) {
                Add-BackupFilesFromDirectory -Path $child.FullName -Files $Files
            }
        }
        else {
            [void]$Files.Add($child)
        }
    }
}

try {
    Initialize-BackupConsole

    Write-Step "START: $Title"
    Write-Step "Source: $SourcePath"
    Write-Step "Target: $BackupPath"
    Write-Step "Log   : $LogFile"
    Write-Step 'Mode  : Silent custom copy. Robocopy output disabled by design.'

    if ($ExcludedFullDirs.Count -gt 0) {
        foreach ($excluded in $ExcludedFullDirs) {
            Write-Step "Ignore: $excluded"
        }
    }

    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null

    Write-StatusLine -Percent 2 -Status 'Scanning source files'
    Write-Step 'Scanning files. Excluded folders are skipped during traversal.'

    $files = New-Object System.Collections.Generic.List[System.IO.FileInfo]
    Add-BackupFilesFromDirectory -Path $SourcePath -Files $files

    $totalFiles = $files.Count
    if ($totalFiles -le 0) {
        throw 'No files found for backup after applying exclusions.'
    }

    Write-Step "Files to copy: $totalFiles"
    Write-StatusLine -Percent 5 -Status 'Copying files' -Current 0 -Total $totalFiles

    $copiedFiles = 0
    $lastPercent = -1
    $normalizedSource = [System.IO.Path]::GetFullPath($SourcePath).TrimEnd('\')

    foreach ($file in $files) {
        $copiedFiles++
        $relativePath = $file.FullName.Substring($normalizedSource.Length).TrimStart('\')
        $destinationFile = Join-Path $BackupPath $relativePath
        $destinationDir = Split-Path -Path $destinationFile -Parent

        if (-not (Test-Path -LiteralPath $destinationDir)) {
            New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
        }

        Copy-Item -LiteralPath $file.FullName -Destination $destinationFile -Force -ErrorAction Stop

        $percent = [int](5 + (($copiedFiles / [double]$totalFiles) * 90))
        if ($percent -gt 95) { $percent = 95 }

        if (($percent -ne $lastPercent) -or ($copiedFiles -eq $totalFiles) -or ($copiedFiles % 25 -eq 0)) {
            Write-StatusLine -Percent $percent -Status 'Copying files' -Current $copiedFiles -Total $totalFiles
            $lastPercent = $percent
        }
    }

    Write-StatusLine -Percent 98 -Status 'Writing backup summary' -Current $totalFiles -Total $totalFiles

    $summaryFile = Join-Path $BackupPath 'backup_summary.txt'
    $summary = @(
        "$Title Summary",
        "CreatedAt : $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))",
        "Source    : $SourcePath",
        "Target    : $BackupPath",
        "Files     : $totalFiles",
        'CopyMode  : Silent custom copy',
        'Console   : Fixed progress line, no Robocopy output'
    )

    if ($ExcludedFullDirs.Count -gt 0) {
        $summary += 'Excluded full directories:'
        foreach ($excluded in $ExcludedFullDirs) {
            $summary += "- $excluded"
        }
    }

    Set-Content -LiteralPath $summaryFile -Value $summary -Encoding UTF8

    Write-StatusLine -Percent 100 -Status 'Backup completed' -Current $totalFiles -Total $totalFiles
    Write-Step "SUCCESS: $Title completed. Files copied: $totalFiles"
    Write-Step "Backup target: $BackupPath"
    Write-Step "Summary file : $summaryFile"

    Write-Host ''
    Write-Host "$Title completed successfully. This window will close automatically." -ForegroundColor Green
    Start-Sleep -Milliseconds 1200
    exit 0
}
catch {
    Write-StatusLine -Percent 0 -Status 'Backup failed'
    Write-Step "FAILED: $($_.Exception.Message)"
    Write-Step "FAILED TYPE: $($_.Exception.GetType().FullName)"
    Write-Host ''
    Write-Host "$Title failed. This PowerShell window will stay open for troubleshooting." -ForegroundColor Yellow
    Write-Host "Log file: $LogFile" -ForegroundColor Yellow
    [void](Read-Host 'Press Enter to close this failed terminal')
    exit 1
}
'@

    $runnerScript = $runnerTemplate.Replace('__TITLE_LITERAL__', (Convert-ToPowerShellSingleQuotedLiteral $Title))
    $runnerScript = $runnerScript.Replace('__SOURCE_PATH_LITERAL__', (Convert-ToPowerShellSingleQuotedLiteral $SourcePath))
    $runnerScript = $runnerScript.Replace('__BACKUP_PATH_LITERAL__', (Convert-ToPowerShellSingleQuotedLiteral $BackupPath))
    $runnerScript = $runnerScript.Replace('__LOG_FILE_LITERAL__', (Convert-ToPowerShellSingleQuotedLiteral $LogFile))
    $runnerScript = $runnerScript.Replace('__EXCLUDED_FULL_DIRS_LITERAL__', $excludedFullDirLiteral)

    Set-Content -LiteralPath $RunnerScriptPath -Value $runnerScript -Encoding UTF8

    Append-Log "START: $Title launched in separate PowerShell."
    Append-Log "Runner: $RunnerScriptPath"
    Append-Log "Source: $SourcePath"
    Append-Log "Target: $BackupPath"
    Append-Log "Log   : $LogFile"
    Append-Log "Mode  : Silent custom copy, fixed progress line, no Robocopy console output."

    if ($null -ne $ExcludeFullDirs -and $ExcludeFullDirs.Count -gt 0) {
        foreach ($excluded in $ExcludeFullDirs) {
            Append-Log "Ignore: $excluded"
        }
    }

    Append-Log "Success auto-closes; failure stays open."

    try {
        $process = Start-Process -FilePath "powershell.exe" `
            -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$RunnerScriptPath`"" `
            -WorkingDirectory $SourcePath `
            -PassThru

        if ($null -ne $process) {
            Append-Log "Started backup terminal. PID: $($process.Id)"
        }
    }
    catch {
        Append-Log "ERROR: Failed to start backup PowerShell: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to start backup PowerShell:`n$($_.Exception.Message)",
            "$Title Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}

function Backup-ToolsFullFolder {
    if (-not (Test-RequiredPath -Path $ToolsRoot -Label "Tools Folder")) {
        return
    }

    Ensure-Folder -Path $BackupRoot
    Ensure-Folder -Path $LogRoot

    $runnerFolder = Join-Path $LogRoot "backup_runners"
    Ensure-Folder -Path $runnerFolder

    $stamp = Get-TimeStamp
    $backupPath = Join-Path $BackupRoot "Tools_Full_$stamp"
    $logFile = Join-Path $LogRoot "Backup_Tools_Full_$stamp.log"
    $runnerScriptPath = Join-Path $runnerFolder "backup_tools_full_$stamp.ps1"

    Start-FolderBackupWithProgress `
        -Title "Backup Full Tools Folder" `
        -SourcePath $ToolsRoot `
        -BackupPath $backupPath `
        -LogFile $logFile `
        -RunnerScriptPath $runnerScriptPath
}

function Backup-ToolsExcludeBackgroundService {
    if (-not (Test-RequiredPath -Path $ToolsRoot -Label "Tools Folder")) {
        return
    }

    Ensure-Folder -Path $BackupRoot
    Ensure-Folder -Path $LogRoot

    $runnerFolder = Join-Path $LogRoot "backup_runners"
    Ensure-Folder -Path $runnerFolder

    $stamp = Get-TimeStamp
    $backupPath = Join-Path $BackupRoot "Tools_NoBgService_$stamp"
    $logFile = Join-Path $LogRoot "Backup_Tools_NoBgService_$stamp.log"
    $runnerScriptPath = Join-Path $runnerFolder "backup_tools_no_bg_service_$stamp.ps1"

    Start-FolderBackupWithProgress `
        -Title "Backup Tools Exclude Background Service Folder" `
        -SourcePath $ToolsRoot `
        -BackupPath $backupPath `
        -LogFile $logFile `
        -RunnerScriptPath $runnerScriptPath `
        -ExcludeFullDirs @($BackgroundRemoverPath)
}


function Test-TreeExcludedDirectory {
    param([Parameter(Mandatory = $true)][System.IO.DirectoryInfo]$Item)

    $excludedDirs = @(
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

    return ($excludedDirs -contains $Item.Name)
}

function Test-TreeExcludedFile {
    param([Parameter(Mandatory = $true)][System.IO.FileInfo]$Item)

    $excludedFiles = @(
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

    foreach ($pattern in $excludedFiles) {
        if ($Item.Name -like $pattern) {
            return $true
        }
    }

    return $false
}

function Get-TreeVisibleChildren {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [bool]$FoldersOnly = $false
    )

    $children = @(Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue)

    $visible = foreach ($child in $children) {
        if ($child.PSIsContainer) {
            if (-not (Test-TreeExcludedDirectory -Item $child)) {
                $child
            }
        } else {
            if (-not $FoldersOnly -and -not (Test-TreeExcludedFile -Item $child)) {
                $child
            }
        }
    }

    return ($visible | Sort-Object @{ Expression = { -not $_.PSIsContainer } }, Name)
}

function Write-CleanTree {
    param(
        [Parameter(Mandatory = $true)][string]$CurrentPath,
        [Parameter(Mandatory = $true)][string]$OutputFile,
        [string]$Prefix = "",
        [bool]$FoldersOnly = $false
    )

    $items = @(Get-TreeVisibleChildren -Path $CurrentPath -FoldersOnly $FoldersOnly)

    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $isLast = ($i -eq $items.Count - 1)
        $connector = if ($isLast) { "\---" } else { "+---" }

        Add-Content -LiteralPath $OutputFile -Value ("{0}{1}{2}" -f $Prefix, $connector, $item.Name) -Encoding UTF8

        if ($item.PSIsContainer) {
            $childPrefix = if ($isLast) { "$Prefix    " } else { "$Prefix|   " }
            Write-CleanTree -CurrentPath $item.FullName -OutputFile $OutputFile -Prefix $childPrefix -FoldersOnly $FoldersOnly
        }
    }
}

function New-CleanStructureFile {
    param(
        [Parameter(Mandatory = $true)][string]$RootPath,
        [Parameter(Mandatory = $true)][string]$OutputFile,
        [switch]$FoldersOnly
    )

    if (-not (Test-Path -LiteralPath $RootPath)) {
        Append-Log "WARNING: Structure root path not found: $RootPath"
        return $false
    }

    $resolvedRoot = (Resolve-Path -LiteralPath $RootPath).Path
    $rootItem = Get-Item -LiteralPath $resolvedRoot

    if (Test-Path -LiteralPath $OutputFile) {
        Remove-Item -LiteralPath $OutputFile -Force -ErrorAction SilentlyContinue
    }

    Set-Content -LiteralPath $OutputFile -Value "Folder PATH listing" -Encoding UTF8
    Add-Content -LiteralPath $OutputFile -Value ("Path: {0}" -f $rootItem.FullName) -Encoding UTF8
    Add-Content -LiteralPath $OutputFile -Value ("{0}." -f $rootItem.FullName.Substring(0,1)) -Encoding UTF8
    Write-CleanTree -CurrentPath $rootItem.FullName -OutputFile $OutputFile -FoldersOnly ([bool]$FoldersOnly)

    Append-Log "Generated structure: $OutputFile"
    return $true
}

function Generate-ProjectStructures {
    if (-not (Test-RequiredPath -Path $RepoRoot -Label "MuthoBazar Repo")) {
        return
    }

    $treeScript = Join-Path $RepoRoot "tools\scripts\generate_clean_tree.ps1"
    if (-not (Test-Path -LiteralPath $treeScript)) {
        Append-Log "ERROR: Structure generator script not found: $treeScript"
        [System.Windows.Forms.MessageBox]::Show(
            "Structure generator script not found:`n$treeScript",
            "Generate Structure Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
        return
    }

    if ($null -ne $script:StructureProcess -and -not $script:StructureProcess.HasExited) {
        Append-Log "Generate Structure is already running. Please wait until it finishes."
        [System.Windows.Forms.MessageBox]::Show(
            "Structure generation is already running. Please wait until it finishes.",
            "Generate Structure Running",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
        return
    }

    $stamp = Get-TimeStamp
    $structureRoot = Join-Path $LocalFilesRoot "Structures"
    $outputFolder = Join-Path $structureRoot "structure_$stamp"
    Ensure-Folder -Path $outputFolder
    Ensure-Folder -Path $LogRoot

    $runnerRoot = Join-Path $LogRoot "structure_runners"
    Ensure-Folder -Path $runnerRoot

    $runnerScriptPath = Join-Path $runnerRoot "generate_structure_$stamp.ps1"
    $runnerLogFile = Join-Path $runnerRoot "generate_structure_$stamp.log"

    $repoEsc = $RepoRoot -replace "'", "''"
    $outputEsc = $outputFolder -replace "'", "''"
    $logEsc = $runnerLogFile -replace "'", "''"
    $treeEsc = $treeScript -replace "'", "''"

    $runnerScript = @"
`$ErrorActionPreference = 'Stop'
`$RepoRoot = '$repoEsc'
`$OutputFolder = '$outputEsc'
`$LogFile = '$logEsc'
`$TreeScript = '$treeEsc'

function Write-Step {
    param([AllowEmptyString()][AllowNull()][string]`$Message)

    if (`$null -eq `$Message) {
        `$Message = ''
    }

    `$time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    `$line = "[`$time] `$Message"
    Write-Host `$line
    Add-Content -LiteralPath `$LogFile -Value `$line -Encoding UTF8
}

function Invoke-TreeGenerator {
    param(
        [AllowEmptyString()][AllowNull()][string]`$RootPath,
        [Parameter(Mandatory = `$true)][string]`$OutputFile
    )

    if ([string]::IsNullOrWhiteSpace(`$OutputFile)) {
        throw 'Output file cannot be empty.'
    }

    Set-Location -LiteralPath `$RepoRoot
    `$sourceFile = Join-Path `$RepoRoot `$OutputFile
    `$destFile = Join-Path `$OutputFolder `$OutputFile

    if (Test-Path -LiteralPath `$sourceFile) {
        Remove-Item -LiteralPath `$sourceFile -Force -ErrorAction SilentlyContinue
    }

    Write-Step "Generating: `$OutputFile"

    `$commandOutput = @()
    if ([string]::IsNullOrWhiteSpace(`$RootPath)) {
        `$commandOutput = & `$TreeScript -OutputFile `$OutputFile 2>&1
    }
    else {
        `$commandOutput = & `$TreeScript -RootPath `$RootPath -OutputFile `$OutputFile 2>&1
    }

    foreach (`$line in `$commandOutput) {
        `$text = [string]`$line
        if (-not [string]::IsNullOrWhiteSpace(`$text)) {
            Write-Step "  `$text"
        }
    }

    if (-not (Test-Path -LiteralPath `$sourceFile)) {
        throw "Missing generated file after running generator: `$sourceFile"
    }

    Copy-Item -LiteralPath `$sourceFile -Destination `$destFile -Force
    Write-Step "Copied: `$OutputFile"
}

try {
    New-Item -ItemType Directory -Path `$OutputFolder -Force | Out-Null
    Write-Step 'START: MuthoBazar structure generation.'
    Write-Step "Repo output: `$RepoRoot"
    Write-Step "Copy output: `$OutputFolder"
    Write-Step "Generator : `$TreeScript"

    Invoke-TreeGenerator -RootPath '' -OutputFile 'repo_structure_clean.txt'
    Invoke-TreeGenerator -RootPath '.\apps\customer_app\lib' -OutputFile 'customer_lib_structure_clean.txt'
    Invoke-TreeGenerator -RootPath '.\apps\admin_web\lib' -OutputFile 'adminWeb_lib_structure_clean.txt'
    Invoke-TreeGenerator -RootPath '.\apps\staff_app\lib' -OutputFile 'staff_app_lib_structure_clean.txt'
    Invoke-TreeGenerator -RootPath '.\packages' -OutputFile 'packages_structure_clean.txt'
    Invoke-TreeGenerator -RootPath '.\firebase' -OutputFile 'firebase_structure_clean.txt'
    Invoke-TreeGenerator -RootPath '.\tools' -OutputFile 'tools_structure_clean.txt'

    Write-Step 'END: Structure generation completed successfully.'
    & explorer.exe `$OutputFolder
    exit 0
}
catch {
    Write-Step "FAILED: `$(`$_.Exception.Message)"
    Write-Step "FAILED TYPE: `$(`$_.Exception.GetType().FullName)"
    exit 1
}
"@

    Set-Content -LiteralPath $runnerScriptPath -Value $runnerScript -Encoding UTF8

    Append-Log "START: Generate Structure launched in separate PowerShell."
    Append-Log "Runner: $runnerScriptPath"
    Append-Log "Log   : $runnerLogFile"
    Append-Log "Output: $outputFolder"
    Append-Log "The separate PowerShell window will close automatically after execution completes."

    try {
        $process = Start-Process -FilePath "powershell.exe" `
            -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $runnerScriptPath) `
            -WorkingDirectory $RepoRoot `
            -PassThru

        $script:StructureProcess = $process
        $script:StructureOutputFolder = $outputFolder
        $script:StructureLogFile = $runnerLogFile

        if ($null -ne $script:StructureTimer) {
            $script:StructureTimer.Stop()
            $script:StructureTimer.Dispose()
            $script:StructureTimer = $null
        }

        $script:StructureTimer = New-Object System.Windows.Forms.Timer
        $script:StructureTimer.Interval = 1000
        $script:StructureTimer.Add_Tick({
            if ($null -ne $script:StructureProcess -and $script:StructureProcess.HasExited) {
                $exitCode = $script:StructureProcess.ExitCode
                Append-Log "END: Generate Structure background process. ExitCode: $exitCode"
                Append-Log "Output: $($script:StructureOutputFolder)"
                Append-Log "Log   : $($script:StructureLogFile)"

                if ($exitCode -ne 0) {
                    Append-Log "Generate Structure failed. Open the log file above for the exact generator error."
                }

                $script:StructureTimer.Stop()
                $script:StructureTimer.Dispose()
                $script:StructureTimer = $null
                $script:StructureProcess = $null
            }
        })
        $script:StructureTimer.Start()
    }
    catch {
        Append-Log "ERROR: Failed to start Generate Structure PowerShell: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to start Generate Structure PowerShell:`n$($_.Exception.Message)",
            "Generate Structure Failed",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}


function Execute-CustomPowerShell {
    if ($null -eq $script:PsEditorBox) {
        Append-Log "ERROR: PS editor was not initialized."
        return
    }

    $code = $script:PsEditorBox.Text
    if ([string]::IsNullOrWhiteSpace($code)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Please write or paste PowerShell code first.",
            "Empty PowerShell Code",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
        return
    }

    if (-not (Confirm-Action -Title "Execute PowerShell" -Message "Execute the PowerShell code from the editor?")) {
        Append-Log "CANCELLED: PS Execute"
        return
    }

    $lines = $code -split "`r?`n"
    Invoke-LoggedCommand -Title "Custom PS Execute" -WorkingDirectory $RepoRoot -Commands $lines
}

# -----------------------------
# 3-page UI rendering helpers
# -----------------------------
function New-UiButton {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][int]$X,
        [Parameter(Mandatory = $true)][int]$Y,
        [Parameter(Mandatory = $true)][scriptblock]$OnClick,
        [int]$Width = 190,
        [int]$Height = 36,
        [System.Drawing.Color]$BackColor = $ColorBlue
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Size = New-Object System.Drawing.Size($Width, $Height)
    $button.Location = New-Object System.Drawing.Point($X, $Y)
    $button.Font = $FontButton
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.FlatAppearance.BorderSize = 0
    $button.ForeColor = [System.Drawing.Color]::White
    $button.BackColor = $BackColor
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $button.Add_Click($OnClick)

    Add-ContentControl -Control $button
    $button.BringToFront()
    return $button
}

function New-GoldBadge {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][int]$X,
        [Parameter(Mandatory = $true)][int]$Y,
        [int]$Width = 150,
        [int]$Height = 34
    )

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point($X, $Y)
    $panel.Size = New-Object System.Drawing.Size($Width, $Height)
    $panel.Tag = $Text
    $panel.BackColor = [System.Drawing.Color]::Goldenrod
    $panel.Add_Paint({
        param($sender, $eventArgs)
        $rect = $sender.ClientRectangle
        $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromArgb(199, 126, 0), [System.Drawing.Color]::FromArgb(255, 191, 32), [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
        $eventArgs.Graphics.FillRectangle($brush, $rect)
        $brush.Dispose()
        $flags = [System.Windows.Forms.TextFormatFlags]::HorizontalCenter -bor [System.Windows.Forms.TextFormatFlags]::VerticalCenter -bor [System.Windows.Forms.TextFormatFlags]::EndEllipsis
        [System.Windows.Forms.TextRenderer]::DrawText($eventArgs.Graphics, [string]$sender.Tag, $FontButton, $rect, $ColorBlueText, $flags)
    })

    Add-ContentControl -Control $panel
    return $panel
}

function New-LightPanel {
    param(
        [Parameter(Mandatory = $true)][int]$X,
        [Parameter(Mandatory = $true)][int]$Y,
        [Parameter(Mandatory = $true)][int]$Width,
        [Parameter(Mandatory = $true)][int]$Height
    )

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point($X, $Y)
    $panel.Size = New-Object System.Drawing.Size($Width, $Height)
    $panel.BackColor = $ColorCanvas
    Add-ContentControl -Control $panel
    $panel.SendToBack()
    return $panel
}

function Render-MainTabSelection {
    foreach ($key in $script:MainTabButtons.Keys) {
        $button = $script:MainTabButtons[$key]
        if ($key -eq $script:ActiveMainTab) {
            $button.BackColor = $ColorHeader
            $button.ForeColor = [System.Drawing.Color]::White
            $button.FlatAppearance.BorderSize = 2
            $button.FlatAppearance.BorderColor = $ColorHeaderDark
        } else {
            $button.BackColor = $ColorBg
            $button.ForeColor = $ColorBlueText
            $button.FlatAppearance.BorderSize = 0
        }
    }
}

function Set-MainTab {
    param([Parameter(Mandatory = $true)][string]$TabName)

    $script:ActiveMainTab = $TabName
    Render-MainTabSelection
    Clear-ContentPanel

    switch ($TabName) {
        "Apps" { Render-AppsPage }
        "Tools" { Render-ToolsPage }
        "PS Execute" { Render-PsExecutePage }
    }
}

function Render-AppsPage {
    $labelX = 45
    $buttonX = 290
    $rowY = @(42, 95, 148, 201)
    $buttonW = 210
    $buttonH = 36
    $gap = 25

    New-GoldBadge -Text "Customer App" -X $labelX -Y $rowY[0] -Width 155 -Height 34 | Out-Null
    New-GoldBadge -Text "Admin App" -X ($labelX + 28) -Y $rowY[1] -Width 127 -Height 34 | Out-Null
    New-GoldBadge -Text "Web Server" -X ($labelX + 28) -Y $rowY[2] -Width 127 -Height 34 | Out-Null
    New-GoldBadge -Text "Staff App" -X ($labelX + 28) -Y $rowY[3] -Width 127 -Height 34 | Out-Null

    New-UiButton -Text "Run Customer App" -X $buttonX -Y $rowY[0] -Width $buttonW -Height $buttonH -OnClick { Run-CustomerApp } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Stop Customer App" -X ($buttonX + ($buttonW + $gap)) -Y $rowY[0] -Width $buttonW -Height $buttonH -OnClick { Stop-CustomerApp } -BackColor $ColorBlue | Out-Null
    New-UiButton -Text "Pub Get Customer App" -X ($buttonX + 2 * ($buttonW + $gap)) -Y $rowY[0] -Width $buttonW -Height $buttonH -OnClick { PubGet-CustomerApp } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Clean Customer App" -X ($buttonX + 3 * ($buttonW + $gap)) -Y $rowY[0] -Width $buttonW -Height $buttonH -OnClick { Clean-CustomerApp } -BackColor $ColorRed | Out-Null

    New-UiButton -Text "Run Admin App" -X $buttonX -Y $rowY[1] -Width $buttonW -Height $buttonH -OnClick { Run-AdminWeb } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Stop Admin App" -X ($buttonX + ($buttonW + $gap)) -Y $rowY[1] -Width $buttonW -Height $buttonH -OnClick { Stop-AdminApp } -BackColor $ColorBlue | Out-Null
    New-UiButton -Text "Pub Get Admin App" -X ($buttonX + 2 * ($buttonW + $gap)) -Y $rowY[1] -Width $buttonW -Height $buttonH -OnClick { PubGet-AdminWeb } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Clean Admin App" -X ($buttonX + 3 * ($buttonW + $gap)) -Y $rowY[1] -Width $buttonW -Height $buttonH -OnClick { Clean-AdminWeb } -BackColor $ColorRed | Out-Null

    New-UiButton -Text "Open Web Server" -X $buttonX -Y $rowY[2] -Width $buttonW -Height $buttonH -OnClick { Open-AdminWebServer } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Stop Web Server" -X ($buttonX + ($buttonW + $gap)) -Y $rowY[2] -Width $buttonW -Height $buttonH -OnClick { Stop-WebServer } -BackColor $ColorBlue | Out-Null
    New-UiButton -Text "Reload Web Server" -X ($buttonX + 2 * ($buttonW + $gap)) -Y $rowY[2] -Width $buttonW -Height $buttonH -OnClick { Reload-WebServer } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Restart Web Server" -X ($buttonX + 3 * ($buttonW + $gap)) -Y $rowY[2] -Width $buttonW -Height $buttonH -OnClick { Restart-WebServer } -BackColor $ColorRed | Out-Null

    New-UiButton -Text "Run Staff App" -X $buttonX -Y $rowY[3] -Width $buttonW -Height $buttonH -OnClick { Run-StaffApp } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Stop Staff App" -X ($buttonX + ($buttonW + $gap)) -Y $rowY[3] -Width $buttonW -Height $buttonH -OnClick { Stop-StaffApp } -BackColor $ColorBlue | Out-Null
    New-UiButton -Text "Pub Get Staff App" -X ($buttonX + 2 * ($buttonW + $gap)) -Y $rowY[3] -Width $buttonW -Height $buttonH -OnClick { PubGet-StaffApp } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Clean Staff App" -X ($buttonX + 3 * ($buttonW + $gap)) -Y $rowY[3] -Width $buttonW -Height $buttonH -OnClick { Clean-StaffApp } -BackColor $ColorRed | Out-Null

    $script:SkipAdminWebCleanCheckBox = New-Object System.Windows.Forms.CheckBox
    $script:SkipAdminWebCleanCheckBox.Text = "Skip Clean for Open Web Server"
    $script:SkipAdminWebCleanCheckBox.Location = New-Object System.Drawing.Point($buttonX, 255)
    $script:SkipAdminWebCleanCheckBox.Size = New-Object System.Drawing.Size(300, 28)
    $script:SkipAdminWebCleanCheckBox.Font = $FontNormal
    $script:SkipAdminWebCleanCheckBox.ForeColor = $ColorText
    $script:SkipAdminWebCleanCheckBox.BackColor = $ColorBg
    $script:SkipAdminWebCleanCheckBox.Checked = $script:SkipAdminWebClean
    $script:SkipAdminWebCleanCheckBox.Add_CheckedChanged({
        param($sender, $eventArgs)
        $script:SkipAdminWebClean = [bool]$sender.Checked
        if ($script:SkipAdminWebClean) {
            Append-Log "Skip Clean enabled for Open Web Server."
        } else {
            Append-Log "Skip Clean disabled for Open Web Server."
        }
    })
    Add-ContentControl -Control $script:SkipAdminWebCleanCheckBox
}

function Render-ToolsPage {
    New-GoldBadge -Text "Git Tools" -X 55 -Y 35 -Width 120 -Height 31 | Out-Null
    New-GoldBadge -Text "Project Tools" -X 40 -Y 90 -Width 150 -Height 31 | Out-Null
    New-GoldBadge -Text "Script Tools" -X 48 -Y 145 -Width 135 -Height 31 | Out-Null
    New-GoldBadge -Text "Firebase Tools" -X 25 -Y 200 -Width 175 -Height 31 | Out-Null

    New-LightPanel -X 220 -Y 18 -Width 680 -Height 56 | Out-Null
    New-InfoLabel -Text "Git commit message:" -X 235 -Y 32 -Width 130 -Height 25 -Font $FontNormal -BackColor $ColorCanvas -ForeColor $ColorText | Out-Null

    $script:CommitMessageTextBox = New-Object System.Windows.Forms.TextBox
    $script:CommitMessageTextBox.Location = New-Object System.Drawing.Point(365, 31)
    $script:CommitMessageTextBox.Size = New-Object System.Drawing.Size(380, 26)
    $script:CommitMessageTextBox.Font = $FontNormal
    $script:CommitMessageTextBox.Text = $DefaultCommitMessage
    Add-ContentControl -Control $script:CommitMessageTextBox
    $script:CommitMessageTextBox.BringToFront()

    New-UiButton -Text "Sync to GitHub" -X 760 -Y 26 -Width 145 -Height 38 -OnClick { Sync-ToGitHub } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Git Status" -X 925 -Y 26 -Width 145 -Height 38 -OnClick { Git-Status } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Open Repo" -X 1090 -Y 26 -Width 145 -Height 38 -OnClick { Open-Folder -Path $RepoRoot } -BackColor $ColorRed | Out-Null

    New-UiButton -Text "Open Project Folder" -X 300 -Y 82 -Width 210 -Height 38 -OnClick { Open-Folder -Path $RepoRoot } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Open Backup Folder" -X 530 -Y 82 -Width 210 -Height 38 -OnClick { Open-Folder -Path $ProjectBackupRoot } -BackColor $ColorBlue | Out-Null
    New-UiButton -Text "Backup MuthoBazar" -X 760 -Y 82 -Width 210 -Height 38 -OnClick { Backup-MuthoBazar } -BackColor $ColorBlue | Out-Null
    New-UiButton -Text "Open Logs" -X 990 -Y 82 -Width 210 -Height 38 -OnClick { Open-LogsFolder } -BackColor $ColorBlue | Out-Null

    New-UiButton -Text "Backup Full Tools`nFolder" -X 300 -Y 135 -Width 210 -Height 38 -OnClick { Backup-ToolsFullFolder } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Backup Tools Exclude`nBackground Service Folder" -X 530 -Y 135 -Width 300 -Height 38 -OnClick { Backup-ToolsExcludeBackgroundService } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Generate`nStructure" -X 850 -Y 135 -Width 145 -Height 38 -OnClick { Generate-ProjectStructures } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Start Background`nRemover Service" -X 1015 -Y 135 -Width 210 -Height 38 -OnClick { Start-BackgroundRemoverService } -BackColor $ColorBlue | Out-Null

    New-UiButton -Text "Build Firebase`nFunctions" -X 300 -Y 188 -Width 210 -Height 38 -OnClick { Build-FirebaseFunctions } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Deploy All Functions" -X 530 -Y 188 -Width 210 -Height 38 -OnClick { Deploy-AllFunctions } -BackColor $ColorBlue | Out-Null
    New-UiButton -Text "Deploy Storage Rule" -X 760 -Y 188 -Width 210 -Height 38 -OnClick { Deploy-StorageRule } -BackColor $ColorGreen | Out-Null
    New-UiButton -Text "Deploy Firestore Rule" -X 990 -Y 188 -Width 210 -Height 38 -OnClick { Deploy-FirestoreRule } -BackColor $ColorGreen | Out-Null

    New-UiButton -Text "Deploy Selected`nFunctions" -X 25 -Y 250 -Width 220 -Height 44 -OnClick { Deploy-SelectedFunction } -BackColor $ColorBlue | Out-Null

    $script:FunctionComboBox = New-Object System.Windows.Forms.ComboBox
    $script:FunctionComboBox.Location = New-Object System.Drawing.Point(300, 244)
    $script:FunctionComboBox.Size = New-Object System.Drawing.Size(650, 31)
    $script:FunctionComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $script:FunctionComboBox.Font = $FontNormal
    $script:FunctionComboBox.Add_SelectedIndexChanged({ Update-FunctionSelectionUi })
    Add-ContentControl -Control $script:FunctionComboBox

    $script:AddFunctionButton = New-UiButton -Text "Add" -X 970 -Y 243 -Width 110 -Height 38 -OnClick { Add-SelectedFunctionToList } -BackColor $ColorGreen
    $script:AddFunctionButton.Visible = $false

    New-UiButton -Text "Refresh List" -X 1095 -Y 243 -Width 160 -Height 38 -OnClick { Refresh-FunctionList } -BackColor $ColorSlate | Out-Null

    $script:SelectedFunctionsListBox = New-Object System.Windows.Forms.ListBox
    $script:SelectedFunctionsListBox.Location = New-Object System.Drawing.Point(300, 290)
    $script:SelectedFunctionsListBox.Size = New-Object System.Drawing.Size(650, 56)
    $script:SelectedFunctionsListBox.Font = $FontNormal
    Add-ContentControl -Control $script:SelectedFunctionsListBox

    New-UiButton -Text "Remove" -X 970 -Y 288 -Width 110 -Height 44 -OnClick { Remove-SelectedFunctionFromList } -BackColor $ColorRed | Out-Null
    New-UiButton -Text "Clear" -X 1095 -Y 288 -Width 160 -Height 44 -OnClick { Clear-SelectedFunctionsList } -BackColor $ColorSlate | Out-Null

    Refresh-FunctionList
}

function Render-PsExecutePage {
    $editorBorder = New-Object System.Windows.Forms.Panel
    $editorBorder.Location = New-Object System.Drawing.Point(45, 12)
    $editorBorder.Size = New-Object System.Drawing.Size(1110, 340)
    $editorBorder.BackColor = $ColorHeaderDark
    Add-ContentControl -Control $editorBorder

    $editorHeader = New-Object System.Windows.Forms.Label
    $editorHeader.Text = ">> PS Code insert Here"
    $editorHeader.Location = New-Object System.Drawing.Point(2, 2)
    $editorHeader.Size = New-Object System.Drawing.Size(1106, 23)
    $editorHeader.Font = $FontNormal
    $editorHeader.BackColor = $ColorHeader
    $editorHeader.ForeColor = $ColorBlack
    $editorHeader.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $editorBorder.Controls.Add($editorHeader)

    $script:PsEditorBox = New-Object System.Windows.Forms.TextBox
    $script:PsEditorBox.Multiline = $true
    $script:PsEditorBox.ScrollBars = "Both"
    $script:PsEditorBox.AcceptsTab = $true
    $script:PsEditorBox.WordWrap = $false
    $script:PsEditorBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $script:PsEditorBox.Location = New-Object System.Drawing.Point(2, 25)
    $script:PsEditorBox.Size = New-Object System.Drawing.Size(1106, 313)
    $script:PsEditorBox.BackColor = [System.Drawing.Color]::White
    $script:PsEditorBox.ForeColor = $ColorText
    $editorBorder.Controls.Add($script:PsEditorBox)

    New-UiButton -Text "Execute" -X 1180 -Y 145 -Width 115 -Height 36 -OnClick { Execute-CustomPowerShell } -BackColor $ColorGreen | Out-Null
}

# -----------------------------
# Main UI - 25 percent wider 3-page layout
# -----------------------------
$form = New-Object System.Windows.Forms.Form
$script:Form = $form
$form.Text = "MuthoBazar Control Center"
$form.Size = New-Object System.Drawing.Size(1360, 825)
$form.StartPosition = "CenterScreen"
$form.MinimumSize = New-Object System.Drawing.Size(1280, 760)
$form.BackColor = $ColorBg

# Border effect panel
$borderPanel = New-Object System.Windows.Forms.Panel
$borderPanel.Location = New-Object System.Drawing.Point(8, 8)
$borderPanel.Size = New-Object System.Drawing.Size(1328, 780)
$borderPanel.BackColor = [System.Drawing.Color]::FromArgb(180, 205, 231)
$borderPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$form.Controls.Add($borderPanel)

# Header
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Location = New-Object System.Drawing.Point(6, 6)
$headerPanel.Size = New-Object System.Drawing.Size(1310, 43)
$headerPanel.BackColor = $ColorHeader
$headerPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$borderPanel.Controls.Add($headerPanel)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "MuthoBazar Control Center"
$titleLabel.Font = $FontTitle
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(82, 7)
$headerPanel.Controls.Add($titleLabel)

# Main tabs
$navPanel = New-Object System.Windows.Forms.Panel
$navPanel.Location = New-Object System.Drawing.Point(360, 55)
$navPanel.Size = New-Object System.Drawing.Size(600, 48)
$navPanel.BackColor = $ColorBg
$borderPanel.Controls.Add($navPanel)

function New-MainTabButton {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][int]$X,
        [int]$Width = 120
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Location = New-Object System.Drawing.Point($X, 5)
    $button.Size = New-Object System.Drawing.Size($Width, 38)
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.FlatAppearance.BorderSize = 0
    $button.Font = $FontTab
    $button.ForeColor = $ColorBlueText
    $button.BackColor = $ColorBg
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $button.Add_Click({ Set-MainTab -TabName $this.Text })
    $navPanel.Controls.Add($button)
    $script:MainTabButtons[$Text] = $button
}

New-MainTabButton -Text "Apps" -X 80 -Width 95
New-MainTabButton -Text "Tools" -X 215 -Width 100
New-MainTabButton -Text "PS Execute" -X 355 -Width 150

# Dynamic content panel
$contentPanel = New-Object System.Windows.Forms.Panel
$script:ContentPanel = $contentPanel
$contentPanel.Location = New-Object System.Drawing.Point(20, 104)
$contentPanel.Size = New-Object System.Drawing.Size(1290, 360)
$contentPanel.BackColor = $ColorBg
$borderPanel.Controls.Add($contentPanel)

# Command log background band
$logBand = New-Object System.Windows.Forms.Panel
$logBand.Location = New-Object System.Drawing.Point(12, 458)
$logBand.Size = New-Object System.Drawing.Size(1302, 305)
$logBand.BackColor = $ColorCanvas
$borderPanel.Controls.Add($logBand)

# Command log label
$logLabel = New-Object System.Windows.Forms.Label
$logLabel.Text = "Command Log"
$logLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$logLabel.ForeColor = $ColorText
$logLabel.AutoSize = $true
$logLabel.Location = New-Object System.Drawing.Point(15, 20)
$logBand.Controls.Add($logLabel)

# Command log
$script:LogBox = New-Object System.Windows.Forms.TextBox
$script:LogBox.Multiline = $true
$script:LogBox.ReadOnly = $true
$script:LogBox.ScrollBars = "Vertical"
$script:LogBox.Font = $FontLog
$script:LogBox.BackColor = $ColorLog
$script:LogBox.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
$script:LogBox.Location = New-Object System.Drawing.Point(15, 75)
$script:LogBox.Size = New-Object System.Drawing.Size(1268, 210)
$logBand.Controls.Add($script:LogBox)

$form.Add_Shown({
    Ensure-Folder -Path $BackupRoot
    Ensure-Folder -Path $ProjectBackupRoot
    Ensure-Folder -Path $LocalFilesRoot
    Ensure-Folder -Path $PatchFilesRoot
    Ensure-Folder -Path $LogRoot

    Set-MainTab -TabName "Apps"

    Append-Log "Ready."
    Append-Log "Repo Root: $RepoRoot"
    Append-Log "Patch Backup Root: $BackupRoot"
    Append-Log "Project Backup Root: $ProjectBackupRoot"
    Append-Log "Local Files Root: $LocalFilesRoot"
    Append-Log "Patch Files Root: $PatchFilesRoot"
    Append-Log "Log Root: $LogRoot"
})

[void]$form.ShowDialog()



