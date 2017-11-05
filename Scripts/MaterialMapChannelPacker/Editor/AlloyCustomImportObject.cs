// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace Alloy
{
    // This stores information used by the asset re-importer; 
    // to rebuild Mip Maps with corrected roughness information.
    public class AlloyCustomImportObject : ScriptableObject
    {
        [HideInInspector] 
        public Vector4 ChannelValues  = new Vector4(0.0f, 0.0f, 0.5f, 0.0f);

        public string[] TexturesGUID = {"", "", "", ""};
        public string NormalGUID;

        public bool[] DoInvert = {false, false, false, false};


        public float VarianceBias;

        public int Width;
        public int Height;

        public bool DoAutoRegenerate;
        public TextureValueChannelMode[] SelectedModes = {
                                                                                       TextureValueChannelMode.Texture,
                                                                                       TextureValueChannelMode.Texture,
                                                                                       TextureValueChannelMode.Gray,
                                                                                       TextureValueChannelMode.Texture
                                                                                   };

        Texture2D[] m_textures;
        public static readonly int[] s_Resolutions = {0, 32, 64, 128, 256, 512, 1024, 2048, 4096};
        [HideInInspector] public int MaxResolution = 0;


        /// ///LEGACY:
        public bool IsDetailMap;
        public bool IsTerrainMap;
        /// ///
        
        [SerializeField]
        PackedMapDefinition m_packMode;

        public PackedMapDefinition PackMode {
            get {
                if (m_packMode == null) {
	                var defintion = AlloyMaterialMapChannelPacker.GlobalDefinition;

	                if (IsDetailMap) {
                        m_packMode = defintion.DetailPack;
                    }else if (IsTerrainMap) {
                        m_packMode = defintion.TerrainPack;
                    } else {
                        m_packMode = defintion.PackedPack;
                    }
                }
                return m_packMode;
            }
            set { m_packMode = value; }
        }
        

        Texture2D m_normalTex;
        public Texture2D NormalMapTexture {
            get {
                if (m_normalTex == null) {
                    m_normalTex =
                        AssetDatabase.LoadAssetAtPath(AssetDatabase.GUIDToAssetPath(NormalGUID), typeof(Texture2D)) as Texture2D;
                }

                return m_normalTex;
            }
            set {
                m_normalTex = value;
                NormalGUID = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(value));
            }
        }


        public void SetTextures(Texture2D[] textures, Texture2D normalMap) {
            m_textures = textures;
            NormalMapTexture = normalMap;

            TexturesGUID = new string[textures.Length];

            for (int i = 0; i < textures.Length; ++i) {
                TexturesGUID[i] = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(textures[i]));
            }

            NormalGUID = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(normalMap));
        }

        public Texture2D GetTexture(int index) {
            if (m_textures == null || m_textures.Length == 0) {
                m_textures = new Texture2D[4];
            }

            if (m_textures[index] == null) {
                m_textures[index] =
                    AssetDatabase.LoadAssetAtPath(AssetDatabase.GUIDToAssetPath(TexturesGUID[index]), typeof (Texture2D)) as Texture2D;
            }

            return m_textures[index];
        }

        public const int DefaultOutputWidth = 32,
                 DefaultOutputHeight = 32,
                 DefaultOutputMipmapCount = 1;

        public Vector2 GetOutputSize() {
            int width = DefaultOutputWidth;
            int height = DefaultOutputHeight;

            // Pick output texture dimensions based on the largest input texture.
            for (int i = 0; i < 4; ++i) {
                var texture = GetTexture(i);

                if (SelectedModes[i] == TextureValueChannelMode.Texture && texture != null) {
                    // So we can accomodate rectangles, if need be.
                    width = Math.Max(width, texture.width);
                    height = Math.Max(height, texture.height);
                }
            }

            if (NormalMapTexture != null) {
                width = Math.Max(width, NormalMapTexture.width);
                height = Math.Max(height, NormalMapTexture.height);
            }

            return new Vector2(width, height);
        }

        public void GenerateMap() {
            string path = AssetDatabase.GetAssetPath(this).Replace(".asset", ".png");

            var tempTex = new Texture2D(4, 4, TextureFormat.ARGB32, true);
            AssetDatabase.DeleteAsset(path);
            File.WriteAllBytes(path, tempTex.EncodeToPNG());
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
        }

        public void SetTexture(Texture2D selTex, int texIndex) {
            TexturesGUID[texIndex] = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(selTex));
            m_textures[texIndex] = selTex;
        }

        public void ClearCache() {
            m_textures[0] = null;
            m_textures[1] = null;
            m_textures[2] = null;
            m_textures[3] = null;
        }
    }
}