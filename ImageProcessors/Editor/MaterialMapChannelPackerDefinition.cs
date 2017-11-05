// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEngine;

namespace Alloy
{
	public class MaterialMapChannelPackerDefinition : ScriptableObject
	{
		public string MetalText;
		public Color MetalColor;


		public string OcclusionText;
		public Color OcclusionColor;

		public string SpecularityTex;
		public Color SpecularityColor;

		public string RoughnessText;
		public Color RoughnessColor;

		public string NormalTex;
		public Color NormalColor;

		public string VarianceText;

		public string AutoRegenerateText;
	}
}
