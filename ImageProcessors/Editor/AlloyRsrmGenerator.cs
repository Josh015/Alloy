// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEditor;
using UnityEngine;

namespace Alloy
{
	public class AlloyRsrmGenerator : AlloyImageProcessorEditorWindow
	{
		private const int EditorMinWidth = 236;
		private const int EditorMinHeight = 200;
		private const string EditorName = "RSRM";
		private const string EditorFullPath = EditorPathRoot + "RSRM Generator";
		private const string OutputSuffix = "_AlloyRS";
		
		private const int InputWidth = 1;
		private const int InputHeight = 256;
		private const int OutputWidth = 256;
		private const int OutputHeight = 16; 
		private const float MaxSpecularPower = 2048.0f;
		
		[SerializeField] 
		private Texture2D m_texture;
		
		[MenuItem(EditorFullPath)]
		private static void LoadWindow() {
			GetWindow<AlloyRsrmGenerator>(false, EditorName);
		}
		
		private void OnGUI() {
			minSize = new Vector2(EditorMinWidth, EditorMinHeight);
			
			GUILayout.BeginArea(new Rect(0, 0, position.width, position.height));
			ScrollPosition = EditorGUILayout.BeginScrollView(ScrollPosition, false, false, GUILayout.MinWidth(EditorMinWidth),
			                                                 GUILayout.MaxWidth(position.width));
			
			EditorGUILayout.BeginVertical("HelpBox");
			
			// Section label
			GUILayout.Label("Gradient", EditorStyles.boldLabel);
			
			// Texture and warning
			GUILayout.BeginHorizontal();
			{
				if (m_texture == null) {
					EditorGUILayout.HelpBox("Please select a texture.", MessageType.Warning);
				} else if (m_texture.height != InputHeight) {
					EditorGUILayout.HelpBox("Texture must be " + InputHeight + " pixels tall.", MessageType.Error);
				}
				
				GUILayout.FlexibleSpace();
				
				m_texture =
					EditorGUILayout.ObjectField(m_texture, typeof (Texture2D), false, GUILayout.Width(70.0f), GUILayout.Height(70.0f))
						as Texture2D;
			}
			EditorGUILayout.EndHorizontal();
			GUILayout.Space(10.0f);
			EditorGUILayout.EndVertical();
			
			var enabled = m_texture != null
				&& m_texture.height == InputHeight;
			
			string curPath;
			
			if (FileEntryAndSaveGUI(OutputSuffix, ".png", enabled, ref SaveName, out curPath)) {
				//GeneratePackedMaterialMap(curPath + "/" + m_saveName);
				SaveRsrmFromGradient(m_texture, curPath + "/" + SaveName);
			}
			
			EditorGUILayout.EndScrollView();
			GUILayout.EndArea();
		}
		
		public void SaveRsrmFromGradient(Texture2D gradient, string filePath) {
			var outputTex = GetRsrmFromGradient(gradient);
			
			if (!filePath.EndsWith(OutputSuffix)) {
				filePath += OutputSuffix;
			}
			
			var importSettings = new AlloyTextureImportSettings {
				AnisoLevel = 0,
				IsLinear = false,
				MaxSize = 256,
				MipEnabled = false,
				TextureImporterFormat = TextureImporterFormat.ARGB32,
				WrapMode = TextureWrapMode.Clamp,
				FilterMode = FilterMode.Bilinear
			};
			
			AlloyTextureUtility.SaveTexture(filePath, outputTex, importSettings);
			DestroyImmediate(outputTex);
		}
		
		private Texture2D GetRsrmFromGradient(Texture2D gradient)
		{
			if (gradient == null) {
				Debug.LogError("Error: gradient is null!");
				return null;
			}
			
			var outputColors = new Color[OutputWidth * OutputHeight];
			
			if (EditorUtility.IsPersistent(gradient)) {
				var path = AssetDatabase.GetAssetPath(gradient);
				var importer = AssetImporter.GetAtPath(path) as TextureImporter;
				
				if (importer != null && !importer.isReadable) {
					importer.isReadable = true;
					AssetDatabase.ImportAsset(path);
				}
			}
			
			Color[] inputColors = gradient.GetPixels(0, 0, InputWidth, InputHeight, 0);
			
			GammaToLinearImage(InputWidth, InputHeight, ref inputColors);
			
			// Ensure that the input texture's colors have an overall maximum value
			// of one by explicitly normalizing the colors if necessary.
			var maxValue = 1e-6f;
			
			for (int i = 0; i < InputWidth * InputHeight; ++i) {
				var color = inputColors[i];
				maxValue = Mathf.Max(maxValue, color.r);
				maxValue = Mathf.Max(maxValue, color.g);
				maxValue = Mathf.Max(maxValue, color.b);
			}
			
			if (!Mathf.Approximately(1.0f, maxValue)) {
				for (int i = 0; i < InputWidth * InputHeight; ++i) {
					var color = inputColors[i];
					color.r /= maxValue;
					color.g /= maxValue;
					color.b /= maxValue;
					inputColors[i] = color;
				}
			}
			
			// Generate the LUT to speed up the integration step.
			var dpLUT = new float[InputHeight * InputHeight * OutputWidth];
			var thetaOutLerp = 0.0f;
			
			EditorUtility.DisplayProgressBar("Generating RSRM...", "Calculating LUT", 0.0f);

			for (int xOut = 0; xOut < OutputWidth; ++xOut) {
				var thetaOut = Mathf.Acos(thetaOutLerp * 2.0f - 1.0f);
				var norm = SphericalToCartesian(1.0f, thetaOut, 0.0f);
				var thetaInLerp = 0.0f;
				
				for (int yIn = 0; yIn < InputHeight; ++yIn) {
					var thetaIn = Mathf.Acos(thetaInLerp * 2.0f - 1.0f);
					
					var phiInLerp = 0.0f;
					
					for (int xIn = 0; xIn < InputHeight; ++xIn) {
						var phiIn = Mathf.Acos(phiInLerp * 2.0f - 1.0f);
						var l = SphericalToCartesian(1.0f, thetaIn, phiIn);
						var dp = Mathf.Clamp01(Vector3.Dot(norm, l));
						
						dpLUT[xIn + yIn * InputHeight + xOut * InputHeight * InputHeight] = dp;
						
						phiInLerp += 1.0f / (InputHeight - 1);
					}
					
					thetaInLerp += 1.0f / (InputHeight - 1);
				}
				
				thetaOutLerp += 1.0f / (OutputWidth - 1);
			}
						
			// Generate the RSRM.
			for (int yOut = 0; yOut < OutputHeight; ++yOut) {
				// Non-linear mapping
				var shininessLerp = yOut / (OutputHeight - 1.0f);
				var specularPower = Mathf.Pow(MaxSpecularPower, shininessLerp);

				EditorUtility.DisplayProgressBar("Generating RSRM...", Mathf.Floor((yOut * 100.0f) / OutputHeight) + "% complete", shininessLerp);
				IntegrateEnvMap(yOut, InputHeight, specularPower, dpLUT, inputColors, outputColors);
			}
			
			EditorUtility.ClearProgressBar();
			
			// Normalize the specular rows so that the highest intensity per row is one.
			// In this form, specular power zero can be used for diffuse lighting.
			// Store the max value in the alpha so we can recover the original color.
			for (int yOut = 0; yOut < OutputHeight; ++yOut) {		
				maxValue = 1e-6f;
				
				for (int xOut = 0; xOut < OutputWidth; ++xOut) {	
					var color = outputColors[xOut + (OutputWidth * yOut)];
					maxValue = Mathf.Max(maxValue, color.r);
					maxValue = Mathf.Max(maxValue, color.g);
					maxValue = Mathf.Max(maxValue, color.b);
				}
				
				for (int xOut = 0; xOut < OutputWidth; ++xOut) {
					var color = outputColors[xOut + (OutputWidth * yOut)];
					color.r /= maxValue;
					color.g /= maxValue;
					color.b /= maxValue;
					color.a = maxValue;
					outputColors[xOut + (OutputWidth * yOut)] = color;
				}
			}
			
			LinearToGammaImage(OutputWidth, OutputHeight, ref outputColors);
			
			var outputTex = new Texture2D(OutputWidth, OutputHeight, TextureFormat.ARGB32, false);
			outputTex.hideFlags = HideFlags.HideAndDontSave;
			outputTex.SetPixels(outputColors);
			outputTex.Apply();
			
			return outputTex;
		}
		
		private void IntegrateEnvMap(int yOut, int inputHeight, float specularPower, float[] dpLUT, Color[] inputImage,
		                             Color[] workingImage)
		{
			for (uint xOut = 0; xOut < OutputWidth; ++xOut) {
				var illumination = new Color(0.0f, 0.0f, 0.0f);
				var weightSum = 0.0f;
				
				for (uint yIn = 0; yIn < inputHeight; ++yIn) {
					var zoneIntensity = 0.0f;
					
					for (uint xIn = 0; xIn < inputHeight; ++xIn) {
						var dp = dpLUT[xIn + yIn * inputHeight + xOut * inputHeight * inputHeight];
						var lobeShape = Mathf.Pow(dp, specularPower);
						
						zoneIntensity += dp * lobeShape;
						weightSum += lobeShape;
					}
					
					// Moving this out of the inner loop cut bake time in half!
					illumination += inputImage[yIn] * zoneIntensity;
				}
				
				workingImage[xOut + (OutputWidth * yOut)] = illumination / weightSum;
			}
		}
		
		// This code ALWAYS produces UNIT-LENGTH normals
		private Vector3 SphericalToCartesian(float radius, float theta, float phi)
		{
			var sinTheta = Mathf.Sin(theta);
			var cosTheta = Mathf.Cos(theta);
			var sinPhi = Mathf.Sin(phi);
			var cosPhi = Mathf.Cos(phi);
			
			return radius * new Vector3(sinTheta * cosPhi, sinTheta * sinPhi, cosTheta);
		}
		
		private float GammaToLinear(float value)
		{
			// Official sRGB transformation function.
			// http://chilliant.blogspot.de/2012/08/srgb-approximations-for-hlsl.html
			if (value <= 0.04045f)
				return value / 12.92f;
			else
				return Mathf.Pow((value + 0.055f) / 1.055f, 2.4f);
		}

		private float LinearToGamma(float value)
		{
			// Official sRGB transformation function.
			// http://chilliant.blogspot.de/2012/08/srgb-approximations-for-hlsl.html
			if (value <= 0.0031308f)
				return value * 12.92f;
			else
				return 1.055f * Mathf.Pow(value, 1.0f / 2.4f) - 0.055f;
		}
		
		private float LinearToQuantizedGamma(float value)
		{
			// saturate to get [0,1], then gamma for better space use when quantized
			// floor() eliminates dark not quite black zone, but is it correct?
			return Mathf.Floor(LinearToGamma(Mathf.Clamp01(value)) * 255.0f) / 255.0f;
		}
		
		private float Quantize(float value)
		{
			return Mathf.Floor(Mathf.Clamp01(value) * 255.0f) / 255.0f;
		}
		
		private void GammaToLinearImage(int width, int height, ref Color[] data)
		{
			for (int i = 0; i < width * height; ++i) {
				data[i].r = GammaToLinear(data[i].r);
				data[i].g = GammaToLinear(data[i].g);
				data[i].b = GammaToLinear(data[i].b);
			}
		}
		
		private void LinearToGammaImage(int width, int height, ref Color[] data)
		{
			for (int i = 0; i < width * height; ++i) {
				data[i].r = LinearToQuantizedGamma(data[i].r);
				data[i].g = LinearToQuantizedGamma(data[i].g);
				data[i].b = LinearToQuantizedGamma(data[i].b);
				data[i].a = Quantize(data[i].a);
			}
		}
	}
}