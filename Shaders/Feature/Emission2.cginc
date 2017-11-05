// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Emission2.cginc
/// @brief Secondary emission effects.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_EMISSION2_CGINC
#define ALLOY_SHADERS_FEATURE_EMISSION2_CGINC

#if !defined(A_EMISSION2_ON) && defined(_EMISSION2_ON)
    #define A_EMISSION2_ON
#endif

#ifdef A_EMISSION2_ON
    #ifndef A_EMISSIVE_COLOR_ON
        #define A_EMISSIVE_COLOR_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_EMISSION2_ON
    /// Secondary emission tint color.
    /// Expects a linear LDR color.
    half3 _Emission2Color;
    
    #ifndef A_EMISSION2_MASK_MAP_OFF
        //// Secondary emission mask texture.
        /// Expects an RGB map with sRGB sampling.
        sampler2D _EmissionMap2;
    #endif

    #ifndef A_EMISSION2_EFFECTS_MAP_OFF
        /// Secondary emission effect texture.
        /// Expects an RGB map with sRGB sampling.
        A_SAMPLER_2D(_IncandescenceMap2);
    #endif
    
    /// The weight of the secondary emission effect.
    /// Expects linear space value in the range [0,1].
    half _Emission2Weight;
#endif

void aEmission2(
    inout ASurface s)
{
#ifdef A_EMISSION2_ON
    half3 emission = _Emission2Color;

    #ifndef A_EMISSION2_MASK_MAP_OFF
        emission *= tex2D(_EmissionMap2, s.baseUv).rgb; 
    #endif

    #ifndef A_EMISSION2_EFFECTS_MAP_OFF
        float2 incandescenceUv2 = A_TEX_TRANSFORM_UV_SCROLL(s, _IncandescenceMap2);
        emission *= tex2D(_IncandescenceMap2, incandescenceUv2).rgb;
    #endif
    
    s.emissiveColor += emission * (_Emission2Weight * s.mask);
#endif
} 

#endif // ALLOY_SHADERS_FEATURE_EMISSION2_CGINC
