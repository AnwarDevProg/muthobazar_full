@echo off
title MuthoBazar Control Center Launcher
cd /d "%~dp0"

echo Starting MuthoBazar Control Center...
echo.

powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -NoExit -File "%~dp0muthobazar_control_center.ps1"

echo.
echo Script finished or failed.
pause
