# WsoXnaBridge

WsoXnaBridge lets Windows Script Host games written in JScript or VBScript use XNA Framework 4.0 for hardware-accelerated sprites, text, sound, keyboard, and mouse input. WSO (`Scripting.WindowSystemObject`) creates the window while `WsoXnaBridge.Renderer` supplies rendering and the game loop.

## One-click installation

1. Download the repository or extract its ZIP archive.
2. Double-click `install.bat` and approve the Windows administrator prompt.
3. The installer locates WSO through the registry. If WSO is missing, it installs the bundled `wso.dll`.
4. If XNA Framework 4.0 is missing, it silently installs `XNA Framework 4.0 Redist.msi`.
5. It copies `WsoXnaBridge.dll` next to WSO, registers the 32-bit COM component, and runs an automatic smoke test.

Run `uninstall.bat` as administrator to remove the bridge. It leaves XNA Framework and any pre-existing WSO installation in place.

## Example game

`Example_Game` contains a small driving game made with road, car, and zombie artwork from LoopCut. It includes a scrolling road, animated zombies, FPS display, collision scoring, and dismemberment effects.

- Double-click `Example_Game\play.vbs` to start the JScript version without opening a black console window. If the bridge is missing, the launcher starts `install.bat`, waits for setup, and then starts the game.
- Run `Example_Game\play.vbs example_game.vbs` for the VBScript version.
- `play.cmd` remains available as a console launcher for troubleshooting.
- Arrow keys drive the car.
- Hitting a zombie awards 100 points.

Both implementations use the same API and assets, making them useful starting points for new games.

## Running your own game

Copy `play.vbs` next to a `.js` or `.vbs` game and double-click it. The launcher stays hidden, detects 32-bit or 64-bit Windows, and selects the correct 32-bit Windows Script Host. You may also pass a script explicitly:

```bat
play.vbs mygame.js
play.vbs mygame.vbs
```

WsoXnaBridge is an x86 COM component. On 64-bit Windows, starting a game directly with the 64-bit `wscript.exe` will fail. The supplied launcher prevents that mistake. Use `play.cmd` only when you want to see console output while troubleshooting. Game scripts and assets may live in any folder; use absolute paths or resolve relative paths from `WScript.ScriptFullName`.

## Minimal JScript example

```js
var wso = new ActiveXObject("Scripting.WindowSystemObject");
var form = wso.CreateForm(100, 100, 820, 660);
var host = form.CreateActiveXControl(0, 0, 800, 600, "WsoXnaBridge.Renderer");
var game = host.Control;

var texture = game.LoadTexture("C:\\mygame\\player.png");
var player = game.CreateSprite(texture);
player.X = 400;
player.Y = 300;

function Update(dt) {
    if (game.IsKeyDown("Right")) player.X += 200 * dt;
}

game.OnUpdate = Update;
form.Show();
wso.Run();
```

VBScript assigns the callback with `Game.OnUpdate = GetRef("Update")`.

## Script API

### Renderer

- `LoadTexture(path)` and `CreateSprite(texture)`
- `CreateText(text, fontFamily, fontSize)`
- `LoadSound(path)`
- `IsKeyDown(name)` and `IsMouseDown(button)`
- `MouseX`, `MouseY`, `ElapsedSeconds`, and `TotalSeconds`
- `BackgroundColor`, `Width`, `Height`, and `OnUpdate`

### Sprite

- `X`, `Y`, `Rotation`, `ScaleX`, `ScaleY`, `OriginX`, `OriginY`, and `Layer`
- `Visible`, `Color`, `Alpha`, and `Texture`
- `Scale(value)`, `CenterOrigin()`, and `Destroy()`
- `SetSourceRect(x, y, width, height)` and `ClearSourceRect()`
- `SetText(text)` for text sprites

### Sound

- `Play()`, `Play(volume)`, `PlayLooped()`, and `StopLoop()`
- `DurationSeconds`

## Troubleshooting

- **ActiveX object can't create object:** run `install.bat`, then launch the game through `play.vbs`.
- **BadImageFormat or wrong format:** a 64-bit script host was used. Start the game through `play.vbs`.
- **XNA fails to load:** make sure `XNA Framework 4.0 Redist.msi` is present and run the installer again.
- Runtime details are written to `renderer.log` next to the installed `WsoXnaBridge.dll`.

## Repository contents

- `WsoXnaBridge.dll`: ready-to-use x86 COM bridge
- `wso.dll`: WSO runtime
- `XNA Framework 4.0 Redist.msi`: XNA runtime installer
- `install.bat`, `uninstall.bat`, `play.vbs`, `play.cmd`, and `RunScript32.cmd`: setup and launch tools
- `Example_Game`: JScript and VBScript sample game
- `*.cs`: C# bridge source files
- `test_*`: basic and advanced test scripts

Third-party runtime and audio attribution is recorded in `THIRD_PARTY_NOTICES.md`. Add the license you want to use for your own source code before publishing if you want others to be able to modify and redistribute it under explicit terms.
