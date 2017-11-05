// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEditor;
using UnityEngine;

namespace Alloy {
	public class AlloyTextureImportSettings
	{
		public bool MipEnabled;
		public TextureImporterFormat TextureImporterFormat;
		public FilterMode FilterMode; 
		public int AnisoLevel;
		public TextureWrapMode WrapMode;
		public TextureImporterType TextureImporterType;
		public bool IsLinear;
		public bool IsReadWriteEnabled { get; set; }
		
		public int MaxSize;
	};
}