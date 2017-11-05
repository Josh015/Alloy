// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Dissolve.cginc
/// @brief Surface dissolve effects.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_DISSOLVE_CGINC
#define ALLOY_DISSOLVE_CGINC

#include "Assets/Alloy/Shaders/Utility.cginc"

#if defined(_DISSOLVEMODE_DISSOLVE) || defined(_DISSOLVEMODE_TRANSITION)
	float4 _DissolveColor; 
	float4 _DissolveTex_ST;
	sampler2D _DissolveTex;
	float _DissolveCutoff;
	float _DissolveEdgeWidth;
	float _DissolveGlowIntensity;
	float4 _DissolveOffset;
#endif

void AlloyDissolve(float2 baseUv, float2 offset, inout half3 emission, inout half clipval) {
#if defined(_DISSOLVEMODE_DISSOLVE) || defined(_DISSOLVEMODE_TRANSITION)
	half weight = 0.0h;
	float2 dissolveUv = TRANSFORM_TEX(baseUv, _DissolveTex) + offset;
	half4 dissolveBase = _DissolveColor * tex2D(_DissolveTex, dissolveUv);
	half cutoff = _DissolveCutoff * 1.01h;
	
	clipval = dissolveBase.a - cutoff;
	
	#ifdef _DISSOLVEMODE_DISSOLVE
		clip(clipval);
	#endif

	// Dissolve glow
	weight = step(clipval, _DissolveEdgeWidth) * step(0.0h, clipval) * step(0.01h, cutoff);
	emission += weight * dissolveBase.rgb * AlloyGammaToLinearFast(_DissolveGlowIntensity);
#endif
} 

#endif // ALLOY_DISSOLVE_CGINC
