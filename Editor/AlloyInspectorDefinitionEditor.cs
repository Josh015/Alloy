// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEditor;
using UnityEngine;

namespace Alloy
{
	[CustomEditor(typeof (AlloyInspectorDefinition))]
	public class AlloyInspectorDefinitionEditor : Editor
	{
		private void ArrayGUIStart(SerializedProperty sp) {
			float old = EditorGUIUtility.labelWidth;

			EditorGUIUtility.labelWidth = 320.0f;
			GUILayout.Space(4.0f);
			EditorGUILayout.BeginVertical("box", GUILayout.MaxWidth(Screen.width));

			ArrayGUIIterative(sp);

			sp.Reset();

			EditorGUI.indentLevel = 0;
			EditorGUILayout.EndVertical();
			EditorGUIUtility.labelWidth = old;
		}

		private int ArrayGUIIterative(SerializedProperty sp) {
			EditorGUI.indentLevel = sp.depth;

			int i = 0;
			int del = -1;

			int startDepth = sp.depth;

			SerializedProperty array = sp.Copy();

			bool open = EditorGUILayout.PropertyField(sp);

			if (!open) {
				return 0;
			}

			sp.NextVisible(true);

			bool child = EditorGUILayout.PropertyField(sp);


			if (sp.intValue == 0) {
				return 0;
			}

			int over = 0;

			while (true) {
				if (!sp.NextVisible(child)) {
					over = -1;
					break;
				}

				if (sp.depth < startDepth) {
					over = 1;
					break;
				}

				bool doArray = sp.isArray && sp.propertyType != SerializedPropertyType.String && sp.depth != startDepth;

				if (doArray) {
					int br = ArrayGUIIterative(sp);

					if (br == 0) {
						child = false;
						continue;
					}

					if (br == -1) {
						break;
					}
				}


				EditorGUI.indentLevel = sp.depth - 1;

				if (sp.depth == startDepth + 1) {
					EditorGUILayout.BeginHorizontal();

					if (GUILayout.Button("", "OL Minus", GUILayout.Width(21.0f))) {
						del = i;
					}

					GUILayout.Space(10.0f);
					child = EditorGUILayout.PropertyField(sp);


					GUI.enabled = i > 0;

					if (GUILayout.Button("U", "ButtonLeft", GUILayout.Width(22.0f), GUILayout.Height(18.0f))) {
						array.MoveArrayElement(i - 1, i);
					}

					GUI.enabled = i < array.arraySize - 1;
					if (GUILayout.Button("D", "ButtonRight", GUILayout.Width(22.0f), GUILayout.Height(18.0f))) {
						array.MoveArrayElement(i + 1, i);
					}

					++i;

					GUI.enabled = true;
					EditorGUILayout.EndHorizontal();

				}
				else {
					EditorGUI.indentLevel += 1;
					child = EditorGUILayout.PropertyField(sp);
				}

			}

			if (del != -1) {
				array.DeleteArrayElementAtIndex(del);
			}

			return over;
		}

		public override void OnInspectorGUI() {
			serializedObject.Update();

			var tabs = serializedObject.FindProperty("Tabs");

			ArrayGUIStart(tabs);

			serializedObject.ApplyModifiedProperties();
		}
	}
}