@echo off
setlocal EnableExtensions
rem ---------------------------------------------------------------------------
rem  play.cmd - one-click launcher for a WsoXnaBridge game script.
rem  Put this file next to your game (.js or .vbs) and double-click it.
rem  It detects whether Windows is 32- or 64-bit and starts the script with the
rem  32-bit Windows Script Host, which is required because WsoXnaBridge (XNA 4.0)
rem  is an x86-only COM component: the 64-bit wscript.exe cannot load it.
rem  Optional: play.cmd mygame.js  (runs that script instead of auto-detecting one)
rem ---------------------------------------------------------------------------

rem 1) Pick the 32-bit script host
set "HOST=%WINDIR%\System32\wscript.exe"
if defined PROCESSOR_ARCHITEW6432 set "HOST=%WINDIR%\SysWOW64\wscript.exe"
if /i not "%PROCESSOR_ARCHITECTURE%"=="x86" set "HOST=%WINDIR%\SysWOW64\wscript.exe"
if not exist "%HOST%" set "HOST=%WINDIR%\System32\wscript.exe"

rem 2) Install the bridge automatically when this computer has not registered it yet
reg query "HKCR\WsoXnaBridge.Renderer\CLSID" /ve /reg:32 >nul 2>&1
if errorlevel 1 (
    if not exist "%~dp0..\install.bat" (
        echo WsoXnaBridge is not installed and install.bat was not found in the parent folder.
        pause
        exit /b 1
    )
    echo WsoXnaBridge is not installed. Starting the installer...
    call "%~dp0..\install.bat"
    reg query "HKCR\WsoXnaBridge.Renderer\CLSID" /ve /reg:32 >nul 2>&1
    if errorlevel 1 (
        echo Installation did not complete. Run install.bat and approve the UAC prompt.
        pause
        exit /b 1
    )
)

rem 3) Find the script: argument first, otherwise the first .js then .vbs in this folder
set "SCRIPT="
if not "%~1"=="" (
    set "SCRIPT=%~f1"
) else (
    for %%f in ("%~dp0*.js") do if not defined SCRIPT set "SCRIPT=%%~ff"
    for %%f in ("%~dp0*.vbs") do if not defined SCRIPT set "SCRIPT=%%~ff"
)
if not defined SCRIPT (
    echo No .js or .vbs script found next to play.cmd.
    pause
    exit /b 1
)

rem 4) Run it (the working directory is the script's own folder)
cd /d "%~dp0"
"%HOST%" "%SCRIPT%"
endlocal
