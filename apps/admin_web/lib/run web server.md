
cd "C:\Users\1\AndroidStudioProjects\MuthoBazar\apps\admin_web"
flutter clean
flutter pub get
flutter run -d web-server --web-hostname localhost --web-port 8080




or use


powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web.ps1"
powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web.ps1" -Port 9090
powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web.ps1" -SkipClean



or open chrome


powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web_chrome.ps1"
powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web_chrome.ps1" -SkipClean
powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web_chrome.ps1" -Port 9090
powershell -ExecutionPolicy Bypass -File ".\tools\scripts\run_admin_web_chrome.ps1" -ChromePath "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

