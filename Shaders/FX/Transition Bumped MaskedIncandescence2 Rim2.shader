// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/FX/Transition Bumped MaskedIncandescence2 Rim2" {
Properties {
	// Dissolve Parameters
	_DissolveColor 		("Dissolve Color", Color) 					= (1,1,1,1)
	_DissolveCutoff		("Dissolve Cutoff [0,1.01]", Float)			= 0
	_DissolveEdgeWidth	("Dissolve Edge Width [0,0.1]", Float)		= 0.05
	_DissolveGlowIntensity("Dissolve Intensity [0,n]", Float)		= 1
	_DissolveTex 		("Dissolve(RGB) Trans(A)", 2D) 				= "white" {}

	// Main Textures
	_Color 				("Main Color", Color) 						= (1,1,1,1)
	_MainTex 			("Base(RGB)", 2D) 							= "white" {}
	_BumpMap            ("Normalmap", 2D)                   		= "bump" {}
	_MaterialMap 		("Metal(R) AO(G) Spec(B) Rough(A)", 2D)		= "white" {}
	
	// Main Physical Properties
	_Metallic			("Metallic [0,1]", Float)					= 1
	_Specularity		("Specularity [0,1]", Float)				= 1
	_Roughness			("Roughness [0,1]", Float)					= 1
	
	// Incandescence Properties
    _IncandescenceTint  ("Incandescence Tint", Color)       		= (1,1,1,1)
	_IncandescenceWeight("Incandescence Weight [0,1]", Float)		= 0
	_IncandescenceIntensity("Incandescence Intensity [0,n]", Float)	= 1
	_IncandescenceMask 	("Incandescence Mask(RGB)", 2D) 			= "white" {}
    _IncandescenceMap   ("Incandescence(RGB)", 2D)         			= "white" {}
    _IncandescenceOffset("Incandescence Tiling(XY) Velocity(ZW)", Vector)= (1,1,0,0)
    
   	// Rim Emission Properties
	_RimTint            ("Rim Tint", Color)                 		= (1,1,1,1)
	_RimWeight			("Rim Weight [0,1]", Float)					= 0
	_RimIntensity		("Rim Intensity [0,n]", Float)				= 1
	_RimBias			("Rim Bias [0,1]", Float)					= 0
	_RimPower			("Rim Power [0,n]", Float)					= 4
	    
	// Secondary Textures
	_Color2 			("Main Color", Color) 						= (1,1,1,1)
	_MainTex2 			("Base(RGB)", 2D) 							= "white" {}
	_BumpMap2           ("Normalmap", 2D)                   		= "bump" {}
	_MaterialMap2 		("Metal(R) AO(G) Spec(B) Rough(A)", 2D)		= "white" {}
	
	// Secondary Physical Properties
	_Metallic2			("Metallic [0,1]", Float)					= 1
	_Specularity2		("Specularity [0,1]", Float)				= 1
	_Roughness2			("Roughness [0,1]", Float)					= 1

	// Secondary Incandescence Properties
    _IncandescenceTint2 ("Incandescence Tint", Color)       		= (1,1,1,1)
	_IncandescenceWeight2("Incandescence Weight [0,1]", Float)		= 0
	_IncandescenceIntensity2("Incandescence Intensity [0,n]", Float)= 1
	_IncandescenceMask2 ("Incandescence Mask(RGB)", 2D) 			= "white" {}
    _IncandescenceMap2  ("Incandescence(RGB)", 2D)         			= "white" {}
    _IncandescenceOffset2("Incandescence Tiling(XY) Velocity(ZW)", Vector)= (1,1,0,0)
    	   
   	// Secondary Rim Emission Properties
	_RimTint2           ("Rim Tint", Color)                 		= (1,1,1,1)
	_RimWeight2			("Rim Weight [0,1]", Float)					= 0
	_RimIntensity2		("Rim Intensity [0,n]", Float)				= 1
	_RimBias2			("Rim Bias [0,1]", Float)					= 0
	_RimPower2			("Rim Power [0,n]", Float)					= 4
	      
	// Reflection Properties	
	[KeywordEnum(Rsrm, RsrmCube, SkyshopSH, SkyshopSHBox)] 
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
    
    #define _DISSOLVEMODE_TRANSITION
	#define _INCANDESCENCE_ON
	#define _RIM_ON
    
	#include "Assets/Alloy/Shaders/Transition.cginc"
ENDCG
}
    
FallBack "Bumped Diffuse"
CustomEditor "AlloyBaseShaderEditor"
}