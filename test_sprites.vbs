Dim Wso, Form, Engine, BallTexture, Player, Spinner, Speed

Set Wso = WScript.CreateObject("Scripting.WindowSystemObject")
Wso.EnableVisualStyles = True

Set Form = Wso.CreateForm(100, 100, 460, 500)
Form.Text = "WSO + XNA - VBScript sprite testi"
Form.ClientWidth = 440
Form.ClientHeight = 440

Dim Ax, Fso, ScriptDir
Set Ax = Form.CreateActiveXControl(0, 0, 440, 440, "WsoXnaBridge.Renderer")
Set Engine = Ax.Control

Set Fso = CreateObject("Scripting.FileSystemObject")
ScriptDir = Fso.GetParentFolderName(WScript.ScriptFullName)
Set BallTexture = Engine.LoadTexture(ScriptDir & "\ball.png")

Set Player = Engine.CreateSprite(BallTexture)
Player.X = 220
Player.Y = 220
Player.CenterOrigin()

Set Spinner = Engine.CreateSprite(BallTexture)
Spinner.X = 100
Spinner.Y = 100
Spinner.CenterOrigin()
Spinner.Color = &HFF6633

Speed = 200

Sub Update(dt)
    If Engine.IsKeyDown("Left") Then Player.X = Player.X - Speed * dt
    If Engine.IsKeyDown("Right") Then Player.X = Player.X + Speed * dt
    If Engine.IsKeyDown("Up") Then Player.Y = Player.Y - Speed * dt
    If Engine.IsKeyDown("Down") Then Player.Y = Player.Y + Speed * dt

    Spinner.Rotation = Spinner.Rotation + dt * 2.0
    Spinner.ScaleX = 1.0 + 0.3 * Sin(Engine.TotalSeconds)
    Spinner.ScaleY = Spinner.ScaleX
End Sub

Engine.OnUpdate = GetRef("Update")

Form.Show()
Wso.Run()
