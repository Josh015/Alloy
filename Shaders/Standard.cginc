// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Standard.cginc
/// @brief Standard ubershader inputs and entry points.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_STANDARD_CGINC
#define ALLOY_STANDARD_CGINC

#include "Assets/Alloy/Shaders/Core.cginc"
#include "Assets/Alloy/Shaders/Dissolve.cginc"
#include "Assets/Alloy/Shaders/Parallax.cginc"
#include "Assets/Alloy/Shaders/Detail.cginc"
#include "Assets/Alloy/Shaders/Effects.cginc"
#include "Assets/Alloy/Shaders/Lighting.cginc"

//#ifdef ALLOY_AMPLIFY_VIRTUAL_TEXTURE_ON
//	// TODO: Switch to absolute path once it is known.
//	#include "Shared.cginc" 
//#else

struct Input {
    float4 texcoords; 
	float3 worldPos;
    float3 viewDir;
    float3 worldNormal;
    float3 worldRefl;
    INTERNAL_DATA
};

float4 _Color;
float4 _MainTex_ST;
sampler2D _MainTex;
sampler2D _MaterialMap; // TODO: May need to rename this to what texture name they use.
sampler2D _BumpMap;

float _Metallic;
float _Specularity;
float _Roughness;

#if defined(_UV1AO2_ON)
	float4 _Ao2Map_ST;
	sampler2D _Ao2Map;
#endif

#ifdef _SELFILLUMIN_ON
    float4 _IllumTint;
	float _IllumWeight;
	float _IllumIntensity;
	sampler2D _Illum;
#endif

void AlloyFinalColor(
	Input IN, 
	AlloySurfaceOutput o, 
	inout fixed4 color)
{
	color.rgb = min(color.rgb, ALLOY_MAX_HDR_INTENSITY);
}

void AlloyVert(
	inout appdata_full v, 
	out Input o) 
{
	UNITY_INITIALIZE_OUTPUT(Input, o);
	o.texcoords.xy = v.texcoord;
	
#if defined(_UV1AO2_ON)
	o.texcoords.zw = v.texcoord1;
#endif 
}

void AlloySurf(
	Input IN, 
	inout AlloySurfaceOutput o) 
{ 
    half4 base;
    half4 material;
	half3 normalTs;
	float2 texcoords0 = IN.texcoords.xy;
#if defined(_UV1AO2_ON)
	float2 texcoords1 = IN.texcoords.zw;
#endif 
	float2 baseUv = TRANSFORM_TEX(texcoords0, _MainTex);
	float3 eyeVectorTs = IN.viewDir;
	float3 eyeDirTs = normalize(eyeVectorTs);
	half3 emission = half3(0.0h, 0.0h, 0.0h); 
	half clipval = 1.0h; 

	float2 offset = AlloyParallax(eyeVectorTs, eyeDirTs, baseUv);
  	AlloyDissolve(baseUv, offset, emission, clipval);
  
	// Base
#ifdef ALLOY_AMPLIFY_VIRTUAL_TEXTURE_ON
	VirtualCoord vcoord = VTComputeVirtualCoord(IN.uv_MainTex.xy);
	base = VTSampleBase(vcoord);
	normalTs = UnpackNormal(VTSampleNormal(vcoord));
	material = half4(0.0h, 1.0h, 0.5h, 0.5h); // TODO: Change to new sample function name.
#else
	float2 uv = baseUv + offset;
    base = tex2D(_MainTex, uv);
    material = tex2D(_MaterialMap, uv);
    normalTs = UnpackNormal(tex2D(_BumpMap, uv));
#endif
		
    material.x *= _Metallic;
    material.z *= _Specularity;
    material.w = 1.0h - (material.w * _Roughness); // Roughness to Gloss
	AlloyDetails(baseUv, offset, base, material, normalTs);
	base *= _Color;
    material.y = AlloyGammaToLinearFast(material.y); // DeGamma combined AO
	
#if defined(_UV1AO2_ON)
	// Assumes texture is set to perform sRGB conversion.
	material.y *= tex2D(_Ao2Map, TRANSFORM_TEX(texcoords1, _Ao2Map) + offset).g;
#endif
	
 	// Normal-dependent data
	half ndv = max(0.0h, dot(eyeDirTs, normalTs)); 
	half3 normalWs = WorldNormalVector(IN, normalTs);
	half3 reflectionWs = WorldReflectionVector(IN, normalTs);

	// Self-Illumin
#ifdef _SELFILLUMIN_ON
	half illumin = tex2D(_Illum, baseUv + offset).a;
	emission += base.rgb * _IllumTint.rgb * AlloyGammaToLinearFast(illumin * _IllumWeight * _IllumIntensity);
#endif

	AlloyEffects(baseUv, offset, ndv, emission);
	AlloySurface(base.a, base.rgb, material, normalTs, emission, ndv, o);
	
	half ao = material.y;
	half3 occludedAlbedo = ao * o.Albedo;
	AlloyAmbientBrdf(ao, occludedAlbedo, o.SpecularColor, IN.worldPos, normalWs, reflectionWs, ndv, o);
}

#endif // ALLOY_STANDARD_CGINC
