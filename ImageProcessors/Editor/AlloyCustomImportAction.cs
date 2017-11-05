// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using System;
using System.Linq;
using System.IO;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

namespace Alloy
{
	internal class AlloyCustomImportAction : AssetPostprocessor
	{
		public const int DefaultOutputWidth = 32,
		                 DefaultOutputHeight = 32,
		                 DefaultOutputMipmapCount = 1;

		public const string PackedMaterialMapSuffix = "_AlloyPM";
		public const string DetailMaterialMapSuffix = "_AlloyDM";


		private delegate void OnAlloyImportFunc(AlloyCustomImportObject settings, Texture2D texture, string path);


		static void OnPostprocessAllAssets (string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPath)
		{
			foreach (var asset in importedAssets) {
				if (!asset.EndsWith("_AlloyPM.asset") && !asset.EndsWith("_AlloyDM.asset")) {
					continue;
				}

				if (File.Exists(asset.Replace(".asset", ".png"))) {
					continue;
				}
				
				var settings = AssetDatabase.LoadAssetAtPath(asset, typeof (AlloyCustomImportObject)) as AlloyCustomImportObject;

				if (settings != null) {
					settings.GenerateMap();
				}
			}
		}
	

		private void OnAlloyImport(Texture2D texture, OnAlloyImportFunc onImport) {
// Check to see if this is an Alloy material that we need to edit.

			if (assetPath.Contains(PackedMaterialMapSuffix)
			    || assetPath.Contains(DetailMaterialMapSuffix)) {
				//Debug.Log("Processing Alloy Information for " + assetPath);
				// and if we've got saved settings/data for it...
				var path = Path.Combine(Path.GetDirectoryName(assetPath), Path.GetFileNameWithoutExtension(assetPath)) + ".asset";
				
				if (File.Exists(path)) {
					var settings = AssetDatabase.LoadAssetAtPath(path, typeof (AlloyCustomImportObject)) as AlloyCustomImportObject;

					if (settings == null) {
						if (AlloyImporterSupervisor.IsFinalTry)
						{
							Debug.LogError("Packed map settings file is messed up! Contact Alloy support");
							return;
						}

						AlloyImporterSupervisor.OnFailedImport(path);
						return;
					}
					
					for (int i = 0; i < 4; ++i) {
						if (settings.SelectedModes[i] == TextureValueChannelMode.Texture && settings.GetTexture(i) == null) {
							if (AlloyImporterSupervisor.IsFinalTry)
							{
								Debug.LogError("Packed map texture input can't be loaded!");
								return;
							}

							AlloyImporterSupervisor.OnFailedImport(path);
							return;
						}
					}

					if (!string.IsNullOrEmpty(settings.NormalGUID) && settings.NormalMapTexture == null) {
						if (AlloyImporterSupervisor.IsFinalTry)
						{
							Debug.LogError("Packed map texture input can't be loaded!");
							return;
						}

						AlloyImporterSupervisor.OnFailedImport(path);
						return;
					}

					onImport(settings, texture, path);
				} else {
					Debug.LogError("Found a _AlloyPM file, but no post-processing data for it! Conact Alloy support");
					Selection.activeObject = texture;
				}
			}
		}

		private void ApplyImportSettings(AlloyCustomImportObject settings, Texture2D texture, string path) {
			var importer = assetImporter as TextureImporter;
			var size = settings.GetOutputSize();

			importer.textureType = TextureImporterType.Advanced;
			importer.linearTexture = true;
			importer.filterMode = FilterMode.Trilinear;

			// NOTE: Left blank, wrapMode will default to 'Repeat', and allow users to change it!
			//importer.wrapMode = TextureWrapMode.Repeat;

			// They need the ability to set this themselves, but we should cap it.
			var nextPowerOfTwo = Mathf.NextPowerOfTwo((int) Mathf.Max(size.x, size.y));

			if (importer.maxTextureSize > nextPowerOfTwo) 
				importer.maxTextureSize = nextPowerOfTwo;

			// Allow setting to uncompressed, else use compressed. Disallows any other format!
			if (importer.textureFormat != TextureImporterFormat.AutomaticTruecolor)
				importer.textureFormat = TextureImporterFormat.AutomaticCompressed;
		}

		private void OnPreprocessTexture() {
			OnAlloyImport(null, ApplyImportSettings);


			HandleAutoRefresh();
		}

		private void HandleAutoRefresh() {
			var paths = AssetDatabase.GetAllAssetPaths();

			var texGUID = AssetDatabase.AssetPathToGUID(assetPath);

			foreach (var path in paths) {
				if (path.EndsWith("_AlloyPM.asset")) {
					var setting = AssetDatabase.LoadAssetAtPath(path, typeof (AlloyCustomImportObject)) as AlloyCustomImportObject;

					
					if (texGUID == setting.NormalGUID || setting.TexturesGUID.Contains(texGUID))
					{
						if (setting.DoAutoRegenerate) {
							AssetDatabase.ImportAsset(path.Replace(".asset", ".png"));
						}
					}
				}
			}
		}

		private void OnPostprocessTexture(Texture2D texture) {
			OnAlloyImport(texture, GeneratePackedMaterialMap);
		}


		// This saves secondary information about the texture, and precomputed levels into a '.asset' file which is a ScriptableObject of type AlloyCustomImportObject
		public static void CreatePostProcessingInformation(string filePath, AlloyCustomImportObject settings) {
			settings.hideFlags = HideFlags.None;

			AssetDatabase.CreateAsset(settings, filePath);
		}

		/// <summary>
		/// Generates the packed material map for an object, moved from MaterialMapChannelPacker.cs to avoid duplication of functionality.
		/// </summary>
		public static void GeneratePackedMaterialMap(AlloyCustomImportObject settings, Texture2D source, string filePath) {
			int mipmapCount = DefaultOutputMipmapCount;

			var textureMipmapCounts = new[] {1.0f, 1.0f, 1.0f, 1.0f};
			bool isEditorInLinearSpace = PlayerSettings.colorSpace != ColorSpace.Gamma;
			Shader.SetGlobalFloat("_EditorIsLinear", isEditorInLinearSpace ? 1.0f : 0.0f);

			Vector2 size = settings.GetOutputSize();
			int width = (int) size.x;
			int height = (int) size.y;

			// Pick output texture dimensions based on the largest input texture.
			for (int i = 0; i < 4; ++i) {
				var texture = settings.GetTexture(i);

				if (settings.SelectedModes[i] == TextureValueChannelMode.Texture && texture != null) {



					int count = GetMipmapCount(texture);
					

					textureMipmapCounts[i] = count;

					
					// So we can accomodate rectangles, if need be.
					mipmapCount = Math.Max(mipmapCount, count);
				}
			}

			bool doMips;

			if (settings.NormalMapTexture != null) {

				var tex = settings.NormalMapTexture;

				var count = GetMipmapCount(tex);

				mipmapCount = Math.Max(mipmapCount, count);


				doMips = true;
			}
			else {
				mipmapCount = 1;
				doMips = false;
			}


			if (source.width != width || source.height != height) {
				source.Resize(width, height);
			}

			if (!Mathf.IsPowerOfTwo(width) || !Mathf.IsPowerOfTwo(height)) {
				Debug.LogWarning(
					"Alloy: Texture resolution is not power of 2; will have issues generating correct mip maps if custom sizing is specified in generated texture platform settings.");
			}

			var readableTextures = new Texture2D[settings.TexturesGUID.Length];

			for (int i = 0; i < settings.TexturesGUID.Length; ++i) {
				readableTextures[i] = AlloyTextureReader.GetReadable(settings.GetTexture(i), false);
			}

			var normal = AlloyTextureReader.GetReadable(settings.NormalMapTexture, true);


			// Use renderer to sample mipmaps.
			for (int mipLevel = 0; mipLevel < mipmapCount; mipLevel++) {
				// CPU Method - more reliable/consistent across GPUs, but slower.
				EditorUtility.DisplayProgressBar("Calculating Mip Maps...", "MipLevel " + mipLevel, (float) mipLevel / mipmapCount);

				try {
					AlloyPackerCompositor.CompositeMips(
						source,
						mipLevel,
						readableTextures,
						settings.ChannelValues,
						settings.SelectedModes,
						settings.IsDetailMap,
						settings.VarianceBias,
						normal
						);
				}
				finally {
					EditorUtility.ClearProgressBar();
				}
			}

			foreach (var texture in readableTextures) {
				Object.DestroyImmediate(texture);
			}

			Object.DestroyImmediate(normal);

			int maxResolution = 0;

			settings.Width = width;
			settings.Height = height;

			settings.MaxResolution = maxResolution;
			EditorUtility.SetDirty(settings); // Tells Unity to save changes to the settings .asset object on disk

			source.Apply(!doMips, false);
		}

		private static int GetMipmapCount(Texture tex) {
			int count = 1;


			if (tex is Texture2D) {
				count = (tex as Texture2D).mipmapCount;
			}
			else if (tex is RenderTexture) {
				count = (tex as RenderTexture).useMipMap ? Mathf.CeilToInt(Mathf.Log(Mathf.Max(tex.width, tex.height), 2.0f)) + 1 : 1;
			}
			else if (tex is ProceduralTexture) {
				var mat =
					(tex as ProceduralTexture).GetType().GetMethod("GetProceduralMaterial",
					                                               BindingFlags.Instance | BindingFlags.NonPublic).Invoke(tex, null)
					as ProceduralMaterial;

				var imp = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(mat)) as SubstanceImporter;


				count = imp.GetGenerateMipMaps(mat) ? Mathf.CeilToInt(Mathf.Log(Mathf.Max(tex.width, tex.height), 2.0f)) + 1 : 1;
			}


			return count;
		}
	}
}