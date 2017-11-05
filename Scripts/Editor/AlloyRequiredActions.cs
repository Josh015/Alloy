// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System.IO;

using UnityEngine;
using UnityEditor;

[InitializeOnLoad] 
static class AlloyRequiredActions {
    static AlloyRequiredActions() {
        // Check if popup hasn't appeared for this version.
        if (File.Exists(AlloyRequiredActionsPopup.MessageFilePath)
            && EditorPrefs.GetString(AlloyRequiredActionsPopup.SettingsKey) != AlloyUtils.Version) {
            var window = ScriptableObject.CreateInstance<AlloyRequiredActionsPopup>();
            var dimensions = new Vector2(350, 200);

            window.position = new Rect(Screen.width / 2, Screen.height / 2, 0, 0);
            window.minSize = dimensions;
            window.maxSize = dimensions;
            window.ShowUtility();
        } 
    } 
}

public class AlloyRequiredActionsPopup : EditorWindow {
    public const string SettingsKey = "AlloyRequiredActionsPopupShown";

    public static string MessageFilePath {
        get { return AlloyUtils.AssetsPath + "REQUIRED ACTIONS.txt"; }
    }

    void OnGUI() {        
        var message = File.ReadAllText(MessageFilePath);
        
        titleContent = new GUIContent(string.Format("Required Actions for Alloy {0}...", AlloyUtils.Version));
        EditorGUILayout.LabelField(message, EditorStyles.wordWrappedLabel);
        GUILayout.Space(10);

        EditorGUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();

        if (GUILayout.Button("Okay")) {
            Close();
        }

        GUILayout.FlexibleSpace();
        EditorGUILayout.EndHorizontal();

        // Make sure it doesn't reappear again for this version.
        EditorPrefs.SetString(SettingsKey, AlloyUtils.Version);
    }
}