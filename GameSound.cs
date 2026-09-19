using System.Runtime.InteropServices;
using Microsoft.Xna.Framework.Audio;

namespace WsoXnaBridge
{
    [ComVisible(true)]
    [Guid("C3B4D5E6-3333-4444-8555-666677778888")]
    [ProgId("WsoXnaBridge.Sound")]
    public class GameSound
    {
        private readonly SoundEffect effect;
        private SoundEffectInstance loopInstance;

        internal GameSound(SoundEffect effect)
        {
            this.effect = effect;
        }

        public void Play()
        {
            effect.Play();
        }

        public void Play(double volume)
        {
            effect.Play((float)volume, 0f, 0f);
        }

        public void PlayLooped()
        {
            StopLoop();
            loopInstance = effect.CreateInstance();
            loopInstance.IsLooped = true;
            loopInstance.Play();
        }

        public void StopLoop()
        {
            if (loopInstance != null)
            {
                loopInstance.Stop();
                loopInstance.Dispose();
                loopInstance = null;
            }
        }

        public double DurationSeconds
        {
            get { return effect.Duration.TotalSeconds; }
        }
    }
}
