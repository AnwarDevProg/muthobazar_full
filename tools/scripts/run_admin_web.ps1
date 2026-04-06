param(
    [string]$ProjectPath = "C:\Users\1\AndroidStudioProjects\MuthoBazar\apps\admin_web",
    [string]$HostName = "localhost",
    [int]$Port = 8080,
    [switch]$SkipClean
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

    Write-Info "Starting admin web on http://$HostName`:$Port ..."
    flutter run -d web-server --web-hostname $HostName --web-port $Port
    if ($LASTEXITCODE -ne 0) {
        throw "flutter run failed."
    }
}
catch {
    Write-Fail $_.Exception.Message
    exit 1
}



#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web.ps1"
#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web.ps1" -Port 9090
#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web.ps1" -SkipClean
