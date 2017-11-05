// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEngine;

namespace Alloy
{
	public class AlloyTextureReader
	{
		public static Color[] GetPixels(Texture2D texture) {
			var readTex = GetReadable(texture, false);

			var pixels = readTex.GetPixels();
			Object.DestroyImmediate(readTex);

			return pixels;
		}

		public static Texture2D GetReadable(Texture texture, bool normalMap) {
			if (texture == null) {
				return null;
			}

			var render = new RenderTexture(texture.width, texture.height, 0, RenderTextureFormat.ARGB32);


			Graphics.Blit(texture, render, normalMap ? NormalMaterial : PassthroughMaterial);

			var readTex = new Texture2D(texture.width, texture.height, TextureFormat.ARGB32, false, true);

			Graphics.SetRenderTarget(render);
			readTex.ReadPixels(new Rect(0, 0, texture.width, texture.height), 0, 0, false);
			Graphics.SetRenderTarget(null);

			Object.DestroyImmediate(render);

			readTex.hideFlags = HideFlags.HideAndDontSave;

			return readTex;
		}

		private static Material s_passthroughMat;

		protected static Material PassthroughMaterial {
			get {
				if (s_passthroughMat == null) {
					s_passthroughMat = new Material(Shader.Find("Hidden/AlloyPassthroughBlit")) {hideFlags = HideFlags.HideAndDontSave};
				}

				return s_passthroughMat;
			}
		}

		private static Material s_normMat;

		protected static Material NormalMaterial {
			get {
				if (s_normMat == null) {
					s_normMat = new Material(Shader.Find("Hidden/AlloyNormalBlit"));

					s_normMat.hideFlags = HideFlags.HideAndDontSave;
				}

				return s_normMat;
			}
		}
	}
}