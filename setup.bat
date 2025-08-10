@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %*
if %errorlevel% neq 0 (
  echo.
  echo If PowerShell is not available, please run the script manually or install PowerShell.
)
