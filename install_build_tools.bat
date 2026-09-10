@echo off
title Installing Visual Studio 2022 C++ Build Tools
cls
echo ========================================================
echo   Starting VS 2022 C++ Build Tools Setup...
echo ========================================================
echo.
echo Please click [YES] when Windows UAC prompt appears.
echo.

set "INSTALLER=%LOCALAPPDATA%\Temp\WinGet\Microsoft.VisualStudio.2022.BuildTools.17.14.40\vs_BuildTools.exe"

if not exist "%INSTALLER%" (
    echo Downloading installer...
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_BuildTools.exe' -OutFile '%TEMP%\vs_BuildTools.exe'"
    set "INSTALLER=%TEMP%\vs_BuildTools.exe"
)

echo Running installer, please wait...
"%INSTALLER%" --passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended

echo.
echo ========================================================
echo   Installation Finished!
echo ========================================================
pause
