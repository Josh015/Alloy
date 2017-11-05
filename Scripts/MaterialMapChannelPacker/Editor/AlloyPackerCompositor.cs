// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/
using System.Linq;
using UnityEngine;

namespace Alloy {
    public struct AlloyTextureColorCache {
        public bool NativeSize;
        public bool EmptyTexture;


        public Color[] Values;
        public float[] ValueChannelR;
        public float[] ValueChannelG;
        public float[] ValueChannelB;
        public float[] ValueChannelA;

        public float[] ActiveChannel;
        
        private int m_texWidth;
        private int m_texHeight;

        public AlloyTextureColorCache(Texture2D texture, Texture2D target) {
            if (texture == null) {
                EmptyTexture = true;
                m_texWidth = 0;
                m_texHeight = 0;
                Values = null;
                ValueChannelR = null;
                ValueChannelG = null;
                ValueChannelB = null;
                ValueChannelA = null;
                NativeSize = false;
            }
            else {
                Values = texture.GetPixels();
                m_texWidth = texture.width;
                m_texHeight = texture.height;
                EmptyTexture = false;
                NativeSize = texture.width == target.width && texture.height == target.height;


                ValueChannelR = new float[Values.Length];
                ValueChannelG = new float[Values.Length];
                ValueChannelB = new float[Values.Length];
                ValueChannelA = new float[Values.Length];

                for (int i = 0; i < Values.Length; ++i) {
                    ValueChannelR[i] = Values[i].r;
                    ValueChannelG[i] = Values[i].g;
                    ValueChannelB[i] = Values[i].b;
                    ValueChannelA[i] = Values[i].a;
                }
            }

            ActiveChannel = null;
        }


        public void SetActiveChannel(int channel) {
            switch (channel) {
                case 0:
                    ActiveChannel = ValueChannelR;
                    break;

                case 1:
                    ActiveChannel = ValueChannelG;
                    break;

                case 2:
                    ActiveChannel = ValueChannelB;
                    break;

                case 3:
                    ActiveChannel = ValueChannelA;
                    break;
            }
        }

        public float GetChannelBilinear(float u, float v, int mipLevel, float rangeX, float rangeY) {

            if (mipLevel == 0) {
                u = Mathf.Clamp01(u);
                v = Mathf.Clamp01(v);

                float uScaled = u * (m_texWidth - 1);
                float vScaled = v * (m_texHeight - 1);
                
                int left = Mathf.FloorToInt(uScaled);
                int bottom = Mathf.FloorToInt(vScaled);
            
                int right = Mathf.CeilToInt(uScaled);
                int top = Mathf.CeilToInt(vScaled);

                float lbVal = ActiveChannel[left + bottom * m_texWidth];
                float rbVal = ActiveChannel[right + bottom * m_texWidth];

                float luVal = ActiveChannel[left + top * m_texWidth];
                float ruVal = ActiveChannel[right + top * m_texWidth];

                float uFrac = uScaled - Mathf.Floor(uScaled);
                float vFrac = vScaled - Mathf.Floor(vScaled);

                float lrBottom = Mathf.LerpUnclamped(lbVal, rbVal, uFrac);
                float lrUp = Mathf.LerpUnclamped(luVal, ruVal, uFrac);

                return Mathf.Lerp(lrBottom, lrUp, vFrac);
            }

            float value = 0.0f;
            // Averages the result over the area within the 'pixel' for this mip level
            // this is similar, but not quite exactly the same as trilinear filtering.
            for (int i = -mipLevel; i < mipLevel; ++i) {
                for (int j = -mipLevel; j < mipLevel; ++j) {
                    float um = u + (i * rangeX);
                    float vm = v - (j * rangeY);
                    value += GetChannelBilinear(um, vm, 0, rangeX, rangeY);
                }
            }
            int t = mipLevel * 2;
            value /= t * t;

            return value;
        }

        public Vector3 GetPixelNormal(float u, float v, int mipLevel, float rangeX, float rangeY) {
            if (mipLevel == 0) {
                u = Mathf.Clamp01(u);
                v = Mathf.Clamp01(v);

                float uScaled = u * (m_texWidth - 1);
                float vScaled = v * (m_texHeight - 1);

                int left = Mathf.FloorToInt(uScaled);
                int bottom = Mathf.FloorToInt(vScaled);

                int right = Mathf.CeilToInt(uScaled);
                int top = Mathf.CeilToInt(vScaled);

                Color lbVal = Values[left + bottom * m_texWidth];
                Color rbVal = Values[right + bottom * m_texWidth];

                Color luVal = Values[left + top * m_texWidth];
                Color ruVal = Values[right + top * m_texWidth];

                float uFrac = uScaled - Mathf.Floor(uScaled);
                float vFrac = vScaled - Mathf.Floor(vScaled);

                float rLerp = Mathf.LerpUnclamped(Mathf.LerpUnclamped(lbVal.r, rbVal.r, uFrac), Mathf.LerpUnclamped(luVal.r, ruVal.r, uFrac), vFrac);
                float gLerp = Mathf.LerpUnclamped(Mathf.LerpUnclamped(lbVal.g, rbVal.g, uFrac), Mathf.LerpUnclamped(luVal.g, ruVal.g, uFrac), vFrac);
                float bLerp = Mathf.LerpUnclamped(Mathf.LerpUnclamped(lbVal.b, rbVal.b, uFrac), Mathf.LerpUnclamped(luVal.b, ruVal.b, uFrac), vFrac);

                return new Vector3(rLerp, gLerp, bLerp);
            }

            Vector3 value = Vector3.zero;
            // Averages the result over the area within the 'pixel' for this mip level
            // this is similar, but not quite exactly the same as trilinear filtering.
            for (int i = -mipLevel; i < mipLevel; ++i) {
                for (int j = -mipLevel; j < mipLevel; ++j) {
                    float um = u + (i * rangeX);
                    float vm = v - (j * rangeY);
                    value += GetPixelNormal(um, vm, 0, rangeX, rangeY);
                }
            }

            int t = mipLevel * 2;
            value /= t * t;

            return value;
        }
    }

    public static class AlloyPackerCompositor {
        public static void CompositeMips(Texture2D target, AlloyCustomImportObject source,
            AlloyTextureColorCache[] mapCache, AlloyTextureColorCache normalCache, int mipLevel) {


            // Basically a 1:1 port of the original shader
            // The only point of major difference is the filtering method used; which is a fraction simpler.

            // This was disabled, since it appears GetPixels results don't appear to be affected by Unity's messing with Linear inputs; the same way they do at runtime. Re-enable if you like.

            int w = Mathf.Max(2, target.width >> mipLevel);
            int h = Mathf.Max(2, target.height >> mipLevel);

            var colors = new Color[w * h];


            float rangeX = (1.0f / (mipLevel + 1)) / target.width;
            float rangeY = (1.0f / (mipLevel + 1)) / target.height;

            UnityEngine.Profiling.Profiler.BeginSample("Composite mips");
            for (int channelIndex = 0; channelIndex < source.PackMode.Channels.Count; channelIndex++) {
                var channel = source.PackMode.Channels[channelIndex];
                var inIndices = channel.InputIndices.ToArray();
                var outIndices = channel.OutputIndices.ToArray();
                bool hasInputs = inIndices.Length > 0;

                for (int i = 0; i < outIndices.Length; ++i) {
                    int storeIndex = outIndices[i];
                    var tex = mapCache[storeIndex];
                    var channelVal = source.ChannelValues[storeIndex];

                    if (hasInputs) {
                        int readIndex = inIndices[Mathf.Min(i, inIndices.Length - 1)];

                        tex.SetActiveChannel(readIndex);
                    }
                    
                    bool doInvert = source.DoInvert[storeIndex];
                    bool doNormal = channel.UseNormals && !normalCache.EmptyTexture;
                    bool doNative = hasInputs && tex.NativeSize && mipLevel == 0;

                    UnityEngine.Profiling.Profiler.BeginSample("Blit");
                    for (int x = 0; x < w; ++x) {
                        for (int y = 0; y < h; ++y) {
                            var pixelIndex = x + y * w;
                            var input = 0.0f;

                            if (!hasInputs || tex.EmptyTexture) {
                                input = channelVal;
                            }
                            else if (doNative) {
                                input = tex.ActiveChannel[pixelIndex];
                            }
                            else {
                                input = tex.GetChannelBilinear((float)x / (w - 1), (float)y / (h - 1), mipLevel, rangeX, rangeY);
                            }

                            if (doInvert) {
                                input = 1.0f - input;
                            }

                            if (doNormal) {
                                Vector3 normal;

                                if (normalCache.NativeSize && mipLevel == 0) {
                                    normal = (Vector4)normalCache.Values[pixelIndex];
                                }
                                else {
                                    normal = normalCache.GetPixelNormal((float)x / (w - 1), (float)y / (h - 1), mipLevel, rangeX,
                                        rangeY);
                                }

                                normal.x = (normal.x * 2.0f) - 1.0f;
                                normal.y = (normal.y * 2.0f) - 1.0f;
                                normal.z = (normal.z * 2.0f) - 1.0f;

                                // Specular AA for Beckmann roughness.
                                // cf http://www.frostbite.com/wp-content/uploads/2014/11/course_notes_moving_frostbite_to_pbr.pdf pg92
                                var variance = 0.0f;
                                var avgNormalLength = normal.magnitude;
                                var applyAA = avgNormalLength < 1.0f;

                                if (applyAA) {
                                    float avgNormLen2 = avgNormalLength * avgNormalLength;
                                    float kappa = (3.0f * avgNormalLength - avgNormalLength * avgNormLen2) / (1.0f - avgNormLen2);
                                    
                                    variance = Mathf.Clamp01(1.0f / (2.0f * kappa));// - source.VarianceBias);
                                }

                                if (channel.OutputVariance) {
                                    input = variance;
                                } 
                                else if (channel.RoughnessCorrect && applyAA) {
                                    float a = input * input;
                                    a = Mathf.Sqrt(Mathf.Clamp01(a * a + variance));
                                    input = Mathf.Sqrt(a);
                                }
                            }

                            switch (storeIndex) {
                                case 0: colors[pixelIndex].r = input; break;
                                case 1: colors[pixelIndex].g = input; break;
                                case 2: colors[pixelIndex].b = input; break;
                                case 3: colors[pixelIndex].a = input; break;
                            }
                        }
                    }

                    UnityEngine.Profiling.Profiler.EndSample();
                }
            }

            UnityEngine.Profiling.Profiler.BeginSample("Set pixels");
            target.SetPixels(colors, mipLevel);
            UnityEngine.Profiling.Profiler.EndSample();

            UnityEngine.Profiling.Profiler.EndSample();
        }
    }
}
