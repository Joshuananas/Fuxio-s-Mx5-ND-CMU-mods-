@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Prepare-CMU-USB.ps1"
if errorlevel 1 pause
