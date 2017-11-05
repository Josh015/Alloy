// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Alloy
{
    public class AlloyImportFloat : ScriptableObject {}

    [InitializeOnLoad]
    public static class AlloyImporterSupervisor
    {
        private static List<string> s_failedImportAttempts = new List<string>();

        public static bool IsFinalTry;
        private static AlloyImportFloat m_float;

        public static void OnFailedImport(string path) {
            if (!s_failedImportAttempts.Contains(path)) {
                s_failedImportAttempts.Add(path);
            }
        }

        static AlloyImporterSupervisor() {
            var all = Resources.FindObjectsOfTypeAll<AlloyImportFloat>();

            if (all.Length == 0) {
                m_float = ScriptableObject.CreateInstance<AlloyImportFloat>();
                m_float.hideFlags = HideFlags.HideAndDontSave;

                ScanForLateImport();
            } else {
                m_float = all[0];
            }

            EditorApplication.update += Update;
        }

        private static void ScanForLateImport() {
            var assets = AssetDatabase.FindAssets("t:AlloyCustomImportObject");


            foreach (var asset in assets) {
                var path = AssetDatabase.GUIDToAssetPath(asset);
                var png = path.Replace(".asset", ".png");
                var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(png);

                if (tex == null) {
                    AssetDatabase.ImportAsset(path);
                } else {
                    if (tex.width == 4 && tex.height == 4) {
                        AssetDatabase.ImportAsset(png);
                    }
                }
            }
        }

        // Update is called once per frame
        private static void Update() {
        if (s_failedImportAttempts.Count == 0) {
                return;
            }

            var failed = s_failedImportAttempts.ToArray();
            foreach (var path in failed) {
                
                var settings = AssetDatabase.LoadAssetAtPath(path, typeof (AlloyCustomImportObject)) as AlloyCustomImportObject;
                if (settings == null) {
                    continue;
                }

                IsFinalTry = true;
                settings.GenerateMap();
                IsFinalTry = false;

                s_failedImportAttempts.Remove(path);
            }
        }
    }
}