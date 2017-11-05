// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/FX/Glow MaskedIncandescence Rim" {
Properties {
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
}
    
SubShader { 
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
    LOD 300
    
    Zwrite Off
    Blend One One
    
CGPROGRAM
    #pragma surface surf Lambert noambient novertexlights nolightmap nodirlightmap noforwardadd
		           
	#define _INCANDESCENCE_ON
	#define _RIM_ON
	
	#include "Assets/Alloy/Shaders/Effects.cginc"
	                  	                         	                         	                  
	struct Input {
	    float2 uv_IncandescenceMask;
	    float3 viewDir;
	};
    			
	void surf(Input IN, inout SurfaceOutput o) {   
		float2 baseUv = IN.uv_IncandescenceMask;
		half3 emission = half3(0.0h, 0.0h, 0.0h);
		half ndv = max(0.0h, dot(normalize(IN.viewDir), o.Normal)); 
		float2 offset = float2(0.0f, 0.0f);
    		
		AlloyEffects(baseUv, offset, ndv, emission);
		o.Emission = emission;
	}
ENDCG
}
    
Fallback "Bumped Specular"
CustomEditor "AlloyBaseShaderEditor"
}