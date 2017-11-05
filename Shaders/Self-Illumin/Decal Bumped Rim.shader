// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Self-Illumin/Decal Bumped Rim" {
Properties {
	// Main Textures
	_Color 				("Main Color", Color) 						= (1,1,1,1)
	_MainTex 			("Base(RGB)", 2D) 							= "white" {}
	_BumpMap            ("Normalmap", 2D)                   		= "bump" {}
	_MaterialMap 		("Metal(R) AO(G) Spec(B) Rough(A)", 2D)		= "white" {}
	
	// Main Physical Properties
	_Metallic			("Metallic [0,1]", Float)					= 1
	_Specularity		("Specularity [0,1]", Float)				= 1
	_Roughness			("Roughness [0,1]", Float)					= 1
	
	// Self Illumination Properties
	_Illum 				("Illumin(A)", 2D) 							= "white" {}
	_IllumTint 			("Illumin Tint", Color) 					= (1,1,1,1)
	_IllumWeight		("Illumin Weight [0,1]", Float)				= 0
	_IllumIntensity		("Illumin Intensity [0,n]", Float)			= 1
	_EmissionLM 		("Emission (Lightmapper)", Float) 			= 0

	// Decal Mapping Properties
	_DecalTex 			("Decal(RGBA)", 2D) 						= "black" {}
    _DecalTexBumpMap    ("Decal Normalmap", 2D)             		= "bump" {}
    _DecalTexMaterialMap("Decal AO(G) Variance(A)", 2D)  			= "white" {}
    _DecalTexOffset   	("Decal Tiling(XY) Offset(ZW)", Vector) 	= (1,1,0,0)
   
	// Rim Emission Properties
	_RimTint            ("Rim Tint", Color)                 		= (1,1,1,1)
    _RimTex 			("Rim (RGB)", 2D) 							= "white" {}
	_RimWeight			("Rim Weight [0,1]", Float)					= 0
	_RimIntensity		("Rim Intensity [0,n]", Float)				= 1
	_RimBias			("Rim Bias [0,1]", Float)					= 0
	_RimPower			("Rim Power [0,n]", Float)					= 4
    _RimOffset   		("Rim Tiling(XY) Velocity(ZW)", Vector) 	= (1,1,0,0)
	      
	// Reflection Properties	
	[KeywordEnum(Rsrm, RsrmCube, Skyshop)]
	_EnvironmentMapMode ("Environment Map Mode", Float) 			= 0
    _Rsrm               ("Radially-Symmetric Reflection Map", 2D)	= "black" {}
    _CubeExposureBoost	("Reflection Exposure Boost [0,n]", Float)	= 1
    _Cube 				("Reflection Cubemap", Cube) 				= "_Skybox" { TexGen CubeReflect }
	_SpecCubeIBL 		("Custom Specular Cube", Cube) 				= "black" {}
}
    
SubShader { 
    Tags { "Queue"="Geometry" "RenderType"="Opaque" }
    LOD 400
    
CGPROGRAM
	#ifdef SHADER_API_OPENGL	
		#pragma glsl
	#endif

    #pragma target 3.0
    #pragma surface AlloySurf AlloyBrdf vertex:AlloyVert finalcolor:AlloyFinalColor fullforwardshadows noambient
	#pragma multi_compile _ENVIRONMENTMAPMODE_RSRM _ENVIRONMENTMAPMODE_RSRMCUBE _ENVIRONMENTMAPMODE_SKYSHOP 

	// Skyshop directives
	#pragma multi_compile MARMO_BOX_PROJECTION_OFF MARMO_BOX_PROJECTION_ON
	#pragma multi_compile MARMO_GLOBAL_BLEND_OFF MARMO_GLOBAL_BLEND_ON
	#pragma multi_compile MARMO_SKY_BLEND_OFF MARMO_SKY_BLEND_ON
    
	//#define _TRANSMODE_TRANSLUCENT
	//#define _TRANSMODE_CUTOUT
	#define _SELFILLUMIN_ON
	#define _DETAILMODE_DECAL
	//#define _DETAILMODE_DETAIL
	//#define _INCANDESCENCE_ON
	#define _RIM_ON
    
	#include "Assets/Alloy/Shaders/Standard.cginc"
ENDCG
}
    
Fallback "Self-Illumin/Bumped Diffuse"
CustomEditor "AlloyBaseShaderEditor"
}