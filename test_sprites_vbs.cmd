@echo off
rem WsoXnaBridge x86-only oldugu icin 32-bit script host'u ACIKCA cagiriyoruz.
rem Cift tiklandiginda varsayilan .vbs iliskilendirmesi 64-bit WScript.exe'yi kullanir
rem ve x86-only kopru DLL'i "yanlis format" hatasiyla yuklenemez.
"%SystemRoot%\SysWOW64\wscript.exe" "%~dp0test_sprites.vbs"
