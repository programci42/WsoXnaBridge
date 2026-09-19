@echo off
setlocal EnableExtensions
title WsoXnaBridge uninstall
rem Removes the COM registration and deletes WsoXnaBridge.dll from the WSO folder.
rem XNA Framework and WSO itself are left untouched.

net session >nul 2>&1
if errorlevel 1 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "REGASM=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\RegAsm.exe"
set "WSOCLSID="
for /f "tokens=2,*" %%a in ('reg query "HKCR\Scripting.WindowSystemObject\CLSID" /ve /reg:32 2^>nul ^| findstr /C:"REG_SZ"') do set "WSOCLSID=%%b"
set "WSODLL="
if defined WSOCLSID for /f "tokens=2,*" %%a in ('reg query "HKCR\CLSID\%WSOCLSID%\InprocServer32" /ve /reg:32 2^>nul ^| findstr /C:"REG_SZ"') do set "WSODLL=%%b"
if defined WSODLL (
    for %%i in ("%WSODLL%") do set "WSODIR=%%~dpi"
) else (
    set "WSODIR=%ProgramFiles%\WSO\"
)

if exist "%WSODIR%WsoXnaBridge.dll" "%REGASM%" "%WSODIR%WsoXnaBridge.dll" /unregister /nologo
reg delete "HKCR\CLSID\{E3B1A2A0-6E7F-4B7A-9A2D-2E7B6B6A0E10}" /f /reg:32 >nul 2>&1
reg delete "HKCR\WsoXnaBridge.Renderer" /f /reg:32 >nul 2>&1
reg delete "HKCU\Software\Classes\CLSID\{E3B1A2A0-6E7F-4B7A-9A2D-2E7B6B6A0E10}" /f >nul 2>&1
reg delete "HKCU\Software\Classes\WOW6432Node\CLSID\{E3B1A2A0-6E7F-4B7A-9A2D-2E7B6B6A0E10}" /f >nul 2>&1
reg delete "HKCU\Software\Classes\WsoXnaBridge.Renderer" /f >nul 2>&1
if exist "%WSODIR%WsoXnaBridge.dll" del /q "%WSODIR%WsoXnaBridge.dll"
echo WsoXnaBridge has been removed.
pause
endlocal
