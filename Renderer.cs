using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Graphics;
using XnaKeys = Microsoft.Xna.Framework.Input.Keys;
using XnaButtonState = Microsoft.Xna.Framework.Input.ButtonState;
using Keyboard = Microsoft.Xna.Framework.Input.Keyboard;
using Mouse = Microsoft.Xna.Framework.Input.Mouse;
using MouseState = Microsoft.Xna.Framework.Input.MouseState;

namespace WsoXnaBridge
{
    [ComVisible(true)]
    [Guid("E3B1A2A0-6E7F-4B7A-9A2D-2E7B6B6A0E10")]
    [ProgId("WsoXnaBridge.Renderer")]
    public class Renderer : UserControl
    {
        private GraphicsDevice device;
        private SpriteBatch spriteBatch;
        private Timer timer;
        private readonly List<Sprite> sprites = new List<Sprite>();
        private readonly Stopwatch clock = new Stopwatch();
        private long lastTicks;
        private object onUpdate;
        private bool updateFailed;

        private static readonly string LogPath = Path.Combine(
            Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "renderer.log");

        private static void Log(string msg)
        {
            try { File.AppendAllText(LogPath, DateTime.Now.ToString("HH:mm:ss.fff") + " " + msg + Environment.NewLine); }
            catch { }
        }

        public Renderer()
        {
            Log("ctor called");
            BackColor = System.Drawing.Color.Black;
            BackgroundColor = 0x6495ED; // cornflower blue, matches XNA's classic default
        }

        // --- Lifecycle -------------------------------------------------

        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            Log("OnHandleCreated, Handle=" + Handle + " ClientSize=" + ClientSize);
            try
            {
                InitializeGraphics();
                Log("InitializeGraphics OK");
            }
            catch (Exception ex)
            {
                Log("InitializeGraphics FAILED: " + ex);
                return;
            }

            clock.Start();
            timer = new Timer();
            timer.Interval = 16;
            timer.Tick += delegate { Tick(); };
            timer.Start();
            Log("Timer started");
        }

        private void InitializeGraphics()
        {
            PresentationParameters pp = new PresentationParameters();
            pp.BackBufferWidth = Math.Max(ClientSize.Width, 1);
            pp.BackBufferHeight = Math.Max(ClientSize.Height, 1);
            pp.DeviceWindowHandle = Handle;
            pp.IsFullScreen = false;
            pp.PresentationInterval = PresentInterval.Immediate;

            device = new GraphicsDevice(GraphicsAdapter.DefaultAdapter, GraphicsProfile.Reach, pp);
            spriteBatch = new SpriteBatch(device);
            Mouse.WindowHandle = Handle;

            // SoundEffect/Audio needs this pumped once per frame when not using
            // the XNA Game class (undocumented-but-required outside Game.Run()).
            FrameworkDispatcher.Update();
        }

        protected override void OnResize(EventArgs e)
        {
            base.OnResize(e);
            if (device != null && !device.IsDisposed && ClientSize.Width > 0 && ClientSize.Height > 0)
            {
                PresentationParameters pp = device.PresentationParameters;
                pp.BackBufferWidth = ClientSize.Width;
                pp.BackBufferHeight = ClientSize.Height;
                device.Reset(pp);
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (timer != null) timer.Dispose();
                if (spriteBatch != null) spriteBatch.Dispose();
                if (device != null) device.Dispose();
            }
            base.Dispose(disposing);
        }

        // --- Script-facing engine API ------------------------------------

        public int BackgroundColor { get; set; }

        public new int Width { get { return device != null ? device.Viewport.Width : ClientSize.Width; } }
        public new int Height { get { return device != null ? device.Viewport.Height : ClientSize.Height; } }

        public double ElapsedSeconds { get; private set; }
        public double TotalSeconds { get; private set; }

        public int MouseX { get { return Mouse.GetState().X; } }
        public int MouseY { get { return Mouse.GetState().Y; } }

        // Assign a JScript function / VBScript GetRef(...) here; called once per frame as Update(dt)
        public object OnUpdate
        {
            get { return onUpdate; }
            set
            {
                onUpdate = value;
                updateFailed = false;
                Log("OnUpdate set: value=" + (value == null ? "null" : value.ToString()) + " type=" + (value == null ? "n/a" : value.GetType().ToString()));
            }
        }

        public object LoadTexture(string path)
        {
            using (FileStream stream = File.OpenRead(path))
            {
                Texture2D tex = Texture2D.FromStream(device, stream);
                return new GameTexture(tex);
            }
        }

        public object CreateSprite(object texture)
        {
            GameTexture tex = texture as GameTexture;
            Sprite sprite = new Sprite(this, tex);
            sprites.Add(sprite);
            return sprite;
        }

        // Text drawing: XNA's SpriteFont needs the Content Pipeline, which a script
        // can't trigger at runtime. Instead we rasterize text via GDI+ into a normal
        // texture (fontFamily = any installed Windows font name, e.g. "Arial").
        public object CreateText(string text, string fontFamily, double fontSize)
        {
            GameTexture tex = RenderTextToTexture(text, fontFamily, (float)fontSize);
            Sprite sprite = new Sprite(this, tex);
            sprite.InitTextSprite(fontFamily, (float)fontSize);
            sprites.Add(sprite);
            return sprite;
        }

        internal GameTexture RenderTextToTexture(string text, string fontFamily, float fontSize)
        {
            return TextRenderer.RenderTextToTexture(device, text, fontFamily, fontSize);
        }

        // Sound: SoundEffect.FromStream loads a .wav at runtime, no Content Pipeline needed.
        public object LoadSound(string path)
        {
            using (FileStream stream = File.OpenRead(path))
            {
                SoundEffect effect = SoundEffect.FromStream(stream);
                return new GameSound(effect);
            }
        }

        internal void RemoveSprite(Sprite sprite)
        {
            sprites.Remove(sprite);
        }

        public bool IsKeyDown(string keyName)
        {
            XnaKeys key;
            if (Enum.TryParse(keyName, true, out key))
                return Keyboard.GetState().IsKeyDown(key);
            return false;
        }

        public bool IsMouseDown(int button)
        {
            MouseState state = Mouse.GetState();
            if (button == 0) return state.LeftButton == XnaButtonState.Pressed;
            if (button == 1) return state.RightButton == XnaButtonState.Pressed;
            if (button == 2) return state.MiddleButton == XnaButtonState.Pressed;
            return false;
        }

        // --- Frame loop --------------------------------------------------

        private bool loggedFirstTick;
        private bool loggedFirstUpdate;

        private void Tick()
        {
            if (device == null || device.IsDisposed) return;

            long now = clock.ElapsedTicks;
            ElapsedSeconds = (now - lastTicks) / (double)Stopwatch.Frequency;
            lastTicks = now;
            TotalSeconds = clock.Elapsed.TotalSeconds;

            try { FrameworkDispatcher.Update(); } catch { }

            if (onUpdate != null && !updateFailed)
            {
                try
                {
                    onUpdate.GetType().InvokeMember("", BindingFlags.InvokeMethod, null, onUpdate, new object[] { ElapsedSeconds });
                    if (!loggedFirstUpdate) { Log("OnUpdate invoked OK (dt=" + ElapsedSeconds + ")"); loggedFirstUpdate = true; }
                }
                catch (Exception ex)
                {
                    Log("OnUpdate callback FAILED (disabling further calls): " + ex);
                    updateFailed = true;
                }
            }

            try
            {
                byte r = (byte)((BackgroundColor >> 16) & 0xFF);
                byte g = (byte)((BackgroundColor >> 8) & 0xFF);
                byte b = (byte)(BackgroundColor & 0xFF);
                device.Clear(new Color(r, g, b));

                spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.AlphaBlend);
                foreach (Sprite sprite in sprites.OrderBy(s => s.Layer))
                {
                    if (!sprite.Visible) continue;
                    GameTexture tex = sprite.GetTexture();
                    if (tex == null) continue;

                    Rectangle? sourceRect = null;
                    if (sprite.HasSourceRect)
                    {
                        sourceRect = new Rectangle(
                            (int)sprite.SourceX, (int)sprite.SourceY,
                            (int)sprite.SourceWidth, (int)sprite.SourceHeight);
                    }

                    spriteBatch.Draw(
                        tex.Native,
                        new Vector2((float)sprite.X, (float)sprite.Y),
                        sourceRect,
                        sprite.ToXnaColor(),
                        (float)sprite.Rotation,
                        new Vector2((float)sprite.OriginX, (float)sprite.OriginY),
                        new Vector2((float)sprite.ScaleX, (float)sprite.ScaleY),
                        SpriteEffects.None,
                        0f);
                }
                spriteBatch.End();

                device.Present();

                if (!loggedFirstTick) { Log("First tick rendered OK, viewport=" + device.Viewport.Width + "x" + device.Viewport.Height); loggedFirstTick = true; }
            }
            catch (Exception ex)
            {
                if (!loggedFirstTick) { Log("Tick FAILED: " + ex); loggedFirstTick = true; }
            }
        }
    }
}
