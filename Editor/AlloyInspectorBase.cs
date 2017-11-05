// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Alloy
{
	[CanEditMultipleObjects]
	public class AlloyInspectorBase : MaterialEditor
	{
		protected AlloyTabGroup TabGroup;
		private Dictionary<string, SerializedProperty> m_properties;
		private Shader m_oldShader;

		protected MaterialProperty[] MaterialProperties;

		protected string[] MaterialPropNames;

		private SubstanceImporter m_importer;

		protected int MatInst {
			get {
				if (Selection.objects.Length == 1 && Selection.activeGameObject != null) {
					return ArrayUtility.IndexOf(Selection.activeGameObject.renderer.sharedMaterials, target);
				}

				return 0;
			}
		}

		public override void OnEnable() {
			base.OnEnable();

			if (HasMutlipleShaders()) {
				return;
			}

			SceneView.onSceneGUIDelegate += OnAlloySceneGUI;

			hideFlags = HideFlags.HideAndDontSave;
			TabGroup = GetTabGroup();

			m_properties = new Dictionary<string, SerializedProperty>();
			InitAllProps();

			OnAlloyShaderEnable();
		}

		private bool HasMutlipleShaders() {
			if (targets.Length > 1) {
				foreach (var o in targets) {
					if ((o as Material).shader != (targets[0] as Material).shader) {
						return true;
					}
				}
			}

			return false;
		}

		public override void OnInspectorGUI() {
			if (HasMutlipleShaders()) {
				EditorGUILayout.HelpBox("Can't edit materials with different shaders!", MessageType.Warning);
				return;
			}

			serializedObject.Update();

			GUILayout.Space(10.0f);

			var material = target as Material;

			if (material != null) {
				var ns = material.shader;

				if (ns != m_oldShader) {
					InitAllProps();
					m_oldShader = ns;
				}
			}

			if (isVisible && !HasMutlipleShaders()) {
				OnAlloyShaderGUI();
				DrawSubstanceProperties();
			}

			serializedObject.ApplyModifiedProperties();
		}

		protected virtual void OnAlloyShaderGUI() {
		}

		protected virtual void OnAlloyShaderEnable() {
		}

		//base API functions
		public SerializedProperty GetProperty(string varName) {
			if (!m_properties.ContainsKey(varName)) {
				return null;
			}

			return CheckProp(varName);
		}

		private SerializedProperty CheckProp(string varName) {
			if (!m_properties.ContainsKey(varName)) {
				return null;
			}

			return m_properties[varName];
		}

		private void InitAllProps() {
			m_properties.Clear();

			m_drawers.Clear();

			var textures = serializedObject.FindProperty("m_SavedProperties.m_TexEnvs");

			AddPropsFromArray(textures);

			var floats = serializedObject.FindProperty("m_SavedProperties.m_Floats");
			AddPropsFromArray(floats);

			var colors = serializedObject.FindProperty("m_SavedProperties.m_Colors");
			AddPropsFromArray(colors);
		}

		private void AddPropsFromArray(SerializedProperty props) {
			for (int i = 0; i < props.arraySize; ++i) {
				var prop = props.GetArrayElementAtIndex(i);

				var valueProp = prop.FindPropertyRelative("second");

				string propName = prop.FindPropertyRelative("first.name").stringValue;

				m_properties.Add(propName, valueProp);
			}
		}

		private Dictionary<string, AlloyTextureDrawer> m_drawers = new Dictionary<string, AlloyTextureDrawer>();

		protected void AlloyFieldProperty(AlloyFieldDefinition field)
		{
			var fieldName = field.Name;
			var fieldDisplayName = field.DisplayName;

			if (!MaterialPropNames.Contains(fieldName))
			{
				return;
			}

			// This exists to accomodate the special case for _MainTex & _SpecTex that
			// have to have different display names based on the shader using it.
			if (string.IsNullOrEmpty(fieldDisplayName))
			{
				fieldDisplayName = MaterialProperties.First(property => property.name == fieldName).displayName;
			}

			if (field.IsTexture)
			{
				TextureField(fieldName, fieldDisplayName, field.TextureSettings);
			}
			else if (field.IsDropDown)
			{
				DropdownField(fieldName, 70);
			}
			else
			{
				if (field.HasMin || field.HasMax)
				{
					if (field.HasMin && field.HasMax)
					{
						FloatFieldSlider(fieldName, fieldDisplayName, field.Min, field.Max);
					}

					else if (field.HasMin)
					{
						FloatFieldMin(fieldName, fieldDisplayName, field.Min);
					}
					else
					{
						FloatFieldMax(fieldName, fieldDisplayName, field.Max);
					}
				}
				else
				{
					PropField(fieldName, fieldDisplayName);
				}
			}
		}

		protected void TextureField(string varName, string displayName, AlloyTextureDrawerSettings settings) {
			var texProp = CheckProp(varName);

			// Sync this texture's transforms with it's parent's!
			// Needed for baking and third party tools integration!
			if (!string.IsNullOrEmpty(settings.ParentTextureField)) {
				var parentProp = CheckProp(settings.ParentTextureField);

				if (parentProp != null) {
					var parentScale = parentProp.FindPropertyRelative("m_Scale").vector2Value;
					var parentOffset = parentProp.FindPropertyRelative("m_Offset").vector2Value;
					
					var scale = texProp.FindPropertyRelative("m_Scale");
					var offset = texProp.FindPropertyRelative("m_Offset");

					scale.vector2Value = new Vector2(parentScale.x, parentScale.y);
					offset.vector2Value = new Vector2(parentOffset.x, parentOffset.y);
				}
			}

			if (!m_drawers.ContainsKey(varName)) {
				m_drawers[varName] = new AlloyTextureDrawer();
			}

			var draw = m_drawers[varName];
			draw.Property = texProp;
			draw.Label = GetDispName(displayName, varName).text;
			draw.Settings = settings;
			draw.ShaderVarName = varName;
			draw.VarProvider = this;
			draw.Inst = MatInst;
			draw.DrawTextureGUI();
		}

		private GUIContent GetDispName(string displayName, string varName) {
			if (string.IsNullOrEmpty(displayName)) {
				return new GUIContent(ObjectNames.NicifyVariableName(varName));
			}

			return new GUIContent(displayName);
		}

		protected void FloatFieldMin(string varName, string displayName, float min) {
			var prop = CheckProp(varName);

			prop.floatValue = EditorGUILayout.FloatField(GetDispName(displayName, varName), prop.floatValue);

			prop.floatValue = Mathf.Max(prop.floatValue, min);
		}

		protected void FloatFieldMax(string varName, string displayName, float max) {
			var prop = CheckProp(varName);

			prop.floatValue = EditorGUILayout.FloatField(GetDispName(displayName, varName), prop.floatValue);

			prop.floatValue = Mathf.Min(prop.floatValue, max);
		}

		protected void FloatFieldSlider(string varName, string displayName, float min, float max) {
			var prop = CheckProp(varName);

			prop.floatValue = EditorGUILayout.Slider(GetDispName(displayName, varName), prop.floatValue, min, max);

			prop.floatValue = Mathf.Clamp(prop.floatValue, min, max);
		}

		public void DropdownField(string varName, float dropWidth) {
			var matProp = GetMaterialProperty(targets, varName);

			float old = EditorGUIUtility.labelWidth;
			EditorGUIUtility.labelWidth = Screen.width - dropWidth - 20.0f;

			ShaderProperty(matProp, ObjectNames.NicifyVariableName(varName));

			EditorGUIUtility.labelWidth = old;
		}

		public void PropField(string varName, string displayName, params GUILayoutOption[] options) {
			SerializedProperty prop = CheckProp(varName);

			if (prop != null) {
				EditorGUILayout.PropertyField(prop, GetDispName(displayName, varName), true, options);
			}
		}

		public override void OnDisable() {
			base.OnDisable();

			if (m_substanceEditor != null) {
				DestroyImmediate(m_substanceEditor);
			}

			SceneView.onSceneGUIDelegate -= OnAlloySceneGUI;
		}

		public void OnAlloySceneGUI(SceneView sceneView) {
			foreach (var drawer in m_drawers) {
				drawer.Value.OnSceneGUI();
			}
		}

		public static AlloyTabGroup GetTabGroup() {
			var o = Resources.FindObjectsOfTypeAll<AlloyTabGroup>();

			AlloyTabGroup tab;

			if (o.Length != 0) {
				tab = o[0];
			} else {
				tab = CreateInstance<AlloyTabGroup>();
				tab.hideFlags = HideFlags.HideAndDontSave;
				tab.name = "AlloyTabGroup";
			}

			return tab;
		}

		private Editor m_substanceEditor;
		private Shader m_prevShader;
		private SubstanceImporter m_substanceImporter;

		void DrawSubstanceProperties() {
			var procMat = target as ProceduralMaterial;

			if (procMat == null) {
				return;
			}

			if (m_substanceImporter == null) {
				m_substanceImporter = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(procMat)) as SubstanceImporter;
			}

			if (procMat.shader != m_prevShader) {
				m_substanceImporter.OnShaderModified(procMat);
			}

			GUI.changed = false;

			m_prevShader = procMat.shader;

			if (m_substanceEditor == null) {
				m_substanceEditor = AlloySbarEditor.CreateSubstanceEditor(target as ProceduralMaterial);

			
			}

			AlloySbarEditor.DrawSubstanceInspector(m_substanceEditor);
		}
	}
}