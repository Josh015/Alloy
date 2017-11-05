// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Core/Detail Bumped Dissolve" {
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
	
	// Parallax Properties
	[KeywordEnum(Bump, Parallax, POM)] 
	_BumpMode 			("Bump Mode", Float) 						= 0
	_ParallaxMap 		("Heightmap (A)", 2D) 						= "black" {}
	_Parallax 			("Height [0.005, 0.08]", Float) 			= 0.02
	_MinSamples 		("Min Samples [1,n]", Float) 				= 4
	_MaxSamples 		("Max Samples [1,n]", Float) 				= 20
		
    // Detail Mapping Properties
    _Detail    			("Detail(RGB)", 2D)           				= "white" {}
    _DetailBumpMap    	("Detail Normalmap", 2D)             		= "bump" {}
    _DetailMaterialMap	("Detail AO(G) Variance(A)", 2D)  			= "white" {}
    _DetailOffset   	("Detail Tiling(XY) Offset(ZW)", Vector) 	= (1,1,0,0)

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
    #pragma surface AlloySurf AlloyBrdf vertex:AlloyVert finalcolor:AlloyFinalColor addshadow fullforwardshadows noambient  
	#pragma multi_compile _BUMPMODE_BUMP _BUMPMODE_PARALLAX _BUMPMODE_POM
	#pragma multi_compile _ENVIRONMENTMAPMODE_RSRM _ENVIRONMENTMAPMODE_RSRMCUBE _ENVIRONMENTMAPMODE_SKYSHOP 

	// Skyshop directives
	#pragma multi_compile MARMO_BOX_PROJECTION_OFF MARMO_BOX_PROJECTION_ON
	#pragma multi_compile MARMO_GLOBAL_BLEND_OFF MARMO_GLOBAL_BLEND_ON
	#pragma multi_compile MARMO_SKY_BLEND_OFF MARMO_SKY_BLEND_ON
    
    #define _DISSOLVEMODE_DISSOLVE
	//#define _TRANSMODE_TRANSLUCENT
	//#define _TRANSMODE_CUTOUT
	//#define _SELFILLUMIN_ON
	//#define _DETAILMODE_DECAL
	#define _DETAILMODE_DETAIL
	//#define _INCANDESCENCE_ON
	//#define _RIM_ON
    
	#include "Assets/Alloy/Shaders/Standard.cginc"
ENDCG
}
    
Fallback "Bumped Diffuse"
CustomEditor "AlloyBaseShaderEditor"
}