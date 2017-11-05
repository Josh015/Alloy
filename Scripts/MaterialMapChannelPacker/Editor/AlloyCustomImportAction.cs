// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System;
using System.Linq;
using System.IO;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

namespace Alloy {
    public class AlloyCustomImportAction : AssetPostprocessor {
        delegate void OnAlloyImportFunc(AlloyCustomImportObject settings, Texture2D texture, string path);

        public static bool IsAlloyPackedMapPath(string path) {
            path = Path.GetFileNameWithoutExtension(path);
			var definition = AlloyMaterialMapChannelPacker.GlobalDefinition;

			//Alloy not imported yet -> Assume we're either importing new alloy 
			//and we're importing it now 
	        if (definition == null) {
		        return false;
			}

	        return definition.IsPackedMap(path);
        }

        //Make sure to generate PNG alongside .asset file if it doesn't exist yet
        private static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets,
            string[] movedFromAssetPath) {
            foreach (var asset in importedAssets) {
                if (!IsAlloyPackedMapPath(asset)) {
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
            if (!IsAlloyPackedMapPath(assetPath)) {
                return;
            }

            // and if we've got saved settings/data for it...
            var textureName = Path.GetFileNameWithoutExtension(assetPath);
            var path = Path.Combine(Path.GetDirectoryName(assetPath), textureName) + ".asset";

            //Import can fail because of a variety of reasons, so make sure it's all good here
            if (!File.Exists(path)) {
                Debug.LogError(textureName + " has no post-processing data! Please contact Alloy support.");
                Selection.activeObject = texture;
                return;
            }

            var settings = AssetDatabase.LoadAssetAtPath(path, typeof (AlloyCustomImportObject)) as AlloyCustomImportObject;
            if (settings == null) {
                if (AlloyImporterSupervisor.IsFinalTry) {
                    Debug.LogError(textureName + " settings file is corrupt! Contact Alloy support");
                    return;
                }

                AlloyImporterSupervisor.OnFailedImport(path);
                return;
            }

            for (int i = 0; i < 4; ++i) {
                if (settings.SelectedModes[i] == TextureValueChannelMode.Texture && settings.GetTexture(i) == null) {
                    if (AlloyImporterSupervisor.IsFinalTry) {
                        Debug.LogError(textureName + " texture input " + (i + 1) + " can't be loaded!");
                        return;
                    }

                    AlloyImporterSupervisor.OnFailedImport(path);
                    return;
                }
            }

            if (!string.IsNullOrEmpty(settings.NormalGUID) && settings.NormalMapTexture == null) {
                if (AlloyImporterSupervisor.IsFinalTry) {
                    Debug.LogError(textureName + " normalmap texture input can't be loaded!");
                    return;
                }

                AlloyImporterSupervisor.OnFailedImport(path);
                return;
            }

            //If it's all good, do the importing action
            onImport(settings, texture, path);
        }

        void ApplyImportSettings(AlloyCustomImportObject settings, Texture2D texture, string path) {
            var importer = assetImporter as TextureImporter;
            var size = settings.GetOutputSize();
            var def = settings.PackMode;
            var importSettings = def.ImportSettings;

            importer.textureType = TextureImporterType.Default;
            importer.sRGBTexture = !importSettings.IsLinear;
            importer.filterMode = importSettings.Filter;
            importer.mipmapEnabled = true;

            // They need the ability to set this themselves, but we should cap it.
            var nextPowerOfTwo = Mathf.NextPowerOfTwo((int) Mathf.Max(size.x, size.y));

            if (importer.maxTextureSize > nextPowerOfTwo) {
                importer.maxTextureSize = nextPowerOfTwo;
            }

            // Allow setting to uncompressed, else use compressed. Disallows any other format!
            if (def.ImportSettings.DefaultCompressed 
                && importer.textureCompression != TextureImporterCompression.Uncompressed
                && importer.textureCompression != TextureImporterCompression.CompressedLQ
                && importer.textureCompression != TextureImporterCompression.CompressedHQ) {
                importer.textureCompression = TextureImporterCompression.Compressed;
            }
        }

        private void HandleAutoRefresh() {
            var paths = AssetDatabase.GetAllAssetPaths();
            var texGUID = AssetDatabase.AssetPathToGUID(assetPath);

            foreach (var path in paths) {
                if (!IsAlloyPackedMapPath(path)) {
                    continue;
                }

                var setting = AssetDatabase.LoadAssetAtPath(path, typeof (AlloyCustomImportObject)) as AlloyCustomImportObject;
                if (setting == null || (texGUID != setting.NormalGUID && !setting.TexturesGUID.Contains(texGUID))) {
                    continue;
                }

                if (setting.DoAutoRegenerate) {
                    AssetDatabase.ImportAsset(path.Replace(".asset", ".png"));
                }
            }
        }

        private void OnPreprocessTexture() {
            OnAlloyImport(null, ApplyImportSettings);
            HandleAutoRefresh();
        }

        private void OnPostprocessTexture(Texture2D texture) {
            OnAlloyImport(texture, GeneratePackedMaterialMap);
        }

        public static void CreatePostProcessingInformation(string filePath, AlloyCustomImportObject settings) {
            settings.hideFlags = HideFlags.None;
            AssetDatabase.CreateAsset(settings, filePath);
        }

        /// <summary>
        /// Generates the packed material map for an object
        /// </summary>
        public static void GeneratePackedMaterialMap(AlloyCustomImportObject settings, Texture2D target, string filePath) {
            var size = settings.GetOutputSize();
            var normalMap = settings.NormalMapTexture;
            var useUnityGeneratedMipmaps = normalMap == null;
            int width = (int) size.x;
            int height = (int) size.y;
            int mipmapCount = 1;

            // When explicitly generating mip levels pick output count based on the largest input texture.
            if (!useUnityGeneratedMipmaps) {
                mipmapCount = GetMipmapCount(normalMap);

                for (int i = 0; i < 4; ++i) {
                    if (settings.SelectedModes[i] != TextureValueChannelMode.Texture 
                        || settings.GetTexture(i) == null) {
                        continue;
                    }

                    mipmapCount = Math.Max(mipmapCount, GetMipmapCount(settings.GetTexture(i)));
                }
            }

            // Adjust the dimensions of the output texture if necessary.
            if (target.width != width || target.height != height) {
                target.Resize(width, height);
            }

            if (!Mathf.IsPowerOfTwo(width) || !Mathf.IsPowerOfTwo(height)) {
                Debug.LogWarning(
                    "Alloy: Texture resolution is not power of 2; will have issues generating correct mip maps if custom sizing is specified in generated texture platform settings.");
            }

            // Get readable input textures.
            var readableNormal = AlloyTextureReader.GetReadable(normalMap, true);
            var readableTextures = new Texture2D[settings.TexturesGUID.Length];

            for (int i = 0; i < settings.TexturesGUID.Length; ++i) {
                if (settings.SelectedModes[i] != TextureValueChannelMode.Texture) {
                    continue;
                }

                var settingsTex = settings.GetTexture(i);

                if (settingsTex == null) {
                    readableTextures[i] = null;
                } else {
                    readableTextures[i] = AlloyTextureReader.GetReadable(settingsTex, false);
                }
            }

            // Use renderer to sample mipmaps.
            try {
                var message = string.Format("Packing: \"{0}\"", settings.name);
                var progress = 1.0f;
                var bodyText = message;

                for (int mipLevel = 0; mipLevel < mipmapCount; mipLevel++) {
                    if (mipmapCount > 1) {
                        progress = (float)mipLevel / (mipmapCount - 1);
                        bodyText = string.Format("{0} ({1})", message, progress.ToString("0%"));
                    }

                    EditorUtility.DisplayProgressBar("Building Packed maps...", bodyText, progress);

                    // CPU Method - more reliable/consistent across GPUs, but slower.
                    var normalCache = new AlloyTextureColorCache(readableNormal, target);
	            
	                UnityEngine.Profiling.Profiler.BeginSample("Read");
	                var texCache = readableTextures.Select(tex => new AlloyTextureColorCache(tex, target)).ToArray();
	                UnityEngine.Profiling.Profiler.EndSample();
	            
	                AlloyPackerCompositor.CompositeMips(target, settings, texCache, normalCache, mipLevel);
	            }
	        } finally {
	    	    EditorUtility.ClearProgressBar();
	        }
	    
            // Clean up the readable textures.
	        foreach (var texture in readableTextures) {
                Object.DestroyImmediate(texture);
            }

            Object.DestroyImmediate(readableNormal);

            // Update the texture's associated settings .asset object.
            settings.Width = width;
            settings.Height = height;
            settings.MaxResolution = 0;
            EditorUtility.SetDirty(settings);

            // Update the texture object.
            target.Apply(useUnityGeneratedMipmaps, false);
        }

        private static int GetMipmapCount(Texture tex) {
            int count = 1;
            var texture2D = tex as Texture2D;
            var renderTexture = tex as RenderTexture;
            var proceduralTexture = tex as ProceduralTexture;

            if (texture2D != null) {
                count = texture2D.mipmapCount;
            } else if (renderTexture != null) {
                count = renderTexture.useMipMap ? GetMipCountFromSize(tex) : 1;
            } else if (proceduralTexture != null) {
                var mat =
                    proceduralTexture.GetType()
                        .GetMethod("GetProceduralMaterial", BindingFlags.Instance | BindingFlags.NonPublic)
                        .Invoke(proceduralTexture, null) as ProceduralMaterial;
                var imp = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(mat)) as SubstanceImporter;
                count = imp != null && imp.GetGenerateMipMaps(mat) ? GetMipCountFromSize(tex) : 1;
            }

            return count;
        }

        private static int GetMipCountFromSize(Texture tex) {
            return Mathf.CeilToInt(Mathf.Log(Mathf.Max(tex.width, tex.height), 2.0f)) + 1;
        }
    }
}
