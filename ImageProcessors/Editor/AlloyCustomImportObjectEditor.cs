// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using System.IO;
using UnityEditor;
using UnityEngine;


namespace Alloy
{
	[CustomEditor(typeof(AlloyCustomImportObject))]
	public class AlloyCustomImportObjectEditor : Editor
	{
		private AlloyMaterialMapChannelPacker cs;

		private Vector2 m_scrollPos;

		void OnEnable() {
			cs = CreateInstance<AlloyMaterialMapChannelPacker>();
			cs.hideFlags = HideFlags.HideAndDontSave;

			cs.Target = target as AlloyCustomImportObject;
		}

		void OnDisable() {
			DestroyImmediate(cs);
		}

		public override void OnInspectorGUI() {
			m_scrollPos = GUILayout.BeginScrollView(m_scrollPos);
			cs.DoBaseGUI();

			GUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();

			bool isButtonClicked = GUILayout.Button("Regenerate", EditorStyles.toolbarButton, GUILayout.Width(120.0f),
										GUILayout.Height(70.0f));

			GUILayout.FlexibleSpace();
			GUILayout.EndHorizontal();

			GUILayout.EndScrollView();


			if (isButtonClicked) {
				cs.Target.GenerateMap();
			}


		}
	}
}