using System;
using System.Linq;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(Camera))]
[CanEditMultipleObjects]
public class AlloyCameraEditor : Editor {
    Editor m_editor;

    Type GetTypeGlobal(string typeName) {
        return AppDomain.CurrentDomain.GetAssemblies().SelectMany(a => a.GetTypes()).FirstOrDefault(t => t.Name == typeName);
    }

    void OnEnable() {
        m_editor = CreateEditor(targets, GetTypeGlobal("CameraEditor"));
    }

    void OnDisable() {
        DestroyImmediate(m_editor);
    }

    public override void OnInspectorGUI() {
        m_editor.OnInspectorGUI();
        bool anyMissing = targets.Any(c => ((Camera)c).GetComponent<AlloyEffectsManager>() == null);

        if (anyMissing) {
            if (GUILayout.Button("Convert to Alloy Effects Manager", EditorStyles.toolbarButton)) {
                foreach (Camera camera in targets) {
                    Undo.AddComponent<AlloyEffectsManager>(camera.gameObject);
                }
            }
        }
    }
}