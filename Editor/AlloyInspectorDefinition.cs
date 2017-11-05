// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using System;
using UnityEngine;

namespace Alloy
{
	[Serializable]
	public class AlloyTextureDrawerSettings
	{
		//private bool 
		public TextureVisualizeMode[] VisualizeModes;
		//public VisualizeModeEnum VisualizeMode;
		public bool HasScaleAndOffset;
		public bool IsCubemap;
		
		public string VelocityShaderField;
		public string ParentTextureField;
		public string ScaleOffsetShaderField;
		public string ScaleFieldName;
		public string OffsetFieldName;
	}

	[Serializable]
	public class AlloyParameterHideSettings
	{
		public string[] ParametersToHide;
	}

	[Serializable]
	public class AlloyDropDownSettings
	{
		public AlloyParameterHideSettings[] ParameterHideSettings;
	}

	[Serializable]
	public class AlloyFieldDefinition
	{
		public string ShaderName;

		public string Name {
			get { return ShaderName != null ? ShaderName.Trim() : string.Empty; }
		}

		public string DisplayName;

		public bool HasMin;
		public float Min;
		public bool HasMax;
		public float Max;

		public bool IsTexture;
		public bool IsDropDown;

		public AlloyTextureDrawerSettings TextureSettings;
		public AlloyDropDownSettings DropDownSettings;
	}

	[Serializable]
	public class AlloyInspectorTab
	{
		public string Name;
		public Color Color = Color.white;

		public AlloyFieldDefinition[] Fields;
	}

	public class AlloyInspectorDefinition : ScriptableObject
	{
		public AlloyInspectorTab[] Tabs;
	}
}