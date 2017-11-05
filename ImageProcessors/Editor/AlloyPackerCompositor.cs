// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEngine;

namespace Alloy
{
	public class AlloyPackerCompositor
	{
		//[MethodImpl(MethodImplOptions.AggressiveInlining)]
		private static float GetChannel(TextureValueChannelMode mode, float channelValue, Texture2D tex, float u, float v, int miplevel, int w, int h, float rangeX, float rangeY) {

			if (mode != TextureValueChannelMode.Texture)
				return channelValue;
			

			if (tex == null)
				return 0f;


			if (miplevel == 0) {
				return tex.GetPixelBilinear(u, v).r;
			}

			// Averages the result over the area within the 'pixel' for this mip level
			// this is similar, but not quite exactly the same as trilinear filtering.
			float value = 0.0f;


			for (int x = -miplevel; x < miplevel; ++x) {
				for (int y = -miplevel; y < miplevel; ++y) {
					float um = u + (x * rangeX);
					float vm = v - (y * rangeY);
					value += tex.GetPixelBilinear(um, vm).r;
				}
			}

			int t = miplevel * 2;
			value /= t * t;

			return value;
		}


		private static Vector4 GetChannels(Texture2D tex, float u, float v, int miplevel, int w, int h, float rangeX, float rangeY) {
			if (tex == null)
				return Vector4.zero;


			if (miplevel == 0) {
				return tex.GetPixelBilinear(u, v);
			}

			// Averages the result over the area within the 'pixel' for this mip level
			// this is similar, but not quite exactly the same as trilinear filtering.
			Vector4 value = Vector4.zero;

			for (int x = -miplevel; x < miplevel; x++) {
				for (int y = -miplevel; y < miplevel; y++) {
					float um = u + (x * rangeX);
					float vm = v - (y * rangeY);

					value += (Vector4) tex.GetPixelBilinear(um, vm);
				}
			}

			int t = miplevel * 2;
			value /= t * t;

			return value;
		}

		public static void CompositeMips(Texture2D master, int mipLevel, Texture2D[] blitTextures, Vector4 channelValues,
		                                 TextureValueChannelMode[] modes, bool shouldOutputVariance = false,
		                                 float varianceBias = 0f, Texture2D normalMap = null) {
			// Basically a 1:1 port of the original shader
			// The only point of major difference is the filtering method used; which is a fraction simpler.

			// This was disabled, since it appears GetPixels results don't appear to be affected by Unity's messing with Linear inputs; the same way they do at runtime. Re-enable if you like.

			int w = Mathf.Max(1, master.width >> mipLevel);
			int h = Mathf.Max(1, master.height >> mipLevel);

			var colors = new Color[w * h];

			float offX = 0.5f / w; // Half a pixel
			float offY = 0.5f / h;

			float rangeX = (1.0f / (mipLevel + 1)) / w;
			float rangeY = (1.0f / (mipLevel + 1)) / h;

			
			for (int x = 0; x < w; x++) {
				for (int y = 0; y < h; y++) {
					float u = (float) x / w + offX;
					float v = (float) y / h + offY;

					var color = new Vector4(
						GetChannel(modes[0], channelValues.x, blitTextures[0], u, v, mipLevel, w, h, rangeX, rangeY),
						GetChannel(modes[1], channelValues.y, blitTextures[1], u, v, mipLevel, w, h, rangeX, rangeY),
						GetChannel(modes[2], channelValues.z, blitTextures[2], u, v, mipLevel, w, h, rangeX, rangeY),
						GetChannel(modes[3], channelValues.w, blitTextures[3], u, v, mipLevel, w, h, rangeX, rangeY)
						);

					if (normalMap != null) {
						Vector4 normal = GetChannels(normalMap, u, v, mipLevel, w, h, rangeX, rangeY);
						normal.x = (normal.x * 2.0f) - 1.0f;
						normal.y = (normal.y * 2.0f) - 1.0f;
						normal.z = (normal.z * 2.0f) - 1.0f;

						float na = ((Vector3) normal).magnitude;
						float variance = Mathf.Clamp01(((1.0f - na) / na) - varianceBias);

						if (shouldOutputVariance) {
							color.w = variance;
						}
						else {
							// Convert roughness to specular power.
							float sp = Mathf.Pow(2f, (1f - color.w) * 11f);

							// Apply Toksvig factor
							sp = sp / (1.0f + variance * sp);

							// Output
							color.w = 1f - Mathf.Clamp01(Mathf.Log(sp, 2f) / 11f);
						}
					}


					int idx = y * w + x; 

					colors[idx] = color;
				}
			}

			master.SetPixels(colors, mipLevel);
		}
	}
}