// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Transparent/Cutout/Decal Bumped" {
Properties {
	// Main Textures  
	_Color 				("Main Color", Color) 						= (1,1,1,1)
	_MainTex 			("Base(RGB) Trans(A)", 2D) 					= "white" {}
	_Cutoff 			("Alpha cutoff [0,1]", Float) 				= 0.5
	_BumpMap            ("Normalmap", 2D)                   		= "bump" {}
	_MaterialMap 		("Metal(R) AO(G) Spec(B) Rough(A)", 2D)		= "white" {}
	
	// Main Physical Properties
	_Metallic			("Metallic [0,1]", Float)					= 1
	_Specularity		("Specularity [0,1]", Float)				= 1
	_Roughness			("Roughness [0,1]", Float)					= 1
	
	// Parallax Properties
	[KeywordEnum(Bump, Parallax, POM)] 
	_BumpMode 			("Bump Mode", Float) 						= 0
	_ParallaxMap 		("Heightmap (A)", 2D) 						= "black" {}
	_Parallax 			("Height [0.005, 0.08]", Float) 			= 0.02
	_MinSamples 		("Min Samples [1,n]", Float) 				= 4
	_MaxSamples 		("Max Samples [1,n]", Float) 				= 20

	// Decal Mapping Properties
	_DecalTex 			("Decal(RGBA)", 2D) 						= "black" {}
    _DecalTexBumpMap    ("Decal Normalmap", 2D)             		= "bump" {}
    _DecalTexMaterialMap("Decal AO(G) Variance(A)", 2D)  			= "white" {}
    _DecalTexOffset   	("Decal Tiling(XY) Offset(ZW)", Vector) 	= (1,1,0,0)
 
	// Reflection Properties	
	[KeywordEnum(Rsrm, RsrmCube, Skyshop)]
	_EnvironmentMapMode ("Environment Map Mode", Float) 			= 0
    _Rsrm               ("Radially-Symmetric Reflection Map", 2D)	= "black" {}
    _CubeExposureBoost	("Reflection Exposure Boost [0,n]", Float)	= 1
    _Cube 				("Reflection Cubemap", Cube) 				= "_Skybox" { TexGen CubeReflect }
	_SpecCubeIBL 		("Custom Specular Cube", Cube) 				= "black" {}
}
    
SubShader { 
	Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
	LOD 400
    
CGPROGRAM
	#ifdef SHADER_API_OPENGL	
		#pragma glsl
	#endif

    #pragma target 3.0
    #pragma surface AlloySurf AlloyBrdf vertex:AlloyVert finalcolor:AlloyFinalColor alphatest:_Cutoff fullforwardshadows noambient
	#pragma multi_compile _BUMPMODE_BUMP _BUMPMODE_PARALLAX _BUMPMODE_POM
	#pragma multi_compile _ENVIRONMENTMAPMODE_RSRM _ENVIRONMENTMAPMODE_RSRMCUBE _ENVIRONMENTMAPMODE_SKYSHOP 

	// Skyshop directives
	#pragma multi_compile MARMO_BOX_PROJECTION_OFF MARMO_BOX_PROJECTION_ON
	#pragma multi_compile MARMO_GLOBAL_BLEND_OFF MARMO_GLOBAL_BLEND_ON
	#pragma multi_compile MARMO_SKY_BLEND_OFF MARMO_SKY_BLEND_ON
    
	//#define _TRANSMODE_TRANSLUCENT
	#define _TRANSMODE_CUTOUT
	//#define _SELFILLUMIN_ON
	#define _DETAILMODE_DECAL
	//#define _DETAILMODE_DETAIL
	//#define _INCANDESCENCE_ON
	//#define _RIM_ON
    
	#include "Assets/Alloy/Shaders/Standard.cginc"
ENDCG
}
    
Fallback "Transparent/Cutout/Bumped Diffuse"
CustomEditor "AlloyBaseShaderEditor"
}