// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Self-Illumin/Glow" {
Properties {
	// Main Textures
    _Color 				("Main Color", Color) 						= (1,1,1,1)
	_MainTex 			("Base (RGB)", 2D) 							= "white" {}
	
	// Self Illumination Properties
	_IllumTint 			("Illumin Tint", Color) 					= (1,1,1,1)
	_IllumWeight		("Illumin Weight [0,1]", Float)				= 0
	_IllumIntensity		("Illumin Intensity [0,n]", Float)			= 1
	_EmissionLM 		("Emission (Lightmapper)", Float) 			= 0
}
     
SubShader { 
    Tags { "Queue"="Geometry" "RenderType"="Opaque" }
    LOD 300
    
CGPROGRAM
	#ifdef SHADER_API_OPENGL	
		#pragma glsl
	#endif

    #pragma target 3.0
    #pragma surface surf Lambert fullforwardshadows
	
	#include "Assets/Alloy/Shaders/Utility.cginc"
	
    struct Input {
    	float2 uv_MainTex;
    };
    
    float4 _Color; 
    sampler2D _MainTex; 
    
    float4 _IllumTint;
	float _IllumWeight;
	float _IllumIntensity;
    
    void surf (Input IN, inout SurfaceOutput o) { 
	    half4 base = _Color * tex2D(_MainTex, IN.uv_MainTex);
	    
	    o.Albedo 	= base.rgb;
	    o.Emission  = base.rgb * _IllumTint.rgb * AlloyGammaToLinearFast(_IllumWeight * _IllumIntensity);
    }
ENDCG
}
    
Fallback "Self-Illumin/Diffuse"
CustomEditor "AlloyBaseShaderEditor"
}