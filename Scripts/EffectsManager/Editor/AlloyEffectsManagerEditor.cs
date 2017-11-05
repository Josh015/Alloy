// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System.Collections.Generic;
using System.Linq;
using Alloy;
using UnityEditor;
using UnityEditor.AnimatedValues;
using UnityEngine;

[CustomEditor(typeof(AlloyEffectsManager))]
public class AlloyEffectsManagerEditor : Editor {
    private const string c_skinTabName = "SkinTab";
    private const string c_transmissionTabName = "TransmissionTab";
    private static Color s_scatterColor = new Color(0.49f, 0.36f, 0.16f);
    private static Color s_transmissionColor = new Color(0.49f, 0.46f, 0.16f);

    private AlloyTabGroup m_tabGroup;
    private AnimBool m_skinGroup;
    private AnimBool m_transmissionGroup;
    private List<AlloyTabAdd> m_tabAdd = new List<AlloyTabAdd>();
    private GenericMenu m_menu;

    private void OnEnable() {
        m_tabGroup = AlloyTabGroup.GetTabGroup();
        m_skinGroup = new AnimBool(m_tabGroup.IsOpen(c_skinTabName));
        m_transmissionGroup = new AnimBool(m_tabGroup.IsOpen(c_transmissionTabName));
    }

    public override void OnInspectorGUI() {
        serializedObject.Update();
        m_tabAdd.Clear();

        var skinEnabled = serializedObject.FindProperty("SkinSettings.Enabled");
        
        if (skinEnabled.boolValue && !skinEnabled.hasMultipleDifferentValues) {
            bool removed;
            m_skinGroup.target = m_tabGroup.TabArea("Skin Scattering", s_scatterColor, true, out removed,
                c_skinTabName);
            
            if (EditorGUILayout.BeginFadeGroup(m_skinGroup.faded)) {
                var prop = serializedObject.FindProperty("SkinSettings");
                prop.Next(true); //skip flag
                prop.Next(true); //skip enabled

                DrawRemainingProp(prop);
            }

            EditorGUILayout.EndFadeGroup();
            
            if (removed) {
                skinEnabled.boolValue = false;
            }
        }
        else {
            m_tabAdd.Add(new AlloyTabAdd {
                Color = s_scatterColor,
                Name = "Skin Scattering",
                Enable = EnableSkin
            });
        }
        
        var transEnabled = serializedObject.FindProperty("TransmissionSettings.Enabled");
        
        if (transEnabled.boolValue && !transEnabled.hasMultipleDifferentValues) {
            bool removed;
            m_transmissionGroup.target = m_tabGroup.TabArea("Transmission", s_transmissionColor, true, out removed,
                c_transmissionTabName);
            
            if (EditorGUILayout.BeginFadeGroup(m_transmissionGroup.faded)) {
                var prop = serializedObject.FindProperty("TransmissionSettings");
                prop.Next(true); //skip flag
                prop.Next(true);//skip enabled
                DrawRemainingProp(prop);
            }

            EditorGUILayout.EndFadeGroup();

            if (removed) {
                transEnabled.boolValue = false;
            }
        } 
        else {
            m_tabAdd.Add(new AlloyTabAdd {
                Color = s_transmissionColor,
                Name = "Transmission",
                Enable = EnableTransmission
            });
        }
        
        if (m_skinGroup.isAnimating || m_transmissionGroup.isAnimating) {
            Repaint();
        }

        AlloyEditor.DrawAddTabGUI(m_tabAdd);
        serializedObject.ApplyModifiedProperties();
        
        if (GUI.changed) {
            var deferredRendererPlus = serializedObject.targetObject as AlloyEffectsManager;

            if (deferredRendererPlus != null) {
                deferredRendererPlus.Refresh();
            }
        }
    }

    private void EnableTransmission() {
        foreach (AlloyEffectsManager rend in targets) {
            rend.TransmissionSettings.Enabled = true;
            EditorUtility.SetDirty(rend);
            rend.Refresh();
        }

        m_transmissionGroup.value = false;
        m_transmissionGroup.target = true;
        m_tabGroup.SetOpen(c_transmissionTabName, true);
    }

    private void EnableSkin() {
        foreach (AlloyEffectsManager rend in targets) {
            rend.SkinSettings.Enabled = true;
            EditorUtility.SetDirty(rend);
            rend.Refresh();
        }

        m_skinGroup.value = false;
        m_skinGroup.target = true;
        m_tabGroup.SetOpen(c_skinTabName, true);
    }
    
    private static void DrawRemainingProp(SerializedProperty prop) {
        int depth = prop.depth;

        while (true) {
            bool child = EditorGUILayout.PropertyField(prop, true);

            if (!prop.Next(child) || prop.depth < depth)
                break;
        }
    }
}
