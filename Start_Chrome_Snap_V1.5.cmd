@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Launch_USB_Capture_Snap_V1.5.ps1" -Browser Chrome -HeightPercent 34
if errorlevel 1 pause
