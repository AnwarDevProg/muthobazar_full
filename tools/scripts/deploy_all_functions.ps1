# Run from repo root:
# powershell -ExecutionPolicy Bypass -File .\tools\scripts\deploy_all_functions.ps1
#
# This script:
# 1) installs functions dependencies
# 2) builds all Firebase Functions
# 3) deploys all functions in the project

$ErrorActionPreference = "Stop"

function Write-Step($text) {
    Write-Host "`n=== $text ===" -ForegroundColor Cyan
}

function Require-Command($name) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $name"
    }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent $repoRoot

$functionsDir = Join-Path $repoRoot "firebase\functions"
$firebaseDir = Join-Path $repoRoot "firebase"

Require-Command "npm"
Require-Command "firebase"

Write-Step "Repo root"
Write-Host $repoRoot

Write-Step "Install Firebase Functions dependencies"
Push-Location $functionsDir
npm install
Pop-Location

Write-Step "Build Firebase Functions"
Push-Location $functionsDir
npm run build
Pop-Location

Write-Step "Deploy all Firebase Functions"
Push-Location $firebaseDir
firebase deploy --only functions
Pop-Location

Write-Step "Done"
Write-Host "All Firebase Functions were built and deploy command completed." -ForegroundColor Green
