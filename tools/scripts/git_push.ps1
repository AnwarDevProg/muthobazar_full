param(
    [Parameter(Mandatory = $true)]
    [string]$CommitMessage
)

$ProjectPath = "C:\Users\1\AndroidStudioProjects\MuthoBazar"
$RemoteUrl = "https://github.com/AnwarDevProg/muthobazar_full.git"

try {
    Set-Location $ProjectPath

    git config --global --add safe.directory "C:/Users/1/AndroidStudioProjects/MuthoBazar"

    git status
    git init

    $remoteExists = git remote | Select-String "^origin$"

    if ($remoteExists) {
        git remote set-url origin $RemoteUrl
    }
    else {
        git remote add origin $RemoteUrl
    }

    git add .
    git commit -m $CommitMessage
    git branch -M main
    git push -u origin main
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

#powershell -ExecutionPolicy Bypass -File ".\tools\scripts\git_push.ps1" -RootPath ".\tools" -OutputFile "tools_structure_clean.txt"

#Set-ExecutionPolicy -Scope CurrentUser RemoteSigned; .\tools\scripts\git_push.ps1" "customer app ok, admin ongoing, sidebar has issue"
#Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force; .\git_push.ps1 "customer app ok, admin ongoing, sidebar has issue"