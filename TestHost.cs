using System;
using System.IO;
using System.Windows.Forms;

namespace WsoXnaBridge
{
    public static class TestHost
    {
        [STAThread]
        public static void Main()
        {
            Form form = new Form();
            form.Text = "Standalone Renderer Test";
            form.ClientSize = new System.Drawing.Size(440, 440);

            Renderer r = new Renderer();
            r.Dock = DockStyle.Fill;
            form.Controls.Add(r);
            form.Show();

            string baseDir = AppDomain.CurrentDomain.BaseDirectory;
            object sheet = r.LoadTexture(Path.Combine(baseDir, "spritesheet.png"));
            Sprite anim = (Sprite)r.CreateSprite(sheet);
            anim.X = 100; anim.Y = 150;
            anim.SetSourceRect(0, 0, 64, 64);
            anim.CenterOrigin();

            Sprite label = (Sprite)r.CreateText("Test 123", "Arial", 22);
            label.X = 20; label.Y = 20;

            GameSound ding = (GameSound)r.LoadSound(Path.Combine(baseDir, "ding.wav"));
            ding.Play();

            MessageBox.Show("Standalone test OK so far (before Application.Run)");

            Application.Run(form);
        }
    }
}
