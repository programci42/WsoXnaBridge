using System.Runtime.InteropServices;
using Microsoft.Xna.Framework.Graphics;

namespace WsoXnaBridge
{
    [ComVisible(true)]
    [Guid("A1F2E3D4-1111-4222-8333-444455556666")]
    [ProgId("WsoXnaBridge.Texture")]
    public class GameTexture
    {
        internal Texture2D Native { get; private set; }

        internal GameTexture(Texture2D native)
        {
            Native = native;
        }

        public int Width { get { return Native.Width; } }
        public int Height { get { return Native.Height; } }

        internal void Dispose()
        {
            if (Native != null && !Native.IsDisposed) Native.Dispose();
        }
    }
}
