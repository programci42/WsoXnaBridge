var wso = new ActiveXObject("Scripting.WindowSystemObject");
wso.EnableVisualStyles = true;

var form = wso.CreateForm(100, 100, 460, 500);
form.Text = "WSO + XNA - JScript sprite testi";
form.ClientWidth = 440;
form.ClientHeight = 440;

var ax = form.CreateActiveXControl(0, 0, 440, 440, "WsoXnaBridge.Renderer");
var engine = ax.Control;

var fso = new ActiveXObject("Scripting.FileSystemObject");
var scriptDir = fso.GetParentFolderName(WScript.ScriptFullName);
var ballTexture = engine.LoadTexture(scriptDir + "\\ball.png");

var player = engine.CreateSprite(ballTexture);
player.X = 220; player.Y = 220;
player.CenterOrigin();

var spinner = engine.CreateSprite(ballTexture);
spinner.X = 100; spinner.Y = 100;
spinner.CenterOrigin();
spinner.Color = 0xFF6633;

var speed = 200; // px/sec

function Update(dt) {
    if (engine.IsKeyDown("Left"))  player.X -= speed * dt;
    if (engine.IsKeyDown("Right")) player.X += speed * dt;
    if (engine.IsKeyDown("Up"))    player.Y -= speed * dt;
    if (engine.IsKeyDown("Down"))  player.Y += speed * dt;

    spinner.Rotation += dt * 2.0;
    spinner.ScaleX = 1.0 + 0.3 * Math.sin(engine.TotalSeconds);
    spinner.ScaleY = spinner.ScaleX;
}

engine.OnUpdate = Update;

form.Show();
wso.Run();
