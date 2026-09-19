Dim Wso, Form, Ax, Engine, Fso, ScriptDir
Dim Sheet, Anim, Label, Ding
Dim Frame, FrameTimer, SoundCooldown

Set Wso = WScript.CreateObject("Scripting.WindowSystemObject")
Wso.EnableVisualStyles = True

Set Form = Wso.CreateForm(100, 100, 460, 500)
Form.Text = "WSO + XNA - sprite sheet / text / sound testi (VBScript)"
Form.ClientWidth = 440
Form.ClientHeight = 440

Set Ax = Form.CreateActiveXControl(0, 0, 440, 440, "WsoXnaBridge.Renderer")
Set Engine = Ax.Control

Set Fso = CreateObject("Scripting.FileSystemObject")
ScriptDir = Fso.GetParentFolderName(WScript.ScriptFullName)

' --- 1) Sprite sheet dilimleme (Rectangle'in script karsiligi) ---
Set Sheet = Engine.LoadTexture(ScriptDir & "\spritesheet.png")
Set Anim = Engine.CreateSprite(Sheet)
Anim.X = 100
Anim.Y = 150
Anim.SetSourceRect 0, 0, 64, 64 ' ilk kare: x, y, genislik, yukseklik
Anim.CenterOrigin()

Frame = 0
FrameTimer = 0

' --- 2) Metin cizimi (SpriteFont yerine GDI+ ile runtime texture) ---
Set Label = Engine.CreateText("Sure: 0.0", "Arial", 22)
Label.X = 20
Label.Y = 20
Label.Color = &HFFFFFF

' --- 3) Ses efekti (SoundEffect.FromStream ile runtime WAV yukleme) ---
Set Ding = Engine.LoadSound(ScriptDir & "\ding.wav")
Ding.Play() ' basta bir kere calalim

SoundCooldown = 0

Sub Update(dt)
    ' sprite sheet animasyonu: her 0.2 saniyede bir sonraki kareye gec
    FrameTimer = FrameTimer + dt
    If FrameTimer > 0.2 Then
        FrameTimer = 0
        Frame = (Frame + 1) Mod 4
        Anim.SetSourceRect Frame * 64, 0, 64, 64
    End If

    ' metni her frame guncelle
    Label.SetText "Sure: " & FormatNumber(Engine.TotalSeconds, 1)

    ' Space tusuna basinca ses cal (cooldown ile ust uste calmayi engelle)
    SoundCooldown = SoundCooldown - dt
    If Engine.IsKeyDown("Space") And SoundCooldown <= 0 Then
        Ding.Play()
        SoundCooldown = 0.3
    End If
End Sub

Engine.OnUpdate = GetRef("Update")

Form.Show()
Wso.Run()
