// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEditor;
using UnityEngine;
using System.IO;

namespace Alloy {
	public static class AlloyTextureUtility {		
		public static void GetTextureImportSettings(Texture2D tex, out AlloyTextureImportSettings settings)
		{
			settings = new AlloyTextureImportSettings();
			
			if (tex != null) {
				var path = AssetDatabase.GetAssetPath(tex);
				var importer = AssetImporter.GetAtPath(path) as TextureImporter;
				
				if (importer != null) {
					settings.TextureImporterType = importer.textureType;
					settings.FilterMode = importer.filterMode;
					settings.WrapMode = importer.wrapMode;
					settings.AnisoLevel = importer.anisoLevel;
					settings.TextureImporterFormat = importer.textureFormat;
					settings.IsLinear = importer.linearTexture;
					settings.IsReadWriteEnabled = importer.isReadable;
				}
			} 
		}
		
		public static void SetTextureImportSettings(Texture2D tex, AlloyTextureImportSettings settings)
		{
			if (tex != null) {
				var path = AssetDatabase.GetAssetPath(tex);
				var importer = AssetImporter.GetAtPath(path) as TextureImporter;
				
				if (importer != null && settings != null) {
					importer.textureType = settings.TextureImporterType;
					importer.filterMode = settings.FilterMode; 
					importer.wrapMode = settings.WrapMode;
					importer.anisoLevel = settings.AnisoLevel;
					importer.textureFormat = settings.TextureImporterFormat;
					importer.linearTexture = settings.IsLinear;
					importer.isReadable = settings.IsReadWriteEnabled;
					AssetDatabase.ImportAsset(path);
				} else {
					Debug.LogWarning("Texture importer parameters were null");
				}
			} 
		}
		
		public static Texture2D SaveTexture(string path, Texture2D texture, AlloyTextureImportSettings importSettings, bool overwrite = true)
		{
			if (Path.HasExtension(path)) {
				path = Path.ChangeExtension(path,".png");
			} else {
				path += ".png";
			}

			if (!overwrite) {
				path = AssetDatabase.GenerateUniqueAssetPath(path);
			}

			AlloyTextureProcessor.ApplyTextureSettingsOnImport(path, importSettings);

			var png = texture.EncodeToPNG();
			
			File.WriteAllBytes(path, png);
			AssetDatabase.Refresh();
			
			var tex = AssetDatabase.LoadAssetAtPath(path, typeof (Texture2D)) as Texture2D;
			Selection.activeObject = tex;
			
			return tex;
		}
	}
}