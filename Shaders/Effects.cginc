// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Effects.cginc
/// @brief Surface emission effects.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_EFFECTS_CGINC
#define ALLOY_EFFECTS_CGINC

#include "Assets/Alloy/Shaders/Utility.cginc"

#ifdef _RIM_ON
	float4 _RimTint;
	float _RimWeight;
	float _RimIntensity;
	float _RimBias;
	float _RimPower;
    sampler2D _RimTex;
    float4 _RimOffset;
#endif

#ifdef _INCANDESCENCE_ON
	float4 _IncandescenceTint;
	float _IncandescenceWeight;
	float _IncandescenceIntensity;
	sampler2D _IncandescenceMask;
	sampler2D _IncandescenceMap;
	float4 _IncandescenceOffset;
#endif

void AlloyEffects(float2 baseUv, float2 offset, half ndv, inout half3 emission) {
	float oscillation = _Time.y; 
	
#ifdef _RIM_ON
	float2 rimUv = baseUv * _RimOffset.xy + _RimOffset.zw * oscillation + offset;
    half3 rim = tex2D(_RimTex, rimUv).rgb;
    half3 rimScale = AlloyGammaToLinearFast(half3(_RimWeight, _RimBias, _RimIntensity)); 
    rim *= _RimTint.rgb * (rimScale.x * rimScale.z);

	emission += AlloyRimLight(rim, rimScale.y, _RimPower, ndv);
#endif

#ifdef _INCANDESCENCE_ON
    float2 incandescenceUv = baseUv * _IncandescenceOffset.xy + _IncandescenceOffset.zw * oscillation + offset;
	half3 incandescenceMask = tex2D(_IncandescenceMask, baseUv + offset).rgb;
	half3 incandescence = tex2D(_IncandescenceMap, incandescenceUv).rgb;
    incandescence *= incandescenceMask * _IncandescenceTint.rgb;
	incandescence *= AlloyGammaToLinearFast(_IncandescenceWeight * _IncandescenceIntensity);
	
	emission += incandescence;
#endif
} 

#endif // ALLOY_EFFECTS_CGINC
