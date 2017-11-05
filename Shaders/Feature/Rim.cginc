// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Rim.cginc
/// @brief Rim lighting effects.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_RIM_CGINC
#define ALLOY_SHADERS_FEATURE_RIM_CGINC

#if !defined(A_RIM_ON) && defined(_RIM_ON)
    #define A_RIM_ON
#endif

#ifdef A_RIM_ON
    #ifndef A_NORMAL_WORLD_ON
        #define A_NORMAL_WORLD_ON
    #endif

    #ifndef A_VIEW_DIR_WORLD_ON
        #define A_VIEW_DIR_WORLD_ON
    #endif

    #ifndef A_EMISSIVE_COLOR_ON
        #define A_EMISSIVE_COLOR_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_RIM_ON
    /// Rim lighting tint color.
    /// Expects a linear HDR color.
    half3 _RimColor;

    #ifndef A_RIM_EFFECTS_MAP_OFF
        /// Rim effect texture.
        /// Expects an RGB map with sRGB sampling.
        A_SAMPLER_2D(_RimTex);
    #endif
    
    /// The weight of the rim lighting effect.
    /// Expects linear space value in the range [0,1].
    half _RimWeight;
    
    /// Fills in the center of the rim lighting effect.
    /// Expects linear-space values in the range [0,1].
    half _RimBias;
    
    /// Controls the falloff of the rim lighting effect.
    /// Expects values in the range [0.01,n].
    half _RimPower;
#endif

void aRim(
    inout ASurface s)
{	
#ifdef A_RIM_ON 
    half3 rim = _RimColor;

    #ifndef A_RIM_EFFECTS_MAP_OFF
        float2 rimUv = A_TEX_TRANSFORM_UV_SCROLL(s, _RimTex);
        rim *= tex2D(_RimTex, rimUv).rgb;
    #endif
    
    s.emissiveColor += rim * aRimLight(_RimWeight * s.mask, _RimBias, _RimPower, s.NdotV);
#endif
} 

#endif // ALLOY_SHADERS_FEATURE_RIM_CGINC
