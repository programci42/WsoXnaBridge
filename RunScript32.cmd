@echo off
rem Runs a .js / .vbs game script with the 32-bit Windows Script Host.
rem WsoXnaBridge (XNA 4.0) is x86-only, so scripts must NOT be opened with the 64-bit wscript.exe.
rem Usage: RunScript32.cmd game.js   (or drag and drop the file onto this .cmd)
if "%~1"=="" (
    echo Usage: %~nx0 game.js
    pause
    exit /b 1
)
set "SYS32=%WINDIR%\SysWOW64"
if not exist "%SYS32%\wscript.exe" set "SYS32=%WINDIR%\System32"
"%SYS32%\wscript.exe" "%~f1"
