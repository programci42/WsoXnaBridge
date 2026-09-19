' ---------------------------------------------------------------------------
'  play.vbs - silent one-click launcher for a WsoXnaBridge game script.
'  Same job as play.cmd but WITHOUT the black console window: this file runs in
'  wscript (no console) and starts the game with the 32-bit script host.
'  Put it next to your game (.js or .vbs) and double-click it.
'  Optional: play.vbs mygame.js  (runs that script instead of auto-detecting one)
' ---------------------------------------------------------------------------
Option Explicit
Dim fso, sh, here, host, script, f, cmd
Set fso = CreateObject("Scripting.FileSystemObject")
Set sh = CreateObject("WScript.Shell")
here = fso.GetParentFolderName(WScript.ScriptFullName)

' 1) 32-bit script host (SysWOW64 on 64-bit Windows, System32 on 32-bit Windows)
host = sh.ExpandEnvironmentStrings("%WINDIR%") & "\SysWOW64\wscript.exe"
If Not fso.FileExists(host) Then host = sh.ExpandEnvironmentStrings("%WINDIR%") & "\System32\wscript.exe"

' 2) Install the bridge if this computer has not registered it yet (install.bat asks for UAC)
If Not BridgeRegistered() Then
    If fso.FileExists(here & "\install.bat") Then
        sh.Run """" & here & "\install.bat""", 1, True
    ElseIf fso.FileExists(fso.GetParentFolderName(here) & "\install.bat") Then
        sh.Run """" & fso.GetParentFolderName(here) & "\install.bat""", 1, True
    End If
    If Not BridgeRegistered() Then
        MsgBox "WsoXnaBridge is not installed. Run install.bat and approve the UAC prompt.", vbExclamation, "WsoXnaBridge"
        WScript.Quit 1
    End If
End If

' 3) Find the script: argument first, otherwise the first .js then .vbs in this folder (not this launcher)
script = ""
If WScript.Arguments.Count > 0 Then
    script = WScript.Arguments(0)
Else
    For Each f In fso.GetFolder(here).Files
        If LCase(fso.GetExtensionName(f.Name)) = "js" Then script = f.Path: Exit For
    Next
    If script = "" Then
        For Each f In fso.GetFolder(here).Files
            If LCase(fso.GetExtensionName(f.Name)) = "vbs" And LCase(f.Name) <> "play.vbs" Then script = f.Path: Exit For
        Next
    End If
End If
If script = "" Then
    MsgBox "No .js or .vbs game script found next to play.vbs.", vbExclamation, "WsoXnaBridge"
    WScript.Quit 1
End If

' 4) Run it from its own folder, no console window
sh.CurrentDirectory = here
sh.Run """" & host & """ """ & script & """", 1, False

Function BridgeRegistered()
    On Error Resume Next
    Dim regCommand, result
    regCommand = "reg.exe query ""HKCR\WsoXnaBridge.Renderer\CLSID"" /ve"
    If fso.FolderExists(sh.ExpandEnvironmentStrings("%WINDIR%") & "\SysWOW64") Then regCommand = regCommand & " /reg:32"
    result = sh.Run(regCommand, 0, True)
    BridgeRegistered = (Err.Number = 0 And result = 0)
    Err.Clear
    On Error GoTo 0
End Function
