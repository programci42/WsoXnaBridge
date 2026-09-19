using System;
using System.Runtime.InteropServices;

namespace WsoXnaBridge
{
    [ComVisible(true)]
    [Guid("B2A3C4D5-2222-4333-8444-555566667777")]
    [ProgId("WsoXnaBridge.Sprite")]
    public class Sprite
    {
        private readonly Renderer owner;
        private GameTexture texture;

        private string fontFamily;
        private float fontSize;

        internal Sprite(Renderer owner, GameTexture texture)
        {
            this.owner = owner;
            this.texture = texture;
            ScaleX = 1.0;
            ScaleY = 1.0;
            Visible = true;
            Color = 0xFFFFFF;
            Alpha = 255;
        }

        public double X { get; set; }
        public double Y { get; set; }
        public double Rotation { get; set; }
        public double ScaleX { get; set; }
        public double ScaleY { get; set; }
        public double OriginX { get; set; }
        public double OriginY { get; set; }
        public double Layer { get; set; }
        public bool Visible { get; set; }

        // 0xRRGGBB
        public int Color { get; set; }

        // 0-255
        public int Alpha { get; set; }

        // Sprite-sheet slicing - the script-side equivalent of XNA's Rectangle
        // sourceRectangle parameter: give 4 plain numbers instead of a Rectangle object.
        public bool HasSourceRect { get; private set; }
        public double SourceX { get; private set; }
        public double SourceY { get; private set; }
        public double SourceWidth { get; private set; }
        public double SourceHeight { get; private set; }

        public void SetSourceRect(double x, double y, double width, double height)
        {
            SourceX = x;
            SourceY = y;
            SourceWidth = width;
            SourceHeight = height;
            HasSourceRect = true;
        }

        public void ClearSourceRect()
        {
            HasSourceRect = false;
        }

        public object Texture
        {
            get { return texture; }
            set { texture = (GameTexture)value; }
        }

        public void Scale(double uniform)
        {
            ScaleX = uniform;
            ScaleY = uniform;
        }

        public void CenterOrigin()
        {
            if (texture != null)
            {
                OriginX = texture.Width / 2.0;
                OriginY = texture.Height / 2.0;
            }
        }

        public void Destroy()
        {
            if (owner != null) owner.RemoveSprite(this);
        }

        internal GameTexture GetTexture() { return texture; }

        // Marks this sprite as text-backed and stores the font info so SetText can re-render it.
        internal void InitTextSprite(string family, float size)
        {
            fontFamily = family;
            fontSize = size;
        }

        public void SetText(string newText)
        {
            if (fontFamily == null)
                throw new InvalidOperationException("SetText can only be called on a sprite created via CreateText().");

            GameTexture oldTexture = texture;
            texture = owner.RenderTextToTexture(newText, fontFamily, fontSize);
            if (oldTexture != null) oldTexture.Dispose();
        }

        internal Microsoft.Xna.Framework.Color ToXnaColor()
        {
            int c = Color;
            byte r = (byte)((c >> 16) & 0xFF);
            byte g = (byte)((c >> 8) & 0xFF);
            byte b = (byte)(c & 0xFF);
            byte a = (byte)Math.Max(0, Math.Min(255, Alpha));
            return new Microsoft.Xna.Framework.Color(r, g, b, a);
        }
    }
}
