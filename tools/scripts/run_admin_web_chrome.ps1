param(
    [string]$ProjectPath = "C:\Users\1\AndroidStudioProjects\MuthoBazar\apps\admin_web",
    [string]$HostName = "localhost",
    [int]$Port = 8080,
    [string]$ChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe",
    [switch]$SkipClean,
    [int]$WaitTimeoutSeconds = 180
)

function Write-Info($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success($Message) {
    Write-Host "[OK]   $Message" -ForegroundColor Green
}

function Write-Warn($Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Fail($Message) {
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Test-WebUrlReady {
    param(
        [string]$Url
    )

    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -Method Get -TimeoutSec 3
        return $response.StatusCode -ge 200 -and $response.StatusCode -lt 500
    }
    catch {
        return $false
    }
}

try {
    if (-not (Test-Path $ProjectPath)) {
        throw "Project path not found: $ProjectPath"
    }

    if (-not (Test-Path $ChromePath)) {
        throw "Chrome not found at: $ChromePath"
    }

    Set-Location $ProjectPath
    Write-Info "Working directory: $ProjectPath"

    if (-not $SkipClean) {
        Write-Info "Running flutter clean..."
        flutter clean
        if ($LASTEXITCODE -ne 0) {
            throw "flutter clean failed."
        }
        Write-Success "flutter clean completed."
    }
    else {
        Write-Warn "Skipping flutter clean."
    }

    Write-Info "Running flutter pub get..."
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw "flutter pub get failed."
    }
    Write-Success "flutter pub get completed."

    $Url = "http://$HostName`:$Port"
    $LogFile = Join-Path $env:TEMP "flutter_admin_web_$Port.log"

    if (Test-Path $LogFile) {
        Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    Write-Info "App URL: $Url"
    Write-Info "Log file: $LogFile"

    $flutterCommand = @"
Set-Location '$ProjectPath'
flutter run -d web-server --web-hostname $HostName --web-port $Port 2>&1 | Tee-Object -FilePath '$LogFile'
"@

    Write-Info "Starting Flutter web server in a new PowerShell window..."
    Start-Process powershell `
        -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-Command", $flutterCommand `
        -PassThru | Out-Null

    Write-Info "Waiting until Flutter prints the localhost serve line..."

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $browserOpened = $false
    $servedPattern = [regex]::Escape("lib\main.dart is being served at $Url")

    while ($stopwatch.Elapsed.TotalSeconds -lt $WaitTimeoutSeconds) {
        Start-Sleep -Seconds 1

        $servedLineFound = $false
        if (Test-Path $LogFile) {
            $servedLineFound = Select-String -Path $LogFile -Pattern $servedPattern -Quiet
        }

        if ($servedLineFound) {
            Write-Success "Flutter reported that localhost is now being served."

            $urlReady = $false
            $urlStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            while ($urlStopwatch.Elapsed.TotalSeconds -lt 30) {
                if (Test-WebUrlReady -Url $Url) {
                    $urlReady = $true
                    break
                }
                Start-Sleep -Milliseconds 500
            }

            if (-not $urlReady) {
                Write-Warn "Flutter printed the serve line, but the URL did not respond in time."
                Write-Warn "You can still open this manually: $Url"
                exit 1
            }

            Write-Info "Opening Chrome..."
            Start-Process -FilePath $ChromePath -ArgumentList $Url
            $browserOpened = $true
            break
        }
    }

    if (-not $browserOpened) {
        Write-Warn "Timed out waiting for Flutter to print the localhost serve line."
        Write-Warn "You can still open this manually: $Url"
        exit 1
    }

    Write-Success "Chrome opened successfully after localhost was confirmed ready."
    exit 0
}
catch {
    Write-Fail $_.Exception.Message
    exit 1
}

# Usage:
# powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web_chrome.ps1"
# powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web_chrome.ps1" -SkipClean
# powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web_chrome.ps1" -Port 9090
# powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web_chrome.ps1" -ChromePath "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
