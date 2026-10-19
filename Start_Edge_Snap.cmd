@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Launch_USB_Capture_Snap.ps1" -Browser Edge -HeightPercent 34
if errorlevel 1 pause
