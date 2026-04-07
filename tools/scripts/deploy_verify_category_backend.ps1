# Run from repo root:
#   powershell -ExecutionPolicy Bypass -File .\tools\scripts\deploy_verify_category_backend.ps1
#
# Before running this script:
# 1) Copy the canvas file "Firestore.rules" into:
#    firebase\firestore.rules
# 2) Copy the canvas file "admin_category_form_dialog.fixed.dart" into:
#    apps\admin_web\lib\features\categories\widgets\admin_category_form_dialog.dart
# 3) Make sure all other canvas code files are pasted into their real repo paths.
#
# What this script does:
# - Builds Firebase Functions
# - Deploys only the category-related callables and logger
# - Deploys Firestore rules
# - Prints a manual verification checklist

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

$functionNames = @(
    "createCategory",
    "updateCategory",
    "deleteCategory",
    "setCategoryActiveState",
    "reorderCategoryGroup",
    "fixCategoryGroupSort",
    "logAdminAction"
)

Require-Command "firebase"
Require-Command "npm"

Write-Step "Repo root"
Write-Host $repoRoot

Write-Step "Functions build"
Push-Location $functionsDir
npm install
npm run build
Pop-Location

Write-Step "Deploy category backend functions one by one"
Push-Location $firebaseDir
foreach ($fn in $functionNames) {
    Write-Host "Deploying function: $fn" -ForegroundColor Yellow
    firebase deploy --only "functions:$fn"
}
Pop-Location

Write-Step "Deploy Firestore rules"
Push-Location $firebaseDir
firebase deploy --only firestore
Pop-Location

Write-Step "Manual verification checklist"
Write-Host "1. Open Firebase Console > Functions and confirm these functions exist:" -ForegroundColor Green
$functionNames | ForEach-Object { Write-Host "   - $_" }
Write-Host "2. Confirm each of the above functions shows region: asia-south1." -ForegroundColor Green
Write-Host "3. Open Firebase Console > Firestore Database > Rules and confirm category writes are blocked from client side." -ForegroundColor Green
Write-Host "4. In admin web, test category create." -ForegroundColor Green
Write-Host "5. In admin web, test category update with multiple field changes." -ForegroundColor Green
Write-Host "6. In admin web, test category active/inactive toggle." -ForegroundColor Green
Write-Host "7. In admin web, test category reorder and fix sort." -ForegroundColor Green
Write-Host "8. In admin web, test category delete for:" -ForegroundColor Green
Write-Host "   - blocked when child categories exist"
Write-Host "   - blocked when productsCount > 0"
Write-Host "   - success when eligible"
Write-Host "9. Open Firestore > admin_activity_logs and verify one log per successful server-side category action." -ForegroundColor Green
Write-Host "10. Confirm actorUid / actorName / actorPhone / actorRole are coming from server-side docs, not client payload." -ForegroundColor Green

Write-Step "Smoke test notes"
Write-Host "If Firestore rules were just deployed, allow a short propagation window before final client verification." -ForegroundColor Yellow
Write-Host "If any function deploy fails, stop and fix that function before continuing to the next feature module." -ForegroundColor Yellow

Write-Step "Done"
Write-Host "Category backend deploy + verification phase completed." -ForegroundColor Cyan
