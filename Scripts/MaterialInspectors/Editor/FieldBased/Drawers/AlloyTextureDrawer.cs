// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using Alloy;
using UnityEditor;
using UnityEditor.AnimatedValues;
using UnityEngine;

public class AlloyTextureFieldDrawer : AlloyFieldDrawer {
	public enum TextureVisualizeMode {
		None,
		RGB,
		R,
		G,
		B,
		A,
		NRM
	}

	public string ParentTexture {
		get { return m_parentTexture; }
		set {
			m_parentTexture = value;
			m_hasParentTexture = !string.IsNullOrEmpty(value);
		}
	}

	public TextureVisualizeMode[] DisplayModes;
	public bool Controls = true;

	protected int TexInst;

	string m_parentTexture = string.Empty;
	bool m_hasParentTexture;

	protected AlloyTabGroup TabGroup;

	AnimBool m_tabOpen = new AnimBool(false);
	bool m_firstDraw = true;
	int m_vizIndex;

	Material m_visualizeMat;
	Renderer m_oldSelect;

	static GUIContent[] s_uvModes = {new GUIContent("UV0"), new GUIContent("UV1")};
	static GUILayoutOption[] s_texLayout = new GUILayoutOption[2];

	Material VisualizeMaterial {
		get {
			if (m_visualizeMat == null) {
				m_visualizeMat = new Material(Shader.Find("Hidden/Alloy Visualize")) {hideFlags = HideFlags.HideAndDontSave};
			}

			return m_visualizeMat;
		}
	}

	protected virtual string TextureProp { get { return "m_Texture"; } }

	TextureVisualizeMode Mode {
		get { return m_vizIndex == 0 ? TextureVisualizeMode.None : DisplayModes[m_vizIndex - 1]; }
	}

	protected string SaveName { get { return Property.name + TexInst; } }
	protected bool IsOpen { get { return TabGroup.IsOpen(SaveName); } }

	//Passed in by the base editor
	public AlloyTextureFieldDrawer(AlloyInspectorBase editor, MaterialProperty property)
		: base(editor, property) {
		TabGroup = AlloyTabGroup.GetTabGroup();

		m_tabOpen.value = TabGroup.IsOpen(SaveName);
		m_tabOpen.speed = 4.0f;
	}


	void AdvanceMode() {
		m_vizIndex = (m_vizIndex + 1) % (DisplayModes.Length + 1);
	}

	string GetVisualizeButtonText() {
		return Mode == TextureVisualizeMode.None ? "Visualize" : Mode.ToString();
	}

	void TextureField(float size, MaterialProperty prop, AlloyFieldDrawerArgs args) {
		var rawRef = prop.textureValue;

		if (rawRef == null
		    && !prop.hasMixedValue
		    && (!IsOpen || m_hasParentTexture)) {

			s_texLayout[0] = GUILayout.Width(100.0f);
			s_texLayout[1] = GUILayout.Height(16.0f);
		}
		else {
			s_texLayout[0] = GUILayout.Width(size - 20.0f);
			s_texLayout[1] = GUILayout.Height((size - 20.0f) * 0.9f);
		}

		BeginMaterialProperty(Property);

		var tex = EditorGUILayout.ObjectField(rawRef, typeof(Texture), false, s_texLayout) as Texture;

		if (EndMaterialProperty()) {
			prop.textureValue = tex;
		}
	}

	bool DrawWarningString(MaterialProperty texture) {
		//normal map warning
		if (DisplayModes == null) {
			return false;
		}

		if (ArrayUtility.Contains(DisplayModes, TextureVisualizeMode.NRM)) {
			if (texture.hasMixedValue || texture.textureValue == null) {
				return false;
			}

			string path = AssetDatabase.GetAssetPath(texture.textureValue);

			if (!string.IsNullOrEmpty(path)) {
				var imp = AssetImporter.GetAtPath(path);
				var importer = imp as TextureImporter;

				// If the texture isn't a Normal Map, offer to convert it.
				if (importer != null && importer.textureType != TextureImporterType.NormalMap) {
					GUILayout.BeginHorizontal();
					EditorGUILayout.HelpBox("Texture not marked as normal map", MessageType.Warning, true);

					var rect = GUILayoutUtility.GetLastRect();

					rect.xMin += rect.width / 2;

					GUILayout.BeginVertical();

					GUILayout.Space(14.0f);

					if (GUILayout.Button("Fix now", EditorStyles.toolbarButton, GUILayout.Width(60.0f))) {
						importer.textureType = TextureImporterType.NormalMap;
						AssetDatabase.ImportAsset(path);
					}

					GUILayout.EndVertical();

					GUILayout.EndHorizontal();

					return true;
				}
			}
		}

		return false;
	}

	void DrawVisualizeButton() {
		if (DisplayModes != null && DisplayModes.Length > 0
		    && Selection.activeGameObject && Selection.objects.Length == 1) {
			if (GUILayout.Button(GetVisualizeButtonText(), EditorStyles.toolbarButton, GUILayout.Width(70.0f))) {
				AdvanceMode();
				EditorApplication.delayCall += SceneView.RepaintAll;
			}
		}
	}

	public override void OnDisable() {
		if (Mode != TextureVisualizeMode.None) {
			if (m_oldSelect != null) {
				EditorUtility.SetSelectedRenderState(m_oldSelect, EditorSelectedRenderState.Highlight);
			}

			m_vizIndex = 0;
		}
	}

	public override void OnSceneGUI(Material[] materials) {
		if (materials.Length > 1) {
			return;
		}

		var material = materials[0];

		if (Mode == TextureVisualizeMode.None || Selection.activeGameObject == null || Selection.objects.Length != 1) {
			if (m_oldSelect != null) {
				EditorUtility.SetSelectedRenderState(m_oldSelect, EditorSelectedRenderState.Highlight);
			}

			return;
		}

		var curTex = Property.textureValue;

		if (Mode == TextureVisualizeMode.None) {
			return;
		}

		var trans = Property.textureScaleAndOffset;

		var uvMode = 0.0f;
		var uvName = !m_hasParentTexture ? Property.name + "UV" : m_parentTexture + "UV";

		if (material.HasProperty(uvName)) {
			uvMode = material.GetFloat(uvName);
		}

		VisualizeMaterial.SetTexture("_MainTex", curTex);
		VisualizeMaterial.SetFloat("_Mode", (int) Mode);
		VisualizeMaterial.SetVector("_Trans", trans);
		VisualizeMaterial.SetFloat("_UV", uvMode);

		var target = Selection.activeGameObject.GetComponent<Renderer>();

		if (target != m_oldSelect && m_oldSelect != null) {
			EditorApplication.delayCall += SceneView.RepaintAll;
			EditorUtility.SetSelectedRenderState(target, EditorSelectedRenderState.Highlight);
			return;
		}

		m_oldSelect = target;

		Mesh mesh = null;
		var meshFilter = target.GetComponent<MeshFilter>();
		var meshRenderer = target.GetComponent<MeshRenderer>();

		if (meshFilter != null && meshRenderer != null) {
			mesh = meshFilter.sharedMesh;
		}

		if (mesh == null) {
			var skinnedMeshRenderer = target.GetComponent<SkinnedMeshRenderer>();

			if (skinnedMeshRenderer != null) {
				mesh = skinnedMeshRenderer.sharedMesh;
			}
		}

		if (mesh != null) {
			EditorUtility.SetSelectedRenderState(target, EditorSelectedRenderState.Hidden);
			Graphics.DrawMesh(mesh, target.localToWorldMatrix, VisualizeMaterial, 0, SceneView.currentDrawingSceneView.camera,
				TexInst);
			SceneView.currentDrawingSceneView.Repaint();
		}
		else {
			Debug.LogError("Game object does not have a mesh source.");
		}
	}

	public override void Draw(AlloyFieldDrawerArgs args) {
		TexInst = args.MatInst;

		if (m_firstDraw) {
			OnFirstDraw();
			m_firstDraw = false;
		}

		var curTex = Property.textureValue;
		GUILayout.Space(9.0f);
		GUILayout.BeginHorizontal();
		EditorGUILayout.BeginVertical();

		float oldWidth = EditorGUIUtility.labelWidth;
		EditorGUIUtility.labelWidth = 80.0f;

		bool drewOpen = false;

		if (m_hasParentTexture || !Controls) {
			GUILayout.Label(DisplayName);
		}
		else {
			bool isOpen = TabGroup.Foldout(DisplayName, SaveName, GUILayout.Width(10.0f));
			m_tabOpen.target = isOpen;

			if (EditorGUILayout.BeginFadeGroup(m_tabOpen.faded)) {
				drewOpen = true;
				DrawTextureControls(args);
			}

			EditorGUILayout.EndFadeGroup();
		}

		if ((EditorGUILayout.BeginFadeGroup(1.0f - m_tabOpen.faded)
		     || !Controls)
		    && curTex != null
		    && !Property.hasMixedValue) {

			if (!DrawWarningString(Property)) {
				var oldCol = GUI.color;
				GUI.color = EditorGUIUtility.isProSkin ? Color.gray : new Color(0.3f, 0.3f, 0.3f);

				string name = curTex.name;
				if (name.Length > 17) {
					name = name.Substring(0, 14) + "..";
				}
				GUILayout.Label(name + " (" + curTex.width + "x" + curTex.height + ")", EditorStyles.whiteLabel);
				GUI.color = oldCol;
			}
		}

		EditorGUILayout.EndFadeGroup();

		if (curTex != null
		    && (!m_hasParentTexture || Controls)
		    && !Property.hasMixedValue) {
			DrawVisualizeButton();
		}

		if (drewOpen) {
			EditorGUILayout.EndVertical();
			TextureField(Mathf.Lerp(74.0f, 100.0f, m_tabOpen.faded), Property, args);
		}
		else {
			GUILayout.EndVertical();

			GUILayout.FlexibleSpace();
			TextureField(74.0f, Property, args);
		}

		EditorGUIUtility.labelWidth = oldWidth;
		GUILayout.EndHorizontal();

		if (IsOpen) {
			GUILayout.Space(10.0f);
		}


		if (m_tabOpen.isAnimating) {
			args.Editor.MatEditor.Repaint();
		}
	}

	protected void DrawTextureControls(AlloyFieldDrawerArgs args) {

		string velName = Property.name + "Velocity";
		var scrollProp = args.GetMaterialProperty(velName);

		string spinName = Property.name + "Spin";
		var spinProp = args.GetMaterialProperty(spinName);

		string uvName = Property.name + "UV";
		var uvProp = args.GetMaterialProperty(uvName);


		BeginMaterialProperty(Property);
		var trans = Property.textureScaleAndOffset;

		Vector2 tileVal = EditorGUILayout.Vector2Field("Tiling", new Vector2(trans.x, trans.y));
		Vector2 offsetVal = EditorGUILayout.Vector2Field("Offset", new Vector2(trans.z, trans.w));

		trans.x = tileVal.x;
		trans.y = tileVal.y;
		trans.z = offsetVal.x;
		trans.w = offsetVal.y;


		if (scrollProp != null) {
			BeginMaterialProperty(scrollProp);
			Vector2 curScroll = EditorGUILayout.Vector2Field("Scroll", scrollProp.vectorValue);

			if (EndMaterialProperty()) {
				scrollProp.vectorValue = curScroll;
			}
		}

		float old = EditorGUIUtility.labelWidth;
		EditorGUIUtility.labelWidth = 75.0f;

		if (spinProp != null) {
			BeginMaterialProperty(spinProp);

			float spin = spinProp.floatValue * Mathf.Rad2Deg;
			spin = EditorGUILayout.FloatField(new GUIContent("Spin"), spin, GUILayout.Width(180.0f));

			if (EndMaterialProperty()) {
				spinProp.floatValue = spin * Mathf.Deg2Rad;
			}
		}

		if (uvProp != null) {
			BeginMaterialProperty(uvProp);

			float newVal = EditorGUILayout.Popup(new GUIContent("UV Set"), (int) uvProp.floatValue, s_uvModes,
				GUILayout.Width(180.0f));

			if (EndMaterialProperty()) {
				uvProp.floatValue = newVal;
			}
		}

		EditorGUIUtility.labelWidth = old;

		if (EndMaterialProperty()) {
			Property.textureScaleAndOffset = trans;
		}
	}

	void OnFirstDraw() {
		m_tabOpen.value = IsOpen;
	}
}