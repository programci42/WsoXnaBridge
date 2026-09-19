var wso = new ActiveXObject("Scripting.WindowSystemObject");
wso.EnableVisualStyles = true;

var form = wso.CreateForm(120, 80, 820, 660);
form.Text = "WsoXnaBridge - Highway Zombies (JScript)";
form.ClientWidth = 800;
form.ClientHeight = 600;

var host = form.CreateActiveXControl(0, 0, 800, 600, "WsoXnaBridge.Renderer");
var game = host.Control;
var fso = new ActiveXObject("Scripting.FileSystemObject");
var here = fso.GetParentFolderName(WScript.ScriptFullName);
var assets = here + "\\Assets\\";

// Load the road, car, four walk frames, and two dismemberment pieces.
var roadTexture = game.LoadTexture(assets + "highway_base.png");
var carTexture = game.LoadTexture(assets + "car_player.png");
var walkFrames = [];
for (var wf = 1; wf <= 4; wf++) {
    walkFrames.push(game.LoadTexture(assets + "zombie_walk\\frame00" + wf + ".png"));
}
var goreUpperTexture = game.LoadTexture(assets + "zombie_gore_upper.png");
var goreLowerTexture = game.LoadTexture(assets + "zombie_gore_lower.png");
var engineSound = game.LoadSound(assets + "car_engine.wav");
var crushSound = game.LoadSound(assets + "car_crush.wav");
engineSound.PlayLooped();

var roadA = game.CreateSprite(roadTexture);
var roadB = game.CreateSprite(roadTexture);
roadA.Scale(0.86); roadB.Scale(0.86);
roadA.X = -30; roadB.X = -30;
roadA.Y = 0; roadB.Y = -602;

var car = game.CreateSprite(carTexture);
car.Scale(0.22); car.CenterOrigin();
car.X = 400; car.Y = 500; car.Layer = 10;

var scoreLabel = game.CreateText("SCORE: 0", "Arial", 24);
scoreLabel.X = 18; scoreLabel.Y = 14; scoreLabel.Layer = 20;
var help = game.CreateText("ARROWS: DRIVE   |   HIT ZOMBIES", "Arial", 16);
help.X = 18; help.Y = 48; help.Layer = 20; help.Color = 0xFFE080;
var fpsLabel = game.CreateText("FPS: --", "Arial", 18);
fpsLabel.X = 690; fpsLabel.Y = 16; fpsLabel.Layer = 20;

var zombies = [];
for (var i = 0; i < 6; i++) {
    var z = game.CreateSprite(walkFrames[0]);
    z.Scale(0.18); z.CenterOrigin(); z.Layer = 5;
    zombies.push({ sprite: z, x: 0, y: 0, speed: 0 });
    resetZombie(zombies[i], -i * 115 - 80);
    if (i === 0) { zombies[i].x = 400; zombies[i].y = 370; z.X = 400; z.Y = 370; }
}

var gore = [];
for (var g = 0; g < 6; g++) {
    var upper = game.CreateSprite(goreUpperTexture);
    var lower = game.CreateSprite(goreLowerTexture);
    upper.Scale(0.18); lower.Scale(0.18);
    upper.CenterOrigin(); lower.CenterOrigin();
    upper.Layer = 8; lower.Layer = 8;
    upper.Visible = false; lower.Visible = false;
    gore.push({ upper: upper, lower: lower, active: false, x: 0, y: 0, vx: 0, vy: 0, age: 0 });
}

var score = 0;
var animationTime = 0;
var fpsTime = 0;
var fpsFrames = 0;
function resetZombie(z, y) {
    z.x = 215 + Math.random() * 370;
    z.y = (y === undefined) ? -80 - Math.random() * 280 : y;
    z.speed = 105 + Math.random() * 85;
    z.sprite.X = z.x; z.sprite.Y = z.y;
}

function hit(a, b) {
    return Math.abs(a.X - b.x) < 42 && Math.abs(a.Y - b.y) < 54;
}

function burstZombie(x, y) {
    // Reuse a small effect pool so collisions do not create sprites every frame.
    var piece = null;
    for (var i = 0; i < gore.length; i++) {
        if (!gore[i].active) { piece = gore[i]; break; }
    }
    if (piece === null) piece = gore[0];
    piece.active = true; piece.x = x; piece.y = y; piece.age = 0;
    piece.vx = (Math.random() - 0.5) * 240; piece.vy = -190;
    piece.upper.X = x; piece.upper.Y = y - 8;
    piece.lower.X = x; piece.lower.Y = y + 10;
    piece.upper.Rotation = 0; piece.lower.Rotation = 0;
    piece.upper.Visible = true; piece.lower.Visible = true;
}

function Update(dt) {
    // Clamp long frames so a paused window cannot jump the simulation forward.
    if (dt > 0.1) dt = 0.1;
    fpsTime += dt; fpsFrames++;
    if (fpsTime >= 0.5) {
        fpsLabel.SetText("FPS: " + Math.round(fpsFrames / fpsTime));
        fpsTime = 0; fpsFrames = 0;
    }
    animationTime += dt;
    var walkFrame = Math.floor(animationTime / 0.12) % 4;
    var roadSpeed = 250;
    roadA.Y += roadSpeed * dt; roadB.Y += roadSpeed * dt;
    if (roadA.Y >= 602) roadA.Y = roadB.Y - 602;
    if (roadB.Y >= 602) roadB.Y = roadA.Y - 602;

    var steer = 300 * dt;
    if (game.IsKeyDown("Left")) car.X -= steer;
    if (game.IsKeyDown("Right")) car.X += steer;
    if (game.IsKeyDown("Up")) car.Y -= steer;
    if (game.IsKeyDown("Down")) car.Y += steer;
    if (car.X < 215) car.X = 215;
    if (car.X > 585) car.X = 585;
    if (car.Y < 330) car.Y = 330;
    if (car.Y > 545) car.Y = 545;

    for (var i = 0; i < zombies.length; i++) {
        var z = zombies[i];
        z.sprite.Texture = walkFrames[walkFrame];
        z.y += z.speed * dt;
        z.sprite.X = z.x; z.sprite.Y = z.y;
        if (hit(car, z)) {
            score += 100;
            scoreLabel.SetText("SCORE: " + score);
            crushSound.Play();
            burstZombie(z.x, z.y);
            resetZombie(z);
        } else if (z.y > 680) {
            resetZombie(z);
        }
    }

    for (var j = 0; j < gore.length; j++) {
        var p = gore[j];
        if (!p.active) continue;
        p.age += dt; p.vy += 430 * dt; p.x += p.vx * dt; p.y += p.vy * dt;
        p.upper.X = p.x - p.vx * 0.02; p.upper.Y = p.y - 12;
        p.lower.X = p.x + p.vx * 0.02; p.lower.Y = p.y + 14;
        p.upper.Rotation -= dt * 7; p.lower.Rotation += dt * 6;
        p.upper.Alpha = Math.max(0, 255 - p.age * 260);
        p.lower.Alpha = p.upper.Alpha;
        if (p.age > 0.95) { p.active = false; p.upper.Visible = false; p.lower.Visible = false; }
    }
}

game.OnUpdate = Update;
form.Show();
wso.Run();
