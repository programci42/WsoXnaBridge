@echo off
setlocal EnableExtensions EnableDelayedExpansion
title WsoXnaBridge setup
rem ---------------------------------------------------------------------------
rem  WsoXnaBridge - one-click setup
rem   1) Locate WSO (Scripting.WindowSystemObject) through the registry; if it is not
rem      installed, install the bundled wso.dll into "Program Files\WSO" and register it
rem   2) If XNA Framework 4.0 is missing, install "XNA Framework 4.0 Redist.msi" silently
rem   3) Copy WsoXnaBridge.dll next to wso.dll and register it for COM with 32-bit RegAsm
rem   4) Run a short verification (test_plain_com.js)
rem  Administrator rights are required (copy into Program Files, machine-wide COM
rem  registration, MSI install); the script elevates itself when needed.
rem ---------------------------------------------------------------------------

net session >nul 2>&1
if errorlevel 1 (
    echo Requesting administrator rights...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs -Wait"
    exit /b
)

cd /d "%~dp0"
set "FAILED=0"

rem 32-bit tools (SysWOW64 on 64-bit Windows, System32 on 32-bit Windows)
set "SYS32=%WINDIR%\SysWOW64"
if not exist "%SYS32%\cscript.exe" set "SYS32=%WINDIR%\System32"
set "REGASM=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\RegAsm.exe"

echo.
echo ===== 1/4  Looking for WSO =====
set "WSOCLSID="
for /f "tokens=2,*" %%a in ('reg query "HKCR\Scripting.WindowSystemObject\CLSID" /ve /reg:32 2^>nul ^| findstr /C:"REG_SZ"') do set "WSOCLSID=%%b"
if not defined WSOCLSID (
    echo WSO is not installed; installing the bundled wso.dll...
    if not exist "wso.dll" (
        echo ERROR: WSO is not installed and wso.dll was not found in this folder.
        set "FAILED=1"
        goto :done
    )
    set "WSODIR=%ProgramFiles%\WSO\"
    if not exist "!WSODIR!" mkdir "!WSODIR!"
    copy /y "wso.dll" "!WSODIR!wso.dll" >nul
    if errorlevel 1 (
        echo ERROR: could not copy wso.dll into "!WSODIR!".
        set "FAILED=1"
        goto :done
    )
    "!SYS32!\regsvr32.exe" /s "!WSODIR!wso.dll"
    if errorlevel 1 (
        echo ERROR: COM registration of wso.dll failed.
        set "FAILED=1"
        goto :done
    )
    echo WSO installed: !WSODIR!wso.dll
    set "WSODLL=!WSODIR!wso.dll"
    goto :wso_ready
)
set "WSODLL="
for /f "tokens=2,*" %%a in ('reg query "HKCR\CLSID\%WSOCLSID%\InprocServer32" /ve /reg:32 2^>nul ^| findstr /C:"REG_SZ"') do set "WSODLL=%%b"
if not defined WSODLL (
    echo ERROR: WSO CLSID %WSOCLSID% exists but has no 32-bit InprocServer32 entry.
    set "FAILED=1"
    goto :done
)
for %%i in ("%WSODLL%") do set "WSODIR=%%~dpi"
:wso_ready
echo WSO (32-bit): %WSODLL%
echo Target folder: %WSODIR%

echo.
echo ===== 2/4  XNA Framework 4.0 =====
set "XNAOK="
reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\XNA\Framework\v4.0" /v Installed >nul 2>&1 && set "XNAOK=1"
reg query "HKLM\SOFTWARE\Microsoft\XNA\Framework\v4.0" /v Installed /reg:32 >nul 2>&1 && set "XNAOK=1"
if exist "%WINDIR%\Microsoft.NET\assembly\GAC_32\Microsoft.Xna.Framework.Graphics" set "XNAOK=1"
if defined XNAOK (
    echo XNA Framework 4.0 is already installed.
) else (
    if not exist "XNA Framework 4.0 Redist.msi" (
        echo ERROR: XNA is not installed and "XNA Framework 4.0 Redist.msi" is missing from this folder.
        set "FAILED=1"
        goto :done
    )
    echo Installing XNA Framework 4.0 silently, please wait...
    msiexec /i "XNA Framework 4.0 Redist.msi" /qn /norestart
    if errorlevel 1 (
        echo ERROR: XNA installation failed ^(msiexec exit code !errorlevel!^).
        set "FAILED=1"
        goto :done
    )
    echo XNA Framework 4.0 installed.
)

echo.
echo ===== 3/4  Copying and registering the bridge DLL =====
if not exist "WsoXnaBridge.dll" (
    echo ERROR: WsoXnaBridge.dll was not found in this folder.
    set "FAILED=1"
    goto :done
)
copy /y "WsoXnaBridge.dll" "%WSODIR%" >nul
if errorlevel 1 (
    echo ERROR: could not copy the DLL into "%WSODIR%".
    set "FAILED=1"
    goto :done
)
if not exist "%REGASM%" (
    echo ERROR: .NET Framework 4 RegAsm was not found: %REGASM%
    set "FAILED=1"
    goto :done
)
rem Remove stale per-user (developer) registrations so they cannot shadow the machine-wide one
reg delete "HKCU\Software\Classes\CLSID\{E3B1A2A0-6E7F-4B7A-9A2D-2E7B6B6A0E10}" /f >nul 2>&1
reg delete "HKCU\Software\Classes\WOW6432Node\CLSID\{E3B1A2A0-6E7F-4B7A-9A2D-2E7B6B6A0E10}" /f >nul 2>&1
reg delete "HKCU\Software\Classes\WsoXnaBridge.Renderer" /f >nul 2>&1
"%REGASM%" "%WSODIR%WsoXnaBridge.dll" /codebase /nologo
if errorlevel 1 (
    echo ERROR: RegAsm registration failed.
    set "FAILED=1"
    goto :done
)
echo Registered: WsoXnaBridge.Renderer -^> %WSODIR%WsoXnaBridge.dll

echo.
echo ===== 4/4  Verification =====
if exist "test_plain_com.js" (
    "%SYS32%\cscript.exe" //nologo "test_plain_com.js"
) else (
    echo ^(test_plain_com.js not found, verification skipped^)
)

:done
echo.
if "%FAILED%"=="0" (
    echo SETUP COMPLETE.
    echo Run your game scripts ^(.js / .vbs^) from any folder with the 32-bit script host:
    echo    "%SYS32%\wscript.exe" game.js
    echo Shortcut: put play.cmd next to your script and double-click it, or drop a
    echo .js/.vbs file onto RunScript32.cmd in this folder.
) else (
    echo SETUP FAILED. See the message above.
)
echo.
pause
endlocal
