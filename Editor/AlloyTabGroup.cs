// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Alloy
{
	[Serializable]
	public class AlloyTabGroup : ScriptableObject
	{
		[SerializeField] private List<bool> m_open;

		[SerializeField] private List<string> m_names;


		private void OnEnable() {
			if (m_open != null && m_names != null) return;

			m_open = new List<bool>();
			m_names = new List<string>();
		}

		private int DeclOpen(string nameDecl) {
			string actual = nameDecl + GUI.depth;

			if (!m_names.Contains(actual)) {
				m_open.Add(false);
				m_names.Add(actual);
			}

			return m_names.IndexOf(actual);
		}


		public bool TabArea(string areaName, Color color, string saveAs = "") {
			if (saveAs == "") {
				saveAs = areaName;
			}


			Color oldGuiColor = GUI.color;
			Color oldBackgroundColor = GUI.backgroundColor;

			GUI.color = Color.Lerp(color, Color.white, 0.8f);
			GUI.backgroundColor = color;

			bool ret = TabArea(areaName, saveAs);
			GUI.color = oldGuiColor;
			GUI.backgroundColor = oldBackgroundColor;
			return ret;
		}


		public bool TabArea(string areaName, string saveAs = "") {
			if (saveAs == "") {
				saveAs = areaName;
			}

			int i = DeclOpen(saveAs);


			var oldCol = GUI.color;
			GUI.color = oldCol * (m_open[i] ? Color.white : new Color(0.8f, 0.8f, 0.8f));

			var rect = GUILayoutUtility.GetRect(Screen.width - 30.0f, 18.0f);
			rect.x -= 20.0f;
			rect.width += 50.0f;


			m_open[i] = GUI.Toggle(rect, m_open[i], new GUIContent(""), "ShurikenModuleTitle");

			rect.x += 20.0f;

			// Ensures tab text is always white, even when using light skin in pro.
			GUI.color = EditorGUIUtility.isProSkin ? new Color(0.7f, 0.7f, 0.7f) : new Color(0.9f, 0.9f, 0.9f);
			GUI.Label(rect, areaName, EditorStyles.whiteLabel);
			GUI.color = oldCol;

			if (GUI.changed)
				EditorUtility.SetDirty(this);

			return m_open[i];
		}

		public bool Foldout(string areaName, string saveName, params GUILayoutOption[] options) {
			int i = DeclOpen(saveName);


			EditorGUILayout.BeginHorizontal();
			m_open[i] = EditorGUILayout.Toggle(new GUIContent(""), m_open[i], "foldout", options);

			if (areaName != "")
				EditorGUILayout.LabelField(new GUIContent(areaName), GUILayout.ExpandWidth(false));
			EditorGUILayout.EndHorizontal();

			if (GUI.changed)
				EditorUtility.SetDirty(this);

			return m_open[i];
		}



		public bool IsOpen(string areaName) {
			int i = DeclOpen(areaName);
			return m_open[i];
		}

		public void SetOpen(string areaName, bool open) {
			int i = DeclOpen(areaName);
			m_open[i] = open;
		}

		public void Close(string areaName) {
			int i = DeclOpen(areaName);
			m_open[i] = false;
		}
	}
}