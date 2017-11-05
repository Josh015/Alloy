using System.Collections.Generic;
using System.Linq;
using System.IO;
using UnityEditor;
using UnityEngine;

public static class AlloyMigrationTools {
    private const string keywordReportFilename = "/Alloy/Scripts/Material Report.txt";
    
    [MenuItem(AlloyUtils.MenuItem + "Material Report", false, 11)]
    private static void MaterialReport() {
        var fileName = Application.dataPath + keywordReportFilename;
        var sr = File.CreateText(fileName);
        var materials = GetSceneMaterialsWithKeywords().OrderBy(m => m.name);
        var keywordList = materials
                        .SelectMany(m => m.shaderKeywords)
                        .Where(k => !string.IsNullOrEmpty(k))
                        .Distinct()
                        .OrderBy(k => k);
        var keywordCount = keywordList.Count();
        var materialShaderNames = new List<string>();

        sr.WriteLine(" ");
        sr.WriteLine("-----------------------------------------------------------------------");
        sr.WriteLine(" Keywords: " + keywordCount);
        sr.WriteLine("-----------------------------------------------------------------------");
        
        foreach (var keyword in keywordList) {
            sr.WriteLine("\"" + keyword + "\",");
        }

        sr.WriteLine(" ");
        sr.WriteLine("-----------------------------------------------------------------------");
        sr.WriteLine(" Keywords -> Materials: " + keywordCount);
        sr.WriteLine("-----------------------------------------------------------------------");

        foreach (var keyword in keywordList) {
            sr.WriteLine("\"" + keyword + "\",");

            foreach (var material in materials) {
                var shaderKeywords = material.shaderKeywords;

                if (shaderKeywords.Contains(keyword)) {
                    sr.WriteLine("    " + material.name);
                }
            }

            sr.WriteLine(" ");
        }

        sr.WriteLine("-----------------------------------------------------------------------");
        sr.WriteLine(" Materials -> Keywords: " + materials.Count());
        sr.WriteLine("-----------------------------------------------------------------------");

        foreach (var material in materials) {
            var shaderKeywords = material.shaderKeywords.OrderBy(k => k);
            
            sr.WriteLine(material.name);

            foreach (var keyword in shaderKeywords) {
                if (!string.IsNullOrEmpty(keyword)) {
                    sr.WriteLine("    \"" + keyword + "\",");
                }
            }

            sr.WriteLine(" ");
            materialShaderNames.Add(material.shader.name);
        }

        var shaderNames = materialShaderNames.Distinct().OrderBy(s => s);

        sr.WriteLine("-----------------------------------------------------------------------");
        sr.WriteLine(" Shaders -> Materials: " + shaderNames.Count());
        sr.WriteLine("-----------------------------------------------------------------------");

        foreach (var shaderName in shaderNames) {
            var shaderMaterials = materials.Where(m => m.shader.name == shaderName).Select(m => m.name);

            sr.WriteLine("\"" + shaderName + "\"");

            foreach (var materialName in shaderMaterials) {
                if (!string.IsNullOrEmpty(materialName)) {
                    sr.WriteLine("    " + materialName);
                }
            }

            sr.WriteLine(" ");
        }

        sr.Close();
        System.Diagnostics.Process.Start(fileName);
    }

    [MenuItem(AlloyUtils.MenuItem + "Material Migrator", false, 11)]
    private static void MaterialMigrator() {
        var window = ScriptableObject.CreateInstance<AlloyMaterialMigratorPopup>();
        var dimensions = new Vector2(350, 100);

        window.position = new Rect(Screen.width / 2, Screen.height / 2, 0, 0);
        window.minSize = dimensions;
        window.maxSize = dimensions;
        window.ShowUtility();
    }
    
    [MenuItem(AlloyUtils.MenuItem + "Light Converter", false, 11)]
    private static void LightConverter() {
        var lights = Resources.FindObjectsOfTypeAll<Light>();
        var lightsLength = lights.Length;

        for (int i = 0; i < lightsLength; i++) {
            var light = lights[i];

            EditorUtility.DisplayProgressBar(
                "Converting lights...",
                string.Format("Light {0} / {1}.", i + 1, lightsLength),
                i / (lightsLength - 1.0f));
            
            // Skip Unity baked Area Lights & Prefabs.
            if (light.type != LightType.Area
                && !EditorUtility.IsPersistent(light)) {
                var area = light.GetComponent<AlloyAreaLight>();
                
                if (area == null) {
                    Undo.RecordObject(light.gameObject, "Convert to Alloy area lights.");
                    area = Undo.AddComponent<AlloyAreaLight>(light.gameObject);
                }

                Undo.RecordObject(light, "Set default light cookie");
                area.UpdateBinding();
            }
        }

        EditorUtility.ClearProgressBar();
    }

    private static IEnumerable<Material> GetSceneMaterialsWithKeywords() {
        return Resources.FindObjectsOfTypeAll<Material>().Where(m => m.shaderKeywords.Length > 0);
    }
}

public class AlloyMaterialMigratorPopup : EditorWindow {
    private const string messageFilename = "/Alloy/Scripts/Editor/MaterialMigratorWarning.txt";
    private static string[] keywordsToRemove = new string[] {
        "_AO2MAPUV_UV0",
        "_AO2MAPUV_UV1",
        "_BLENDMAPUV_UV0",
        "_BLENDMAPUV_UV1",
        "_BUMPMODE_BUMP",
        "_BUMPMODE_PARALLAX", // Set by stupid KeywordEnum.
        "_BUMPMODE_SPOM",
        "_CARFLAKEMAPUV_UV0",
        "_CARFLAKEMAPUV_UV1",
        "_DECAL_OFF",
        "_DECALMODE_NONE",
        "_DECALTEXUV_UV0",
        "_DECALTEXUV_UV1",
        "_DETAIL_ON", // Replaced with _DETAIL_MULX2
        "_DETAILALBEDOMAPUV_UV0",
        "_DETAILALBEDOMAPUV_UV1",
        "_DETAILMASKSSOURCE_TEXTURE", // From when I was trying that Masks channel picker idea. >_<
        "_DETAILMASKSOURCE_TEXTURE", // Discarded first attempt at name.
        "_DETAILMASKSOURCE_TEXTUREALPHA", // Set by stupid KeywordEnum.
        "_DETAILMASKSOURCE_VERTEXCOLORALPHA", // Replaced with _NORMALMAP
        "_DETAILMODE_MUL",
        "_DETAILMODE_MULX2",
        "_DIRECTIONALBLENDMODE_WORLD", // Deprecated after I made world-space the default.
        "_DISSOLVETEXUV_UV0",
        "_DISSOLVETEXUV_UV1",
        "_EMISSION_ON",
        "_ENVIRONMENTMAPMODE_RSRM",
        "_ENVIRONMENTMAPMODE_SKYSHOP",
        "_ENVIRONMENTMAPMODE_SKYSHOPSH",
        "_INCANDESCENCEMAPUV_UV0",
        "_INCANDESCENCEMAPUV_UV1",
        "_INCANDESCENCEMAPUV2_UV0",
        "_INCANDESCENCEMAPUV2_UV1",
        "_MAINTEXTURESMODE_FULL",
        "_MAINTEXTURESMODE_LITE",
        "_MAINTEXTURESROUGHNESSSOURCE_BASECOLORALPHA", // Discarded first attempt at name.
        "_MAINTEXTURESROUGHNESSSOURCE_MATERIALALPHA", // Discarded first attempt at name.
        "_MAINROUGHNESSSOURCE_BASECOLORALPHA", // Replaced with _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        "_MAINROUGHNESSSOURCE_PACKEDMAPALPHA", // Set by stupid KeywordEnum.
        "_ORIENTEDROUGHNESSSOURCE_BASECOLORALPHA", // Replaced with _SPECGLOSSMAP
        "_ORIENTEDROUGHNESSSOURCE_PACKEDMAPALPHA", // Set by stupid KeywordEnum.
        "_ORIENTEDTEXTURESMODE_FULL",
        "_ORIENTEDTEXTURESMODE_LITE",
        "_ORIENTEDTEXTURESROUGHNESSSOURCE_BASECOLORALPHA", // Discarded first attempt at name.
        "_ORIENTEDTEXTURESROUGHNESSSOURCE_MATERIALALPHA", // Discarded first attempt at name.
        "_PARALLAX_ON", // Replaced with _PARALLAXMAP
        "_RIMTEXUV_UV0",
        "_RIMTEXUV_UV1",
        "_RIMTEXUV2_UV0",
        "_RIMTEXUV2_UV1",
        "_SECONDARYROUGHNESSSOURCE_BASECOLORALPHA", // Replaced with _METALLICGLOSSMAP
        "_SECONDARYROUGHNESSSOURCE_PACKEDMAPALPHA", // Set by stupid KeywordEnum.
        "_SECONDARYTEXTURESMODE_FULL",
        "_SECONDARYTEXTURESMODE_LITE",
        "_TESSELLATIONMODE_COMBINED", // Dropped this mode in favor of using two other modes keywords together.
        "_TRANSITIONTEXUV_UV0",
        "_TRANSITIONTEXUV_UV1",
        "_TRIPLANARMODE_WORLD", // Deprecated after I made world-space the default.
        "_UVSEC_UV0", // Standard shader sets this.
        "_UVSEC_UV1", // Standard shader sets this.
    };

    void OnGUI() {
        var message = File.ReadAllText(Application.dataPath + messageFilename);

        titleContent = new GUIContent("Migrate Materials?");
        EditorGUILayout.LabelField(message, EditorStyles.wordWrappedLabel);
        GUILayout.Space(10);

        EditorGUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();

        if (GUILayout.Button("Confirm")) {
            Close();
            MigrateMaterials();
        }

        if (GUILayout.Button("Cancel")) {
            Close();
        }

        GUILayout.FlexibleSpace();
        EditorGUILayout.EndHorizontal();
    }

    void MigrateMaterials() {
        try {
            var materialGuids = AssetDatabase.FindAssets("t:material");
            var length = materialGuids.Length;

            for (int i = 0; i < length; i++) {
                var material = AssetDatabase.LoadAssetAtPath(AssetDatabase.GUIDToAssetPath(materialGuids[i]), typeof(Material)) as Material;
                var shaderKeywords = material.shaderKeywords;
                var shaderName = material.shader.name;

                EditorUtility.DisplayProgressBar(
                    "Migrating Materials...",
                    string.Format("({0} / {1}) {2}", i, length, material.name),
                    i / (float)(length - 1));
                    
                if (shaderName.Contains("Alloy")) {
                    if (!shaderKeywords.Contains("EFFECT_BUMP")
                        && material.HasProperty("_HasBumpMap")
                        && Mathf.Approximately(material.GetFloat("_HasBumpMap"), 1.0f)) {
                        material.EnableKeyword("EFFECT_BUMP");
                    }

                    // Have Eye shaders default to having no material map.
                    if (!shaderKeywords.Contains("_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A")
                        && material.HasProperty("_MainRoughnessSource")
                        && Mathf.Approximately(material.GetFloat("_MainRoughnessSource"), 1.0f)) {
                        material.EnableKeyword("_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A");
                    }

                    // TODO: Comment out these two case after enough time has passed.
                    // Swap World and Object now that World is default.
                    if (material.HasProperty("_DirectionalBlendMode")) {
                        if (shaderKeywords.Contains("_DIRECTIONALBLENDMODE_WORLD")) {
                            material.SetFloat("_DirectionalBlendMode", 0.0f);
                            material.DisableKeyword("_DIRECTIONALBLENDMODE_WORLD");
                        } else if (!shaderKeywords.Contains("_DIRECTIONALBLENDMODE_OBJECT")
                                && Mathf.Approximately(material.GetFloat("_DirectionalBlendMode"), 0.0f)) {
                            material.SetFloat("_DirectionalBlendMode", 1.0f);
                            material.EnableKeyword("_DIRECTIONALBLENDMODE_OBJECT");
                        }
                    }

                    // Swap World and Object now that World is default.
                    if (material.HasProperty("_TriplanarMode")) {
                        if (shaderKeywords.Contains("_TRIPLANARMODE_WORLD")) {
                            material.SetFloat("_TriplanarMode", 0.0f);
                            material.DisableKeyword("_TRIPLANARMODE_WORLD");
                        } else if (!shaderKeywords.Contains("_TRIPLANARMODE_OBJECT")
                                && Mathf.Approximately(material.GetFloat("_TriplanarMode"), 0.0f)) {
                            material.SetFloat("_TriplanarMode", 1.0f);
                            material.EnableKeyword("_TRIPLANARMODE_OBJECT");
                        }
                    }

                    // Clean up any remaining keywords.
                    var toRemove = shaderKeywords.Intersect(keywordsToRemove);

                    foreach (var keyword in toRemove) {
                        if (!string.IsNullOrEmpty(keyword)) {
                            material.DisableKeyword(keyword);

                            // Migrate to Unity keywords.
                            switch (keyword) {
                                case "_DETAIL_ON":
                                    material.EnableKeyword("_DETAIL_MULX2");
                                    break;
                                case "_DETAILMASKSOURCE_VERTEXCOLORALPHA":
                                    material.EnableKeyword("_NORMALMAP");
                                    break;
                                case "_MAINROUGHNESSSOURCE_BASECOLORALPHA":
                                    material.EnableKeyword("_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A");
                                    break;
                                case "_PARALLAX_ON":
                                    material.EnableKeyword("_PARALLAXMAP");
                                    break;
                            }
                        }
                    }

                    EditorUtility.SetDirty(material);
                    AssetDatabase.SaveAssets();
                    material = null;
                    EditorUtility.UnloadUnusedAssetsImmediate();
                }
            }
        }
        finally {
            EditorUtility.ClearProgressBar();
        }
    }
}