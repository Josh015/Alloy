// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEditor;
using UnityEngine;

namespace Alloy
{
    [CustomEditor(typeof(AlloyCustomImportObject))]
    public class AlloyCustomImportObjectEditor : Editor
    {
        private AlloyMaterialMapChannelPacker m_packer;

        private Vector2 m_scrollPos;

        void OnEnable() {
            m_packer = CreateInstance<AlloyMaterialMapChannelPacker>();
            m_packer.hideFlags = HideFlags.HideAndDontSave;

            m_packer.Target = target as AlloyCustomImportObject;
        }

        void OnDisable() {
            DestroyImmediate(m_packer);
        }

        public override void OnInspectorGUI() {
            m_scrollPos = GUILayout.BeginScrollView(m_scrollPos);
            bool isValid = m_packer.BaseGUI();
            bool isButtonClicked = m_packer.GenerateButtonGUI("Regenerate", isValid);

            GUILayout.EndScrollView();
            
            if (isButtonClicked) {
                m_packer.Target.GenerateMap();
            }
        }
    }
}