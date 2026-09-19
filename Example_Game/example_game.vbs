Dim Wso, Form, Host, Game, Fso, Here, Assets
Dim RoadTexture, CarTexture, WalkFrames(3), GoreUpperTexture, GoreLowerTexture, RoadA, RoadB, Car
Dim EngineSound, CrushSound
Dim ScoreLabel, HelpLabel, Zombies(5), ZX(5), ZY(5), ZSpeed(5)
Dim FpsLabel, GoreUpper(5), GoreLower(5), GoreActive(5), GoreX(5), GoreY(5), GoreVX(5), GoreVY(5), GoreAge(5)
Dim Score, I, AnimationTime, FpsTime, FpsFrames

Set Wso = WScript.CreateObject("Scripting.WindowSystemObject")
Wso.EnableVisualStyles = True
Set Form = Wso.CreateForm(120, 80, 820, 660)
Form.Text = "WsoXnaBridge - Highway Zombies (VBScript)"
Form.ClientWidth = 800
Form.ClientHeight = 600
Set Host = Form.CreateActiveXControl(0, 0, 800, 600, "WsoXnaBridge.Renderer")
Set Game = Host.Control
Set Fso = CreateObject("Scripting.FileSystemObject")
Here = Fso.GetParentFolderName(WScript.ScriptFullName)
Assets = Here & "\Assets\"

' Load the road, car, four walk frames, and two dismemberment pieces.
Set RoadTexture = Game.LoadTexture(Assets & "highway_base.png")
Set CarTexture = Game.LoadTexture(Assets & "car_player.png")
For I = 0 To 3
    Set WalkFrames(I) = Game.LoadTexture(Assets & "zombie_walk\frame00" & (I + 1) & ".png")
Next
Set GoreUpperTexture = Game.LoadTexture(Assets & "zombie_gore_upper.png")
Set GoreLowerTexture = Game.LoadTexture(Assets & "zombie_gore_lower.png")
Set EngineSound = Game.LoadSound(Assets & "car_engine.wav")
Set CrushSound = Game.LoadSound(Assets & "car_crush.wav")
EngineSound.PlayLooped
Set RoadA = Game.CreateSprite(RoadTexture)
Set RoadB = Game.CreateSprite(RoadTexture)
RoadA.Scale 0.86
RoadB.Scale 0.86
RoadA.X = -30: RoadB.X = -30
RoadA.Y = 0: RoadB.Y = -602

Set Car = Game.CreateSprite(CarTexture)
Car.Scale 0.22
Car.CenterOrigin
Car.X = 400: Car.Y = 500: Car.Layer = 10

Set ScoreLabel = Game.CreateText("SCORE: 0", "Arial", 24)
ScoreLabel.X = 18: ScoreLabel.Y = 14: ScoreLabel.Layer = 20
Set HelpLabel = Game.CreateText("ARROWS: DRIVE   |   HIT ZOMBIES", "Arial", 16)
HelpLabel.X = 18: HelpLabel.Y = 48: HelpLabel.Layer = 20
HelpLabel.Color = &HFFE080
Set FpsLabel = Game.CreateText("FPS: --", "Arial", 18)
FpsLabel.X = 690: FpsLabel.Y = 16: FpsLabel.Layer = 20

Randomize
Score = 0
For I = 0 To 5
    Set Zombies(I) = Game.CreateSprite(WalkFrames(0))
    Zombies(I).Scale 0.18
    Zombies(I).CenterOrigin
    Zombies(I).Layer = 5
    ResetZombie I, -I * 115 - 80
    If I = 0 Then
        ZX(I) = 400: ZY(I) = 370
        Zombies(I).X = 400: Zombies(I).Y = 370
    End If
    Set GoreUpper(I) = Game.CreateSprite(GoreUpperTexture)
    Set GoreLower(I) = Game.CreateSprite(GoreLowerTexture)
    GoreUpper(I).Scale 0.18: GoreLower(I).Scale 0.18
    GoreUpper(I).CenterOrigin: GoreLower(I).CenterOrigin
    GoreUpper(I).Layer = 8: GoreLower(I).Layer = 8
    GoreUpper(I).Visible = False: GoreLower(I).Visible = False
    GoreActive(I) = False
Next
AnimationTime = 0: FpsTime = 0: FpsFrames = 0

Sub ResetZombie(Index, StartY)
    ZX(Index) = 215 + Rnd * 370
    If StartY < 0 Then
        ZY(Index) = StartY
    Else
        ZY(Index) = -80 - Rnd * 280
    End If
    ZSpeed(Index) = 105 + Rnd * 85
    Zombies(Index).X = ZX(Index)
    Zombies(Index).Y = ZY(Index)
End Sub

Sub BurstZombie(X, Y)
    ' Reuse a small effect pool so collisions do not create sprites every frame.
    Dim G
    G = 0
    For G = 0 To 5
        If Not GoreActive(G) Then Exit For
    Next
    If G > 5 Then G = 0
    GoreActive(G) = True: GoreX(G) = X: GoreY(G) = Y: GoreAge(G) = 0
    GoreVX(G) = (Rnd - 0.5) * 240: GoreVY(G) = -190
    GoreUpper(G).X = X: GoreUpper(G).Y = Y - 8
    GoreLower(G).X = X: GoreLower(G).Y = Y + 10
    GoreUpper(G).Rotation = 0: GoreLower(G).Rotation = 0
    GoreUpper(G).Visible = True: GoreLower(G).Visible = True
End Sub

Sub Update(dt)
    Dim Steer, WalkFrame, Z, G, Fade
    ' Clamp long frames so a paused window cannot jump the simulation forward.
    If dt > 0.1 Then dt = 0.1
    FpsTime = FpsTime + dt: FpsFrames = FpsFrames + 1
    If FpsTime >= 0.5 Then
        FpsLabel.SetText "FPS: " & Round(FpsFrames / FpsTime)
        FpsTime = 0: FpsFrames = 0
    End If
    AnimationTime = AnimationTime + dt
    WalkFrame = Int(AnimationTime / 0.12) Mod 4
    RoadA.Y = RoadA.Y + 250 * dt
    RoadB.Y = RoadB.Y + 250 * dt
    If RoadA.Y >= 602 Then RoadA.Y = RoadB.Y - 602
    If RoadB.Y >= 602 Then RoadB.Y = RoadA.Y - 602

    Steer = 300 * dt
    If Game.IsKeyDown("Left") Then Car.X = Car.X - Steer
    If Game.IsKeyDown("Right") Then Car.X = Car.X + Steer
    If Game.IsKeyDown("Up") Then Car.Y = Car.Y - Steer
    If Game.IsKeyDown("Down") Then Car.Y = Car.Y + Steer
    If Car.X < 215 Then Car.X = 215
    If Car.X > 585 Then Car.X = 585
    If Car.Y < 330 Then Car.Y = 330
    If Car.Y > 545 Then Car.Y = 545

    For I = 0 To 5
        Set Z = Zombies(I)
        Set Z.Texture = WalkFrames(WalkFrame)
        ZY(I) = ZY(I) + ZSpeed(I) * dt
        Zombies(I).X = ZX(I): Zombies(I).Y = ZY(I)
        If Abs(Car.X - ZX(I)) < 42 And Abs(Car.Y - ZY(I)) < 54 Then
            Score = Score + 100
            ScoreLabel.SetText "SCORE: " & Score
            CrushSound.Play
            BurstZombie ZX(I), ZY(I)
            ResetZombie I, 0
        ElseIf ZY(I) > 680 Then
            ResetZombie I, 0
        End If
    Next
    For G = 0 To 5
        If GoreActive(G) Then
            GoreAge(G) = GoreAge(G) + dt
            GoreVY(G) = GoreVY(G) + 430 * dt
            GoreX(G) = GoreX(G) + GoreVX(G) * dt
            GoreY(G) = GoreY(G) + GoreVY(G) * dt
            GoreUpper(G).X = GoreX(G) - GoreVX(G) * 0.02: GoreUpper(G).Y = GoreY(G) - 12
            GoreLower(G).X = GoreX(G) + GoreVX(G) * 0.02: GoreLower(G).Y = GoreY(G) + 14
            GoreUpper(G).Rotation = GoreUpper(G).Rotation - dt * 7
            GoreLower(G).Rotation = GoreLower(G).Rotation + dt * 6
            Fade = 255 - GoreAge(G) * 260
            If Fade < 0 Then Fade = 0
            GoreUpper(G).Alpha = Fade: GoreLower(G).Alpha = Fade
            If GoreAge(G) > 0.95 Then
                GoreActive(G) = False
                GoreUpper(G).Visible = False: GoreLower(G).Visible = False
            End If
        End If
    Next
End Sub

Game.OnUpdate = GetRef("Update")
Form.Show
Wso.Run
