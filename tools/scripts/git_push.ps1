param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$CommitMessage
)

$ProjectPath = "C:\Users\1\AndroidStudioProjects\MuthoBazar"
$RemoteName = "origin"
$RemoteUrl = "https://github.com/AnwarDevProg/muthobazar_full.git"
$BranchName = "main"

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
    Set-Location $ProjectPath
    Write-Info "Working directory: $ProjectPath"

    git config --global --add safe.directory "C:/Users/1/AndroidStudioProjects/MuthoBazar" | Out-Null

    if (-not (Test-Path ".git")) {
        Write-Info "Git repository not found. Initializing..."
        git init
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to initialize git repository."
        }
        Write-Success "Git repository initialized."
    }
    else {
        Write-Info "Git repository already initialized."
    }

    $remoteExists = git remote | Select-String "^$RemoteName$"

    if ($remoteExists) {
        Write-Info "Remote '$RemoteName' exists. Updating URL..."
        git remote set-url $RemoteName $RemoteUrl
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to set remote URL."
        }
        Write-Success "Remote URL updated."
    }
    else {
        Write-Info "Remote '$RemoteName' not found. Adding remote..."
        git remote add $RemoteName $RemoteUrl
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to add remote."
        }
        Write-Success "Remote added."
    }

    $statusBefore = git status --porcelain

    if ([string]::IsNullOrWhiteSpace(($statusBefore | Out-String))) {
        Write-Warn "No changes found. Nothing to commit."
        git status
        exit 0
    }

    Write-Info "Staging all changes..."
    git add .
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to stage files."
    }
    Write-Success "All changes staged."

    $cachedStatus = git diff --cached --name-only
    if ([string]::IsNullOrWhiteSpace(($cachedStatus | Out-String))) {
        Write-Warn "No staged changes found after git add. Nothing to commit."
        git status
        exit 0
    }

    Write-Info "Creating commit..."
    git commit -m $CommitMessage
    if ($LASTEXITCODE -ne 0) {
        throw "Commit failed. Check git output above."
    }
    Write-Success "Commit created."

    Write-Info "Switching branch to '$BranchName'..."
    git branch -M $BranchName
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to switch branch to $BranchName."
    }
    Write-Success "Branch set to '$BranchName'."

    Write-Info "Pushing to $RemoteName/$BranchName ..."
    git push -u $RemoteName $BranchName
    if ($LASTEXITCODE -ne 0) {
        throw "Push failed. Check authentication, remote URL, or branch state."
    }
    Write-Success "Push completed successfully."

    $statusAfter = git status --porcelain

    if ([string]::IsNullOrWhiteSpace(($statusAfter | Out-String))) {
        Write-Success "Repository is clean."
    }
    else {
        Write-Warn "Repository still has remaining changes after push:"
        git status
    }
}
catch {
    Write-Fail $_.Exception.Message
    exit 1
}



#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\git_push.ps1" -CommitMessage "customer app ok, admin ongoing, sidebar has issue"