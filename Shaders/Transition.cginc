// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Transition.cginc
/// @brief Dissolve/Transition ubershader inputs and entry points.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_TRANSITION_CGINC
#define ALLOY_TRANSITION_CGINC

#include "Assets/Alloy/Shaders/Core.cginc"
#include "Assets/Alloy/Shaders/Dissolve.cginc"
#include "Assets/Alloy/Shaders/Lighting.cginc"
                  
struct Input { 
    float4 texcoords; 
	float3 worldPos;
    float3 viewDir;
    float3 worldRefl;
    float3 worldNormal;
    INTERNAL_DATA
};

float4 _Color;
float4 _MainTex_ST;
sampler2D _MainTex;
float _Metallic;
float _Specularity;
float _Roughness;
sampler2D _MaterialMap;
sampler2D _BumpMap;

#ifdef _INCANDESCENCE_ON
	float4 _IncandescenceTint;
	float _IncandescenceWeight;
	float _IncandescenceIntensity;
	sampler2D _IncandescenceMask;
	sampler2D _IncandescenceMap;
	float4 _IncandescenceOffset;
#endif

#ifdef _RIM_ON
	float4 _RimTint;
	float _RimWeight;
	float _RimIntensity;
	float _RimBias;
	float _RimPower;
#endif

#ifdef _DISSOLVEMODE_TRANSITION
	float4 _Color2;
	sampler2D _MainTex2;
	float _Metallic2;
	float _Specularity2;
	float _Roughness2;
	sampler2D _MaterialMap2;
	sampler2D _BumpMap2;

	#ifdef _INCANDESCENCE_ON
		float4 _IncandescenceTint2;
		float _IncandescenceWeight2;
		float _IncandescenceIntensity2;
		sampler2D _IncandescenceMask2;
		sampler2D _IncandescenceMap2;
		float4 _IncandescenceOffset2;
	#endif
	
	#ifdef _RIM_ON
		float4 _RimTint2;
		float _RimWeight2;
		float _RimIntensity2;
		float _RimBias2;
		float _RimPower2;
	#endif
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
}

void AlloySurf(
	Input IN, 
	inout AlloySurfaceOutput o) 
{
	half weight = 0.0h;
	float2 texcoords0 = IN.texcoords.xy;
	float2 baseUv = TRANSFORM_TEX(texcoords0, _MainTex);
	half3 emission = half3(0.0h, 0.0h, 0.0h);  
	float2 offset = float2(0.0f, 0.0f);
	half oscillation = _Time.y; 
	half clipval = 1.0h;
	
  	AlloyDissolve(baseUv, offset, emission, clipval);

	// Material Layer 1	
    half3 normalTs = UnpackNormal(tex2D(_BumpMap, baseUv));
    half4 base = _Color * tex2D(_MainTex, baseUv);
    half4 material = tex2D(_MaterialMap, baseUv);
    material.x *= _Metallic;
    material.z *= _Specularity;
    material.w *= _Roughness;
    material.w = 1.0h - material.w; // Roughness to Gloss
    material.y = AlloyGammaToLinearFast(material.y);
    
#ifdef _INCANDESCENCE_ON
    float2 incandescenceUv = baseUv * _IncandescenceOffset.xy + _IncandescenceOffset.zw * oscillation;
	half3 incandescenceMask = tex2D(_IncandescenceMask, baseUv).rgb;
	half3 incandescence = tex2D(_IncandescenceMap, incandescenceUv).rgb;
    incandescence *= incandescenceMask * _IncandescenceTint.rgb;
	incandescence *= AlloyGammaToLinearFast(_IncandescenceWeight * _IncandescenceIntensity);
	
	emission += incandescence;
#endif

#ifdef _DISSOLVEMODE_TRANSITION
	// Material Layer 2
	weight = step(clipval, 0.0h);
	
	half3 emission2 = half3(0.0h, 0.0h, 0.0h);	
    half3 normalTs2 = UnpackNormal(tex2D(_BumpMap2, baseUv));
    half4 base2 = _Color2 * tex2D(_MainTex2, baseUv);
    half4 material2 = tex2D(_MaterialMap2, baseUv);
    material2.x *= _Metallic2;
    material2.z *= _Specularity2;
    material2.w *= _Roughness2;
    material2.w = 1.0h - material2.w; // Roughness to Gloss
    material2.y = AlloyGammaToLinearFast(material2.y);
    
    normalTs = lerp(normalTs, normalTs2, weight);
    base.rgb = lerp(base.rgb, base2.rgb, weight);
    material = lerp(material, material2, weight);
#endif
    
 	// Normal-dependent data
	half ndv = max(0.0h, dot(normalize(IN.viewDir), normalTs)); 
	half3 normalWs = WorldNormalVector(IN, normalTs);
	half3 reflectionWs = WorldReflectionVector(IN, normalTs);
    
#ifdef _RIM_ON
    half3 rimScale = AlloyGammaToLinearFast(half3(_RimWeight, _RimBias, _RimIntensity)); 
    half3 rim = _RimTint.rgb * (rimScale.x * rimScale.z);

	emission += AlloyRimLight(rim, rimScale.y, _RimPower, ndv);
#endif
    
#ifdef _DISSOLVEMODE_TRANSITION
	#ifdef _INCANDESCENCE_ON
	    incandescenceUv = baseUv * _IncandescenceOffset2.xy + _IncandescenceOffset2.zw * oscillation;
		incandescenceMask = tex2D(_IncandescenceMask2, baseUv).rgb;
		incandescence = tex2D(_IncandescenceMap2, incandescenceUv).rgb;
	    incandescence *= incandescenceMask * _IncandescenceTint2.rgb;
		incandescence *= AlloyGammaToLinearFast(_IncandescenceWeight2 * _IncandescenceIntensity2);
		
		emission2 += incandescence;
	#endif
	
	#ifdef _RIM_ON
	    rimScale = AlloyGammaToLinearFast(half3(_RimWeight2, _RimBias2, _RimIntensity2)); 
	    rim = _RimTint2.rgb * (rimScale.x * rimScale.z);

		emission2 += AlloyRimLight(rim, rimScale.y, _RimPower2, ndv);
	#endif
	
	emission = lerp(emission, emission2, weight);
#endif

	AlloySurface(base.a, base.rgb, material, normalTs, emission, ndv, o);
	
	half3 occludedAlbedo = material.y * o.Albedo;
	
	AlloyAmbientBrdf(material.y, occludedAlbedo, o.SpecularColor, IN.worldPos, normalWs, reflectionWs, ndv, o);
}

#endif // ALLOY_TRANSITION_CGINC
