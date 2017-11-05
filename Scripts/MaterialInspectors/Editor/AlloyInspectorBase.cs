// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using Alloy;
using UnityEditor;
using PropType = UnityEditor.MaterialProperty.PropType;

static class AlloySceneDrawer {
	static Dictionary<AlloyInspectorBase, MaterialEditor> s_inspectorKeeper = new Dictionary<AlloyInspectorBase, MaterialEditor>();
	static List<AlloyInspectorBase> s_removekeys = new List<AlloyInspectorBase>();
	
	static AlloySceneDrawer() {
		EditorApplication.update += Update;
	}

	static void Update() {
		var keys = s_inspectorKeeper.Keys;
		s_removekeys.Clear();

		foreach (var key in keys) {
			if (s_inspectorKeeper[key] != null) {
				continue;
			}

			key.OnAlloyShaderDisable();
			s_removekeys.Add(key);
		}

		foreach (var key in s_removekeys) {
			s_inspectorKeeper.Remove(key);
		}
	}

	public static void Register(AlloyInspectorBase inspector, MaterialEditor keeper) {
		if (!s_inspectorKeeper.ContainsKey(inspector)) {
			s_inspectorKeeper.Add(inspector, keeper);
		}
	}
}

public class AlloyInspectorBase : ShaderGUI {
	public MaterialEditor MatEditor;
	protected AlloyTabGroup TabGroup;

	public Object[] Targets { get { return MatEditor.targets; } }
	public Material Target { get { return (Material) MatEditor.target; } }

	bool m_inited;
	bool m_isValid = true;

	protected int MatInst {
		get {
			if (Selection.objects.Length == 1 && Selection.activeGameObject != null) {
				var sharedMaterials = Selection.activeGameObject.GetComponent<Renderer>().sharedMaterials;

				if (sharedMaterials != null) {
					return ArrayUtility.IndexOf(sharedMaterials, Target);
				}
			}

			return 0;
		}
	}

	void OnEnable(MaterialProperty[] properties) {
		if (HasMutlipleShaders()) {
			return;
		}

		TabGroup = AlloyTabGroup.GetTabGroup();

		if (Targets.Length > 1) {
			if (MaterialsAreMismatched()) {
				foreach (var target in Targets) {
					var so = new SerializedObject(target);
					so.Update();


					var textures = so.FindProperty("m_SavedProperties.m_TexEnvs");
					ClearMaterialArray(PropType.Texture, textures, properties);

					var floats = so.FindProperty("m_SavedProperties.m_Floats");
					ClearMaterialArray(PropType.Float, floats, properties);

					var colors = so.FindProperty("m_SavedProperties.m_Colors");
					ClearMaterialArray(PropType.Color, colors, properties);
					so.ApplyModifiedProperties();
					so.Dispose();
				}

				m_isValid = false;
				return;
			}
		}

		SceneView.onSceneGUIDelegate += OnAlloySceneGUI;
		OnAlloyShaderEnable();
	}

	bool HasMutlipleShaders() {
		if (MatEditor.targets.Length > 1) {

			return Targets.Any(o => {
				var objMat = o as Material;
				return objMat != null && (Target != null && objMat.shader != Target.shader);
			});
		}

		return false;
	}

	protected virtual void OnAlloyShaderGUI(MaterialProperty[] properties) {
	}

	protected virtual void OnAlloyShaderEnable() {
	}

	public virtual void OnAlloySceneGUI(SceneView sceneView) {
	}


	void ClearMaterialArray(PropType type, SerializedProperty props, MaterialProperty[] properties) {
		for (int i = 0; i < props.arraySize; ++i) {
			var prop = props.GetArrayElementAtIndex(i);
			var nameProp = prop.FindPropertyRelative("first");
			string propName = nameProp.stringValue;

			MaterialProperty matProp = FindProperty(propName, properties, false);

			if (matProp == null || matProp.type != type) {
				props.DeleteArrayElementAtIndex(i);
				--i;
			}
		}

		MatEditor.OnEnable();
	}

	bool MaterialsAreMismatched() {
		var textures = MatEditor.serializedObject.FindProperty("m_SavedProperties.m_TexEnvs");
		if (PropsInArrayMismatched(textures)) {
			return true;
		}

		var floats = MatEditor.serializedObject.FindProperty("m_SavedProperties.m_Floats");
		if (PropsInArrayMismatched(floats)) {
			return true;
		}
		var colors = MatEditor.serializedObject.FindProperty("m_SavedProperties.m_Colors");
		if (PropsInArrayMismatched(colors)) {
			return true;
		}

		return false;
	}
	
	bool PropsInArrayMismatched(SerializedProperty props) {
		string original = props.propertyPath;
		props.Next(true);
		props.Next(true);
		props.Next(true);

		//some weird unity behaviour where it collapses the array 
		if (!props.propertyPath.Contains(original)) {
			return true;
		}

		do {
			var nameProp = props.FindPropertyRelative("first");

			if (nameProp.hasMultipleDifferentValues) {
				return true;
			}
		} while (props.NextVisible(false) && props.propertyPath.Contains(original));

		return false;
	}

	public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties) {
		MatEditor = materialEditor;
		m_isValid = true;

		if (!m_inited) {
			AlloySceneDrawer.Register(this, MatEditor);
			OnEnable(properties);
		}

		if (!m_isValid) {
			EditorGUILayout.LabelField("There's a problem with the inspector. Reselect the material to fix");
			EditorApplication.delayCall += () => MatEditor.Repaint();
			return;
		}

		if (HasMutlipleShaders()) {
			EditorGUILayout.HelpBox("Can't edit materials with different shaders!", MessageType.Warning);
			return;
		}

		GUILayout.Space(10.0f);
		if (MatEditor.isVisible) {
			OnAlloyShaderGUI(properties);
		}

		m_inited = true;
	}

	public virtual void OnAlloyShaderDisable() {
		SceneView.onSceneGUIDelegate -= OnAlloySceneGUI;
	}
}