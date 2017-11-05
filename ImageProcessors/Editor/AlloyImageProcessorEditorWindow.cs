// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEditor;
using UnityEngine;
using System;
using System.IO;
using Object = UnityEngine.Object;

namespace Alloy
{
	public class AlloyImageProcessorEditorWindow : EditorWindow
	{
		protected enum TextureColorChannelMode
		{
			Color,
			Texture
		}

		protected const string EditorPathRoot = "Window/Alloy/";
		protected const string SelectTextureOrColorErrorMessage = "Please select a texture or a color.";
		protected const string SelectTextureOrValueErrorMessage = "Please select a texture or a value.";
		protected const string EnterFilenameErrorMessage = "Please enter a filename.";

		private const string c_assetPathRoot = "Assets";
		private const string c_defaultFilename = "Output";

		protected Vector2 ScrollPosition = new Vector2(0, 0);

		[SerializeField] protected string SaveName = string.Empty;

		private void OnEnable() {
			SaveName = GetSelectedOrDefaultFilename();
		}

		private void OnSelectionChange() {
			Repaint();
			SaveName = GetSelectedOrDefaultFilename();
		}

		protected string GetSelectedAssetPath() {
			var path = c_assetPathRoot;

			foreach (Object obj in Selection.GetFiltered(typeof (Object), SelectionMode.Assets)) {
				path = AssetDatabase.GetAssetPath(obj);

				if (File.Exists(path)) {
					path = Path.GetDirectoryName(path);
				}

				break;
			}

			return path;
		}

		protected string GetSelectedOrDefaultFilename() {
			string fileName;

			var path = AssetDatabase.GetAssetPath(Selection.activeObject);

			if (string.IsNullOrEmpty(path) || !Path.HasExtension(path)) {
				fileName = c_defaultFilename;
			}
			else {
				fileName = Path.GetFileNameWithoutExtension(path);
			}

			return fileName;
		}

		protected void NormalTextureGUI(string texName, string helpTex, Color back, AlloyCustomImportObject settings) {
			GUI.backgroundColor = back;

			EditorGUILayout.BeginVertical("HelpBox");


			GUI.backgroundColor = Color.white;

			// Texture and warning
			GUILayout.BeginHorizontal();

			GUILayout.BeginVertical();

			// Section label
			GUILayout.Label(texName, EditorStyles.boldLabel);
			GUI.color = EditorGUIUtility.isProSkin ? Color.gray : Color.black;
			GUILayout.Label(helpTex, EditorStyles.whiteLabel);
			GUI.color = Color.white;

			if (settings.NormalMapTexture == null)
			{
				EditorGUILayout.HelpBox("Recommended, but not required.", MessageType.Info);
			}


			GUILayout.EndVertical();



			GUILayout.FlexibleSpace();

			settings.NormalMapTexture =
				EditorGUILayout.ObjectField(settings.NormalMapTexture, typeof(Texture2D), false, GUILayout.Width(70.0f), GUILayout.Height(70.0f))
				as Texture2D;

			EditorGUILayout.EndHorizontal();


			GUILayout.Space(10.0f);


			EditorGUILayout.EndVertical();
		}

		protected void TextureColorChannelModeSelectionGUI(string channelName, ref TextureColorChannelMode curMode,
		                                                   ref Color color, ref Texture selTex) {
			int index = (int) curMode;
			var mode = (TextureColorChannelMode) index;

			EditorGUILayout.BeginVertical("HelpBox");

			//Section label
			GUILayout.Label(channelName);
			GUILayout.BeginHorizontal();

			if (mode == TextureColorChannelMode.Texture && selTex == null) {
				EditorGUILayout.HelpBox(SelectTextureOrColorErrorMessage,
				                        MessageType.Warning);
			}

			GUILayout.FlexibleSpace();

			// Mode toggle buttons
			GUILayout.BeginVertical();

			bool ch1 = GUILayout.Toggle(index == 0, "Color",
			                            EditorStyles.toolbarButton);
			bool ch2 = GUILayout.Toggle(index == 1, "Texture",
			                            EditorStyles.toolbarButton);

			if (ch1 && index != 0) {
				index = 0;
				color = Color.white;
			}
			else if (ch2 && index != 1) {
				index = 1;
			}

			GUILayout.EndVertical();

			// Color or texture picker.
			switch (mode) {
				case TextureColorChannelMode.Texture:
					selTex =
						EditorGUILayout.ObjectField(selTex, typeof (Texture), false, GUILayout.Width(70.0f), GUILayout.Height(70.0f)) as
						Texture;
					break;

				case TextureColorChannelMode.Color:
					GUILayout.Space(10.0f);
					selTex = null;
					color = EditorGUILayout.ColorField(color,
					                                   GUILayout.Width(60.0f));
					break;
			}

			GUILayout.EndHorizontal();

			// Ensures that section has a fixed width to avoid having
			// all the UI elements changing position.
			GUILayout.Space(mode != TextureColorChannelMode.Texture ? 44.0f : 10.0f);

			EditorGUILayout.EndVertical();

			curMode = (TextureColorChannelMode) index;
		}

		protected void TextureValueChannelModeSelectionGUI(string channelName, string helpString, Color col, int texIndex, AlloyCustomImportObject settings) {

			int index = (int) settings.SelectedModes[texIndex];
			var mode = (TextureValueChannelMode) index;

			GUI.backgroundColor = col;

			EditorGUILayout.BeginVertical("HelpBox");

			GUI.backgroundColor = Color.white;

			GUILayout.BeginHorizontal();

			GUILayout.BeginVertical();
			GUILayout.Label(channelName, EditorStyles.boldLabel);
			GUI.color = EditorGUIUtility.isProSkin ? Color.gray : Color.black;
			GUILayout.Label(helpString, EditorStyles.whiteLabel);
			GUI.color = Color.white;

			var selTex = settings.GetTexture(texIndex);

			if (mode == TextureValueChannelMode.Texture && selTex == null) {
				EditorGUILayout.HelpBox(SelectTextureOrValueErrorMessage, MessageType.Warning);
			}

			GUILayout.EndVertical();


			GUILayout.FlexibleSpace();

			// Mode toggle buttons
			GUILayout.BeginVertical();

			bool ch1 = GUILayout.Toggle(index == 0, "Black", EditorStyles.toolbarButton);
			bool ch2 = GUILayout.Toggle(index == 1, "Gray", EditorStyles.toolbarButton);
			bool ch3 = GUILayout.Toggle(index == 2, "White", EditorStyles.toolbarButton);
			bool ch4 = GUILayout.Toggle(index == 3, "Custom", EditorStyles.toolbarButton);
			bool ch5 = GUILayout.Toggle(index == 4, "Texture", EditorStyles.toolbarButton);

			float channelValue = 0.0f;

			if (ch1 && index != 0) {
				index = 0;
			}
			else if (ch2 && index != 1) {
				index = 1;
			}
			else if (ch3 && index != 2) {
				index = 2;
			}
			else if (ch4 && index != 3) {
				index = 3;
			}
			else if (ch5 && index != 4) {
				index = 4;
			}





			GUILayout.EndVertical();

			if (mode != TextureValueChannelMode.Texture) {
				selTex = null;
			}

			GUILayout.Space(10.0f);
			// Color or texture picker.
			switch (mode) {
				case TextureValueChannelMode.Texture:
					selTex =
						EditorGUILayout.ObjectField(selTex, typeof (Texture2D), false,
						                            GUILayout.Width(70.0f),
						                            GUILayout.Height(70.0f))
						as Texture2D;

					settings.SetTexture(selTex, texIndex);
					break;

				case TextureValueChannelMode.Black:
					channelValue = 0.0f;
					DrawColorBox(Color.black);
					break;
				case TextureValueChannelMode.Gray:
					channelValue = 0.5f;
					DrawColorBox(Color.gray);
					break;
				case TextureValueChannelMode.White:
					channelValue = 1.0f;
					DrawColorBox(Color.white);
					break;

				case TextureValueChannelMode.Custom:
					channelValue = GetChannelValue(texIndex, settings.ChannelValues);
					EditorGUILayout.BeginVertical();
					channelValue = Mathf.Clamp01(channelValue);
					channelValue = EditorGUILayout.FloatField(channelValue,
					                                          GUILayout.Width(50.0f));

					DrawColorBox(new Color(channelValue, channelValue, channelValue));
					EditorGUILayout.EndVertical();
					break;
			}


			switch (texIndex)
			{
				case 0:
					settings.ChannelValues.x = channelValue;
					break;

				case 1:
					settings.ChannelValues.y = channelValue;
					break;

				case 2:
					settings.ChannelValues.z = channelValue;
					break;

				case 3:
					settings.ChannelValues.w = channelValue;
					break;
			}


			GUILayout.EndHorizontal();

			GUILayout.Space(10.0f);

			EditorGUILayout.EndVertical();

			settings.SelectedModes[texIndex]  = (TextureValueChannelMode) index;
		}

		private float GetChannelValue(int texIndex, Vector4 channelValues) {

			switch (texIndex)
			{
				case 0:
					return channelValues.x;

				case 1:
					return channelValues.y;

				case 2:
					return channelValues.z;

				case 3:
					return channelValues.w;

				default:
					return 0.0f;
			}
		}

		private static Texture2D s_staticRectTexture;
		private static GUIStyle s_staticRectStyle;


		// Note that this function is only meant to be called from OnGUI() functions.

		public static void GUIDrawRect(Rect position, Color color) {
			if (s_staticRectTexture == null) {
				// Use this format so that input colors are treated as though they
				// are in gamma-space.
				s_staticRectTexture = new Texture2D(1, 1, TextureFormat.RGB24, false, true);
			}
			
			if (s_staticRectStyle == null) {
				s_staticRectStyle = new GUIStyle();
			}
			
			s_staticRectTexture.SetPixel(0, 0, color);
			
			s_staticRectTexture.Apply();
			s_staticRectStyle.normal.background = s_staticRectTexture;
			
			GUI.Box(position, GUIContent.none, s_staticRectStyle);
		}
		
		private static void DrawColorBox(Color col) {
			var rect = GUILayoutUtility.GetRect(74.0f, 74.0f);
			var borderColor = new Color() {
				r = (col.r + 0.2f) / 2.0f, 
				g = (col.g + 0.2f) / 2.0f, 
				b = (col.b + 0.2f) / 2.0f, 
				a = 1.0f
			};
			
			GUIDrawRect(rect, borderColor);
			
			rect.x += 2.0f;
			rect.width -= 4.0f;
			rect.y += 2.0f;
			rect.height -= 4.0f;
			
			GUIDrawRect(rect, col);
		}

		protected bool FileEntryAndSaveGUI(string suffix, string extension, bool enabled, ref string filename,
		                                   out string curPath) {
			curPath = GetSelectedAssetPath();

			// Remove "_AlloyPM" suffix if present.
			if (filename.Contains(suffix)) {
				int fileExtPos = filename.LastIndexOf(suffix, StringComparison.Ordinal);

				if (fileExtPos >= 0) {
					filename = filename.Substring(0, fileExtPos);
				}
			}

			// Output filename section.
			GUILayout.BeginVertical();

			// Path
			GUILayout.BeginHorizontal();

			Color defaultContentColor = GUI.contentColor;
			GUI.contentColor = EditorGUIUtility.isProSkin ? Color.yellow : Color.black;
			GUILayout.Label(curPath + "/", EditorStyles.whiteLabel);
			GUI.contentColor = defaultContentColor;

			GUILayout.Space(10.0f);
			SaveName = GUILayout.TextField(filename, GUILayout.Width(180.0f));
			GUILayout.Label(suffix + extension);
			GUILayout.FlexibleSpace();

			GUILayout.EndHorizontal();

			GUILayout.EndVertical();
			GUILayout.Space(5.0f);

			// "Generate" button section.
			GUILayout.BeginHorizontal();

			// Warning message.
			bool wrong = false;

			if (string.IsNullOrEmpty(filename)) {
				EditorGUILayout.HelpBox(EnterFilenameErrorMessage, MessageType.Warning);
				wrong = true;
			}

			if (filename.Contains("/") || filename.Contains("\\") || filename.Contains(".")) {
				EditorGUILayout.HelpBox("Name is not valid!", MessageType.Warning);
				wrong = true;
			}

			GUILayout.FlexibleSpace();

			GUILayout.EndHorizontal();

			// Disable the button if the editor doesn't have all the fields set.
			GUI.enabled = enabled && !wrong;
			GUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			bool isButtonClicked = GUILayout.Button("Generate", EditorStyles.toolbarButton, GUILayout.Width(120.0f),
			                                        GUILayout.Height(70.0f));
			GUILayout.FlexibleSpace();
			GUILayout.EndHorizontal();

			GUI.enabled = true;
			GUILayout.Space(5.0f);

			return isButtonClicked;
		}
	}
}