var wso = new ActiveXObject("Scripting.WindowSystemObject");
wso.EnableVisualStyles = true;

var form = wso.CreateForm(100, 100, 460, 500);
form.Text = "WSO + XNA - sprite sheet / text / sound testi";
form.ClientWidth = 440;
form.ClientHeight = 440;

var ax = form.CreateActiveXControl(0, 0, 440, 440, "WsoXnaBridge.Renderer");
var engine = ax.Control;

var fso = new ActiveXObject("Scripting.FileSystemObject");
var scriptDir = fso.GetParentFolderName(WScript.ScriptFullName);

// --- 1) Sprite sheet dilimleme (Rectangle'in script karsiligi) ---
var sheet = engine.LoadTexture(scriptDir + "\\spritesheet.png");
var anim = engine.CreateSprite(sheet);
anim.X = 100; anim.Y = 150;
anim.SetSourceRect(0, 0, 64, 64); // ilk kare: x,y,genislik,yukseklik
anim.CenterOrigin();

var frame = 0;
var frameTimer = 0;

// --- 2) Metin cizimi (SpriteFont yerine GDI+ ile runtime texture) ---
var label = engine.CreateText("Sure: 0.0", "Arial", 22);
label.X = 20; label.Y = 20;
label.Color = 0xFFFFFF;

// --- 3) Ses efekti (SoundEffect.FromStream ile runtime WAV yukleme) ---
var ding = engine.LoadSound(scriptDir + "\\ding.wav");
ding.Play(); // basta bir kere calalim (sesin yuklendigini duymak icin)

var soundCooldown = 0;

function Update(dt) {
    // sprite sheet animasyonu: her 0.2 saniyede bir sonraki kareye gec
    frameTimer += dt;
    if (frameTimer > 0.2) {
        frameTimer = 0;
        frame = (frame + 1) % 4;
        anim.SetSourceRect(frame * 64, 0, 64, 64);
    }

    // metni her frame guncelle
    label.SetText("Sure: " + engine.TotalSeconds.toFixed(1));

    // Space tusuna basinca ses cal (cooldown ile ust uste calmayi engelle)
    soundCooldown -= dt;
    if (engine.IsKeyDown("Space") && soundCooldown <= 0) {
        ding.Play();
        soundCooldown = 0.3;
    }
}

engine.OnUpdate = Update;

form.Show();
wso.Run();
