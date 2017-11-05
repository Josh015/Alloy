// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEditor;
using UnityEngine;

namespace Alloy
{
	public enum TextureVisualizeMode
	{
		None,
		RGB,
		R,
		G,
		B,
		A,
		NRM
	}

	public class AlloyTextureDrawer
	{
		public AlloyInspectorBase VarProvider;
		public AlloyTextureDrawerSettings Settings;

		protected virtual string TextureProp {
			get { return "m_Texture"; }
		}

		private int vizIndex;

		private TextureVisualizeMode Mode {
			get { return vizIndex == 0 ? TextureVisualizeMode.None : Settings.VisualizeModes[vizIndex - 1]; }
		}

		private Material Material {
			get { return VarProvider.target as Material; }
		}

		public SerializedProperty Property;
		public string Label;
		public string ShaderVarName;
		public int Inst;

		private AlloyTabGroup m_tabGroup;

		//Passed in by the base editor
		public AlloyTextureDrawer() {
			m_tabGroup = AlloyInspectorBase.GetTabGroup();
		}

		protected bool IsOpen {
			get { return m_tabGroup.IsOpen(Label + Inst); }
		}

		private void AdvanceMode() {
			vizIndex = (vizIndex + 1) % (Settings.VisualizeModes.Length + 1);
		}

		private string GetVisualizeButtonText() {
			return Mode == TextureVisualizeMode.None ? "Visualize" : Mode.ToString();
		}

		private void TextureField(float size, SerializedProperty prop) {
			var rawRef = prop.objectReferenceValue;
			var isCube = Settings.IsCubemap;

			if (rawRef == null 
			    && !prop.hasMultipleDifferentValues 
			    && (!IsOpen || !Settings.HasScaleAndOffset)) {
				prop.objectReferenceValue = EditorGUILayout.ObjectField(null, isCube ? typeof (Cubemap) : typeof (Texture),
				                                                        false, GUILayout.Width(100.0f), GUILayout.Height(16.0f));
				
				return;
			}

			EditorGUI.BeginProperty(new Rect(), null, prop);

			EditorGUI.BeginChangeCheck();

			var tex = EditorGUILayout.ObjectField(rawRef, isCube ? typeof (Cubemap) : typeof (Texture),
			                                      false,
			                                      GUILayout.Width(size - 20.0f),
			                                      GUILayout.Height((size - 20.0f) * 0.9f));

			if (EditorGUI.EndChangeCheck()) {
				prop.objectReferenceValue = tex;
			}

			EditorGUI.EndProperty();
		}

		public void DrawTextureGUI() {
			var texture = Property.FindPropertyRelative(TextureProp);
			var curTex = texture.objectReferenceValue as Texture;

			GUILayout.Space(9.0f);

			GUILayout.BeginHorizontal();

			EditorGUILayout.BeginVertical();

			float oldWidth = EditorGUIUtility.labelWidth;
			EditorGUIUtility.labelWidth = 80.0f;

			if (!Settings.HasScaleAndOffset) {
				GUILayout.Label(Label);
			}

			if (Settings.HasScaleAndOffset 
			    && m_tabGroup.Foldout(Label, ShaderVarName + Inst, GUILayout.Width(10.0f))) {
				var sc = string.IsNullOrEmpty(Settings.ScaleFieldName) ? "Tiling" : Settings.ScaleFieldName;
				var off = string.IsNullOrEmpty(Settings.ScaleFieldName) ? "Offset" : Settings.OffsetFieldName;

				if (string.IsNullOrEmpty(Settings.ScaleOffsetShaderField)) {
					var scale = Property.FindPropertyRelative("m_Scale");
					var offset = Property.FindPropertyRelative("m_Offset");

					Vector2Field(scale, sc);
					Vector2Field(offset, off);
				} else {
					CustomControls(sc, off);
				}

				if (!string.IsNullOrEmpty(Settings.VelocityShaderField)) {
					var prop = VarProvider.GetProperty(Settings.VelocityShaderField);

					EditorGUI.BeginProperty(new Rect(), null, prop);

					var name = Settings.VelocityShaderField;
					var old = EditorGUIUtility.labelWidth;

					EditorGUIUtility.labelWidth = 50.0f;
					
					if (Material != null) {
						var curVal = Material.GetVector(name);
						
						EditorGUI.BeginChangeCheck();
						
						var velocity = EditorGUILayout.Vector2Field("Velocity", new Vector2(curVal.x, curVal.y), GUILayout.Width(190.0f));

						if (EditorGUI.EndChangeCheck()) {
							Undo.RecordObject(Material, "Set Material Velocity");
							Material.SetVector(name, new Vector2(velocity.x, velocity.y));
						}
					}
					
					EditorGUI.EndProperty();

					EditorGUIUtility.labelWidth = old;
				}

				if (!Settings.IsCubemap && !texture.hasMultipleDifferentValues) {
					GUI.enabled = curTex != null;
					DrawVisualizeButton();
					GUI.enabled = true;
				}

				EditorGUILayout.EndVertical();

				TextureField(100.0f, texture);
			} else {
				if (curTex != null && !texture.hasMultipleDifferentValues) {
					string warning = GetWarningString(texture);

					if (!string.IsNullOrEmpty(warning)) {
						EditorGUILayout.HelpBox(warning, MessageType.Warning);
					} else {
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

				if (curTex != null 
				    && !texture.hasMultipleDifferentValues) {
					DrawVisualizeButton();
				}

				GUILayout.EndVertical();

				GUILayout.FlexibleSpace();
				TextureField(74.0f, texture);
			}

			EditorGUIUtility.labelWidth = oldWidth;

			GUILayout.EndHorizontal();

			if (IsOpen) {
				GUILayout.Space(10.0f);
			}
		}

		private string GetWarningString(SerializedProperty texture) {
			//normal map warning
			if (Settings.VisualizeModes == null) {
				return string.Empty;
			}

			if (ArrayUtility.Contains(Settings.VisualizeModes, TextureVisualizeMode.NRM)) {
				if (!texture.hasMultipleDifferentValues && texture.objectReferenceValue != null) {
					string path = AssetDatabase.GetAssetPath(texture.objectReferenceValue);

					if (!string.IsNullOrEmpty(path)) {
						var imp = AssetImporter.GetAtPath(path);

						var importer = imp as TextureImporter;

						if (importer != null && !importer.normalmap) {
							return "Texture not marked as normal map";
						}
					}
				}
			}

			return string.Empty;
		}

		private void DrawVisualizeButton()
		{
			if (Settings.VisualizeModes != null && Settings.VisualizeModes.Length > 0 && Selection.activeGameObject && Selection.objects.Length == 1)
			{
				if (GUILayout.Button(GetVisualizeButtonText(), EditorStyles.toolbarButton, GUILayout.Width(70.0f)))
				{
					AdvanceMode();

					EditorApplication.delayCall += SceneView.RepaintAll;
				}
			}
		}

		private Material m_visualizeMat;

		private Material VisualizeMaterial {
			get {
				if (m_visualizeMat == null) {
					m_visualizeMat = new Material(Shader.Find("Hidden/Alloy Visualize")) {hideFlags = HideFlags.HideAndDontSave};
				}

				return m_visualizeMat;
			}
		}

		private Vector4 GetTextureTransformation() {
			Vector4 result;
			var mainOff = Material.mainTextureOffset;
			var mainScale = Material.mainTextureScale;

			// This setup should transparently work with the 2.1 and 3.x systems.
			if (ShaderVarName == "_MainTex") {
			    result = new Vector4(mainOff.x, mainOff.y, mainScale.x, mainScale.y);
			} else if (!string.IsNullOrEmpty(Settings.ScaleOffsetShaderField)) {
				// Legacy 2.1 path.
				var mat = Material.GetVector(Settings.ScaleOffsetShaderField);
				result = new Vector4(mat.x + mainOff.x, mat.y + mainOff.y, mat.z * mainScale.x, mat.w * mainScale.y);
			} else if (Settings.HasScaleAndOffset) {
				var offset = Property.FindPropertyRelative("m_Offset").vector2Value;
				var scale = Property.FindPropertyRelative("m_Scale").vector2Value;

				result = new Vector4(offset.x, offset.y, scale.x, scale.y);
			} else if (!string.IsNullOrEmpty(Settings.ParentTextureField)) { 
				var parent = Settings.ParentTextureField;
				var offset = Material.GetTextureOffset(parent);
				var scale = Material.GetTextureScale(parent);

				result = new Vector4(offset.x, offset.y, scale.x, scale.y);
			} else {
				// TODO: Should we mess up the visual here to indicate there is a problem?
				result = new Vector4(mainOff.x, mainOff.y, mainScale.x, mainScale.y);
			}

			return result;
		}

		private Renderer m_oldSelect;

		public void OnSceneGUI() {
			if (Mode == TextureVisualizeMode.None || Selection.activeGameObject == null) {
				if (m_oldSelect != null) {
					EditorUtility.SetSelectedWireframeHidden(m_oldSelect, false);
				}

				return;
			}

			var texture = Property.FindPropertyRelative(TextureProp);
			var curTex = texture.objectReferenceValue as Texture;

			if (Settings.IsCubemap || Mode == TextureVisualizeMode.None) {
				return;
			}

			var trans = GetTextureTransformation();

			VisualizeMaterial.SetVector("_Trans", trans);
			VisualizeMaterial.SetTexture("_MainTex", curTex);
			VisualizeMaterial.SetFloat("_Mode", (int)Mode);

			var target = Selection.activeGameObject.renderer;

			if (target != m_oldSelect && m_oldSelect != null)
			{
				EditorApplication.delayCall += SceneView.RepaintAll;
				EditorUtility.SetSelectedWireframeHidden(target, false);
				return;
			}

			m_oldSelect = target;

			Mesh mesh = null;
			var submeshIndex = 0;
			var meshFilter = target.GetComponent<MeshFilter>();
			var meshRenderer = target.GetComponent<MeshRenderer>();
			
			if (meshFilter != null && meshRenderer != null) {
				mesh = meshFilter.sharedMesh;
				submeshIndex = GetMaterialSubmeshIndex(Material.name, meshRenderer);
			}
			
			if (mesh == null) {
				var skinnedMeshRenderer = target.GetComponent<SkinnedMeshRenderer>();
				
				if (skinnedMeshRenderer != null) {
					mesh = skinnedMeshRenderer.sharedMesh;
					submeshIndex = GetMaterialSubmeshIndex(Material.name, skinnedMeshRenderer);
				}
			}
			
			if (mesh != null) {
				EditorUtility.SetSelectedWireframeHidden(target, true);
				
				Graphics.DrawMesh (mesh, target.localToWorldMatrix, VisualizeMaterial, 0, SceneView.currentDrawingSceneView.camera, submeshIndex);
				SceneView.currentDrawingSceneView.Repaint ();
			} else {
				Debug.LogError("Game object does not have a mesh source.");
			}
		}

		private int GetMaterialSubmeshIndex(string materialName, Renderer renderer) {
			var submeshIndex = 0;
			
			if (renderer != null) {
				var rendererMaterials = renderer.sharedMaterials;
				
				if (rendererMaterials.Length > 1) {
					for (int i = 0; i < rendererMaterials.Length; i++) {
						if (rendererMaterials[i].name == materialName){
							submeshIndex = i;
							break;
						}
					}
				}
			}
			
			return submeshIndex;
		}

		private void Vector2Field(SerializedProperty prop, string label) {
			float old = EditorGUIUtility.labelWidth;
			EditorGUIUtility.labelWidth = 50.0f;
			EditorGUILayout.PropertyField(prop, new GUIContent(label), GUILayout.Width(190.0f));
			EditorGUIUtility.labelWidth = old;
		}

		private void CustomControls(string sc, string off) {
			var prop = VarProvider.GetProperty(Settings.ScaleOffsetShaderField);

			EditorGUI.BeginProperty(new Rect(), null, prop);

			var name = Settings.ScaleOffsetShaderField;
			var old = EditorGUIUtility.labelWidth;

			EditorGUIUtility.labelWidth = 50.0f;

			if (Material != null) {
				var curVal = Material.GetVector(name);

				EditorGUI.BeginChangeCheck();

				var scale = EditorGUILayout.Vector2Field(sc, new Vector2(curVal.x, curVal.y), GUILayout.Width(190.0f));
				var offset = EditorGUILayout.Vector2Field(off, new Vector2(curVal.z, curVal.w), GUILayout.Width(190.0f));

				if (EditorGUI.EndChangeCheck()) {
					Undo.RecordObject(Material, "Set Material Tiling");
					Material.SetVector(name, new Vector4(scale.x, scale.y, offset.x, offset.y));
				}
			}

			EditorGUI.EndProperty();

			EditorGUIUtility.labelWidth = old;
		}
	}
}