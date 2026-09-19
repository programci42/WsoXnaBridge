using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using Microsoft.Xna.Framework.Graphics;
using XnaColor = Microsoft.Xna.Framework.Color;

namespace WsoXnaBridge
{
    // XNA's SpriteFont needs the Content Pipeline to compile a .spritefont file,
    // which isn't practical to trigger from a script at runtime. Instead we
    // rasterize text with GDI+ (System.Drawing, using any installed Windows
    // font, no content build step) and upload the result as a normal Texture2D
    // that gets drawn like any other sprite.
    internal static class TextRenderer
    {
        public static GameTexture RenderTextToTexture(GraphicsDevice device, string text, string fontFamily, float fontSize)
        {
            if (string.IsNullOrEmpty(text)) text = " ";

            using (Font font = new Font(fontFamily, fontSize, GraphicsUnit.Pixel))
            using (Bitmap measureBmp = new Bitmap(1, 1))
            using (Graphics measureG = Graphics.FromImage(measureBmp))
            {
                SizeF size = measureG.MeasureString(text, font);
                int w = Math.Max(1, (int)Math.Ceiling(size.Width));
                int h = Math.Max(1, (int)Math.Ceiling(size.Height));

                using (Bitmap bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb))
                {
                    using (Graphics g = Graphics.FromImage(bmp))
                    {
                        g.Clear(Color.Transparent);
                        g.TextRenderingHint = System.Drawing.Text.TextRenderingHint.AntiAliasGridFit;
                        using (Brush brush = new SolidBrush(Color.White))
                        {
                            g.DrawString(text, font, brush, 0, 0);
                        }
                    }

                    Texture2D tex = BitmapToTexture(device, bmp);
                    return new GameTexture(tex);
                }
            }
        }

        private static Texture2D BitmapToTexture(GraphicsDevice device, Bitmap bmp)
        {
            Rectangle rect = new Rectangle(0, 0, bmp.Width, bmp.Height);
            BitmapData data = bmp.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            try
            {
                int byteCount = data.Stride * bmp.Height;
                byte[] buffer = new byte[byteCount];
                Marshal.Copy(data.Scan0, buffer, 0, byteCount);

                XnaColor[] pixels = new XnaColor[bmp.Width * bmp.Height];
                for (int y = 0; y < bmp.Height; y++)
                {
                    int rowStart = y * data.Stride;
                    for (int x = 0; x < bmp.Width; x++)
                    {
                        int idx = rowStart + x * 4;
                        byte b = buffer[idx + 0];
                        byte g = buffer[idx + 1];
                        byte r = buffer[idx + 2];
                        byte a = buffer[idx + 3];
                        pixels[y * bmp.Width + x] = new XnaColor(r, g, b, a);
                    }
                }

                Texture2D tex = new Texture2D(device, bmp.Width, bmp.Height);
                tex.SetData(pixels);
                return tex;
            }
            finally
            {
                bmp.UnlockBits(data);
            }
        }
    }
}
