// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Alloy {
	public class AlloyTextureProcessor : AssetPostprocessor
	{
		private static Dictionary<string, AlloyTextureImportSettings> s_settings;

		public static void ApplyTextureSettingsOnImport(string path, AlloyTextureImportSettings settings)
		{
			if (s_settings == null) {
				s_settings = new Dictionary<string, AlloyTextureImportSettings>();
			}

			s_settings.Add(path, settings);
		}

		private void OnPreprocessTexture()
		{
			// Check if we have any saved settings to look up and apply to the new texture.
			if (s_settings != null 
			    && s_settings.Count != 0 
			    && s_settings.ContainsKey(assetPath)) {
				var curSetting = s_settings[assetPath];
				
				if (curSetting != null) {
					s_settings.Remove(assetPath);

					var texImporter = assetImporter as TextureImporter;
					texImporter.textureType = TextureImporterType.Advanced;
					texImporter.filterMode = curSetting.FilterMode;
					texImporter.mipmapEnabled = curSetting.MipEnabled;
					texImporter.textureFormat = curSetting.TextureImporterFormat;
					texImporter.anisoLevel = curSetting.AnisoLevel;
					texImporter.wrapMode = curSetting.WrapMode;
					texImporter.linearTexture = curSetting.IsLinear;
					texImporter.mipmapFilter = TextureImporterMipFilter.BoxFilter;
					texImporter.maxTextureSize = curSetting.MaxSize;
				}
			}
		}
	}
}
