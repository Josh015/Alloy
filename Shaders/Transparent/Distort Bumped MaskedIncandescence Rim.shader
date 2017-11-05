// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Transparent/Distort Bumped MaskedIncandescence Rim" {
Properties {
	// Main Textures
	_Color 				("Main Color", Color) 						= (1,1,1,1)
	_MainTex 			("Base(RGB) Trans(A)", 2D) 					= "white" {}
	_BumpMap            ("Normalmap", 2D)                   		= "bump" {}
	_MaterialMap 		("Metal(R) AO(G) Spec(B) Rough(A)", 2D)		= "white" {}
	
	// Main Physical Properties
	_Metallic			("Metallic [0,1]", Float)					= 1
	_Specularity		("Specularity [0,1]", Float)				= 1
	_Roughness			("Roughness [0,1]", Float)					= 1

	// Distortion Properties
	_TransparencyLM 	("Transparency (Lightmapper)", 2D) 			= "white" {}
	_DistortWeight		("Distort Weight [0,1]", Float) 			= 1
	_DistortIntensity	("Distort Intensity [0,128]", Float) 		= 10
	_DistortGeoWeight	("Distort Geo Weight [0,1]", Float) 		= 1

    // Incandescence Properties
    _IncandescenceTint  ("Incandescence Tint", Color)       		= (1,1,1,1)
	_IncandescenceMask 	("Incandescence Mask(RGB)", 2D) 			= "white" {}
    _IncandescenceMap   ("Incandescence(RGB)", 2D)         			= "white" {}
	_IncandescenceWeight("Incandescence Weight [0,1]", Float)		= 0
	_IncandescenceIntensity("Incandescence Intensity [0,n]", Float)	= 1
    _IncandescenceOffset("Incandescence Tiling(XY) Velocity(ZW)", Vector)= (1,1,0,0)
    	      
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
    // We must be transparent, so other objects are drawn before this one.
	Tags { "Queue"="Transparent" "RenderType"="Opaque" }
    LOD 500

	// This pass grabs the screen behind the object into a texture.
	// We can access the result in the next pass as _GrabTexture
	GrabPass {							
		Name "BASE"
		Tags { "LightMode" = "Always" }
	}
	 
	// Main pass: Take the texture grabbed above and use the bumpmap to perturb it
	// on to the screen
	Pass {
		Name "BASE"
		Tags { "LightMode" = "Always" }
			
CGPROGRAM
	#ifdef SHADER_API_OPENGL	
		#pragma glsl
	#endif
	
	#pragma vertex AlloyDistortVertex
	#pragma fragment AlloyDistortFragment
	#pragma fragmentoption ARB_precision_hint_fastest
	
	#include "Assets/Alloy/Shaders/Distort.cginc"
ENDCG
	}
	
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
    LOD 500
    
    Zwrite Off
    Blend One OneMinusSrcAlpha
    
CGPROGRAM
	#ifdef SHADER_API_OPENGL	
		#pragma glsl
	#endif

    #pragma target 3.0
    #pragma surface AlloySurf AlloyBrdf vertex:AlloyVert finalcolor:AlloyFinalColor exclude_path:prepass fullforwardshadows noambient
	#pragma multi_compile _ENVIRONMENTMAPMODE_RSRM _ENVIRONMENTMAPMODE_RSRMCUBE _ENVIRONMENTMAPMODE_SKYSHOP 

	// Skyshop directives
	#pragma multi_compile MARMO_BOX_PROJECTION_OFF MARMO_BOX_PROJECTION_ON
	#pragma multi_compile MARMO_GLOBAL_BLEND_OFF MARMO_GLOBAL_BLEND_ON
	#pragma multi_compile MARMO_SKY_BLEND_OFF MARMO_SKY_BLEND_ON
    
	#define _TRANSMODE_TRANSLUCENT
	//#define _TRANSMODE_CUTOUT
	//#define _SELFILLUMIN_ON
	//#define _DETAILMODE_DECAL
	//#define _DETAILMODE_DETAIL
	#define _INCANDESCENCE_ON
	#define _RIM_ON
    
	#include "Assets/Alloy/Shaders/Standard.cginc"
ENDCG
}
    
FallBack "Transparent/Bumped Diffuse"
CustomEditor "AlloyBaseShaderEditor"
}