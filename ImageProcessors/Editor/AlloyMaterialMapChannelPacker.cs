// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEditor;
using UnityEngine;
using Alloy;

public class AlloyMaterialMapChannelPacker : AlloyImageProcessorEditorWindow
{
	[SerializeField] 
	public AlloyCustomImportObject Target;
	
	private const string c_packedMaterialMapSuffix = "_AlloyPM";
	private const string c_detailMaterialMapSuffix = "_AlloyDM";

	[MenuItem(EditorPathRoot + "Material Map Channel Packer")]
	private static void LoadWindow() {
		var all = Resources.FindObjectsOfTypeAll<AlloyMaterialMapChannelPacker>();

		foreach (var channelPacker in all) {
			DestroyImmediate(channelPacker);
		}

		GetWindow<AlloyMaterialMapChannelPacker>(false, "Material Map");
	}

	private MaterialMapChannelPackerDefinition m_definition;

	private void OnDisable() {
		if (!EditorUtility.IsPersistent(Target)) {
			DestroyImmediate(Target);
		}
	}

	private void OnGUI() {
		if (Target == null) {
			Target = CreateInstance<AlloyCustomImportObject>();
		}

		const int editorMinWidth = 236;


		ScrollPosition = EditorGUILayout.BeginScrollView(ScrollPosition, false, false,
		                                                 GUILayout.MinWidth(editorMinWidth),
		                                                 GUILayout.MaxWidth(position.width));

		GUILayout.Space(10.0f);
		GUILayout.BeginHorizontal();

		var toggle1 = GUILayout.Toggle(!Target.IsDetailMap, "Packed", EditorStyles.toolbarButton);
		var toggle2 = GUILayout.Toggle(!toggle1, "Detail", EditorStyles.toolbarButton);
		Target.IsDetailMap = toggle2;

		GUILayout.EndHorizontal();

		DoBaseGUI();

		var enabled = true;

		for (int i = 0; i < 4; ++i) {
			if (Target.SelectedModes[i] == TextureValueChannelMode.Texture && Target.GetTexture(i) == null) {
				enabled = false;
				break;
			}
		}
		
		string curPath;
		var suffix = !Target.IsDetailMap ? c_packedMaterialMapSuffix : c_detailMaterialMapSuffix;

		if (FileEntryAndSaveGUI(suffix, ".png", enabled, ref SaveName, out curPath)) {
			var path = curPath + "/" + SaveName;

			path += !Target.IsDetailMap ? c_packedMaterialMapSuffix : c_detailMaterialMapSuffix;

			var current = Target;

			Target = Instantiate(current) as AlloyCustomImportObject;

			AlloyCustomImportAction.CreatePostProcessingInformation(path + ".asset", current);
			current.GenerateMap();
		}

		EditorGUILayout.EndScrollView();
	}

	public void DoBaseGUI() {
		if (m_definition == null) {
			string path = "Assets/Alloy/ImageProcessors/Editor/packerDefinition.asset";
			m_definition =
				AssetDatabase.LoadAssetAtPath(path, typeof (MaterialMapChannelPackerDefinition)) as
				MaterialMapChannelPackerDefinition;

			if (m_definition == null) {
				m_definition = CreateInstance<MaterialMapChannelPackerDefinition>();

				AssetDatabase.CreateAsset(m_definition, path);
			}
		}

		// Texture editors.
		if (!Target.IsDetailMap) {
			TextureValueChannelModeSelectionGUI("Metallic", m_definition.MetalText, m_definition.MetalColor, 0, Target);
		}
		else {
			Target.SelectedModes[0] = TextureValueChannelMode.Black;
		}

		TextureValueChannelModeSelectionGUI("Occlusion", m_definition.OcclusionText, m_definition.OcclusionColor, 1, Target);


		if (!Target.IsDetailMap) {
			TextureValueChannelModeSelectionGUI("Specularity", m_definition.SpecularityTex, m_definition.SpecularityColor, 2,
			                                    Target);

			TextureValueChannelModeSelectionGUI("Roughness", m_definition.RoughnessText, m_definition.RoughnessColor, 3, Target);
		}
		else {
			Target.SelectedModes[2] = TextureValueChannelMode.Black;
			Target.SelectedModes[3] = TextureValueChannelMode.Black;
		}

		NormalTextureGUI("Normal Map", m_definition.NormalTex, m_definition.NormalColor, Target);

		GUILayout.BeginVertical("HelpBox");
		
		GUILayout.BeginHorizontal();
		GUILayout.Label("Variance Bias", EditorStyles.boldLabel);
		GUILayout.EndHorizontal();

		GUILayout.BeginHorizontal();
		
		GUI.color = Color.gray;
		GUILayout.Label(m_definition.VarianceText);
		
		GUI.color = Color.white;
		GUILayout.FlexibleSpace();

		Target.VarianceBias = EditorGUILayout.Slider(Target.VarianceBias, 0.0f, 1.0f, GUILayout.Width(120.0f));

		GUILayout.EndHorizontal();

		GUILayout.BeginHorizontal();
		GUILayout.Label("Auto regenerate", EditorStyles.boldLabel);
		GUILayout.EndHorizontal();

		GUILayout.BeginHorizontal();
		
		GUI.color = Color.gray;
		GUILayout.Label(m_definition.AutoRegenerateText);
		GUI.color = Color.white;
		GUILayout.FlexibleSpace();
		Target.DoAutoRegenerate = EditorGUILayout.Toggle("", Target.DoAutoRegenerate, GUILayout.Width(120.0f));

		GUILayout.EndHorizontal();

		GUILayout.EndVertical();

		EditorUtility.SetDirty(Target);
	}
}