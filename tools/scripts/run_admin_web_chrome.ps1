param(
    [string]$ProjectPath = "C:\Users\1\AndroidStudioProjects\MuthoBazar\apps\admin_web",
    [string]$HostName = "localhost",
    [int]$Port = 8080,
    [string]$ChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe",
    [switch]$SkipClean,
    [int]$OpenBrowserDelaySeconds = 8
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
    Write-Info "App URL: $Url"

    $flutterCommand = "Set-Location '$ProjectPath'; flutter run -d web-server --web-hostname $HostName --web-port $Port"

    Write-Info "Starting Flutter web server in a new PowerShell window..."
    Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-Command", $flutterCommand

    Write-Info "Waiting $OpenBrowserDelaySeconds seconds before opening Chrome..."
    Start-Sleep -Seconds $OpenBrowserDelaySeconds

    Write-Info "Opening Chrome..."
    Start-Process -FilePath $ChromePath -ArgumentList $Url

    Write-Success "Chrome opened successfully. Exiting launcher script."
    exit 0
}
catch {
    Write-Fail $_.Exception.Message
    exit 1
}


#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web_chrome.ps1"
#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web_chrome.ps1" -SkipClean
#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web_chrome.ps1" -Port 9090
#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web_chrome.ps1" -ChromePath "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"



