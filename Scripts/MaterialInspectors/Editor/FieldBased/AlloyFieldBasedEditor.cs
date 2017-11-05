// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.AnimatedValues;

[CanEditMultipleObjects]
public class AlloyFieldBasedEditor : AlloyInspectorBase {
	Dictionary<string, AnimBool> m_openCloseAnim = new Dictionary<string, AnimBool>();
	AlloyFieldDrawer[] m_fieldDrawers;

	string[] m_allTabs;

	public bool TabIsEnabled(MaterialProperty prop) {
		return !prop.hasMixedValue && prop.floatValue > 0.5f;
	}

	public void EnableTab(string tab, MaterialProperty prop, int matInst) {
		m_openCloseAnim[prop.name].value = false;
		TabGroup.SetOpen(tab + matInst, true);

		prop.floatValue = 1.0f;
		MaterialEditor.ApplyMaterialPropertyDrawers(Targets);
        RepaintScene();
	}

	public void DisableTab(string tab, MaterialProperty prop, int matInst) {
		prop.floatValue = 0.0f;
		MaterialEditor.ApplyMaterialPropertyDrawers(Targets);
        RepaintScene();
		
		m_openCloseAnim[prop.name].target = false;
		TabGroup.SetOpen(tab + matInst, false);
	}

	protected override void OnAlloyShaderEnable() {
		Undo.undoRedoPerformed += OnUndo;
	}

	public override void OnAlloyShaderDisable() {
		base.OnAlloyShaderDisable();

		if (m_fieldDrawers != null) {
			foreach (var drawer in m_fieldDrawers) {
				if (drawer != null) {
					drawer.OnDisable();
				}
			}
		}
	}

	void OnUndo() {
		MatEditor.Repaint();
	}

	static HashSet<string> s_knownNulls = new HashSet<string>();

	protected override void OnAlloyShaderGUI(MaterialProperty[] properties) {
		//Refresh drawer structure if needed
		bool structuralChange = false;
		if (m_fieldDrawers == null || m_fieldDrawers.Length != properties.Length) {
			m_fieldDrawers = new AlloyFieldDrawer[properties.Length];
			structuralChange = true;
		}

		for (int i = 0; i < properties.Length; ++i) {
			string propName = properties[i].name;

			if (m_fieldDrawers[i] == null && !s_knownNulls.Contains(propName) || m_fieldDrawers[i] != null && m_fieldDrawers[i].Property.name != propName) {
				m_fieldDrawers[i] = AlloyFieldDrawerFactory.GetFieldDrawer(this, properties[i]);

				if (m_fieldDrawers[i] == null) {
					s_knownNulls.Add(propName);
				}
				else {
					structuralChange = true;
				}
			}
		}

		//If changed, update the animation stuff
		if (structuralChange) {
			m_openCloseAnim.Clear();
			var allTabs = new List<string>();

			for (var i = 0; i < m_fieldDrawers.Length; i++) {
				var drawer = m_fieldDrawers[i];

				if (!(drawer is AlloyTabDrawer)) {
					continue;
				}

				bool isOpenCur = TabGroup.IsOpen(drawer.DisplayName + MatInst);

				var anim = new AnimBool(isOpenCur) {speed = 6.0f, value = isOpenCur};
				m_openCloseAnim.Add(properties[i].name, anim);
				allTabs.Add(drawer.DisplayName);
			}

			m_allTabs = allTabs.ToArray();
		}


		//Formulate arguments to pass to drawing
		var args = new AlloyFieldDrawerArgs {
			Editor = this,
			Materials = Targets.Cast<Material>().ToArray(),
			Properties = properties,
			PropertiesSkip = new List<string>(),
			MatInst = MatInst,
			TabGroup = TabGroup,
			AllTabNames = m_allTabs,
			OpenCloseAnim = m_openCloseAnim
		};


		for (var i = 0; i < m_fieldDrawers.Length; i++) {
			var drawer = m_fieldDrawers[i];

			if (drawer == null) {
				continue;
			}

            drawer.Index = i;
            drawer.Property = properties[i];

			if (drawer.ShouldDraw(args)) {
				drawer.Draw(args);
			}
		}

		if (!string.IsNullOrEmpty(args.CurrentTab)) {
			EditorGUILayout.EndFadeGroup();
		}

		GUILayout.Space(10.0f);

		AlloyEditor.DrawAddTabGUI(args.TabsToAdd);

		//If animating -> Repaint
		foreach (var animBool in m_openCloseAnim) {
			if (animBool.Value.isAnimating) {
				MatEditor.Repaint();
				break;
			}
		}
	}

	public override void OnAlloySceneGUI(SceneView sceneView) {
		foreach (var drawer in m_fieldDrawers) {
			if (drawer != null) {
				drawer.OnSceneGUI(Targets.Cast<Material>().ToArray());
			}
		}
    }

    private void RepaintScene() {
        var lastSceneView = SceneView.lastActiveSceneView;

        if (lastSceneView != null)
            lastSceneView.Repaint();
    }
}