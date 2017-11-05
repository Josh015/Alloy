// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Rim2.cginc
/// @brief Secondary rim lighting effects.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_RIM2_CGINC
#define ALLOY_SHADERS_FEATURE_RIM2_CGINC

#if !defined(A_RIM2_ON) && defined(_RIM2_ON)
    #define A_RIM2_ON
#endif

#ifdef A_RIM2_ON
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

#ifdef A_RIM2_ON
    /// Secondary rim lighting tint color.
    /// Expects a linear HDR color.
    half3 _Rim2Color;

    #ifndef A_RIM2_EFFECTS_MAP_OFF
        /// Secondary rim effect texture.
        /// Expects an RGB map with sRGB sampling.
        A_SAMPLER_2D(_RimTex2);
    #endif
    
    /// The weight of the secondary rim lighting effect.
    /// Expects linear space value in the range [0,1].
    half _Rim2Weight;
    
    /// Fills in the center of the secondary rim lighting effect.
    /// Expects linear-space values in the range [0,1].
    half _Rim2Bias;
    
    /// Controls the falloff of the secondary rim lighting effect.
    /// Expects values in the range [0.01,n].
    half _Rim2Power;
#endif

void aRim2(
    inout ASurface s)
{	
#ifdef A_RIM2_ON 
    half3 rim = _Rim2Color;

    #ifndef A_RIM2_EFFECTS_MAP_OFF
        float2 rimUv2 = A_TEX_TRANSFORM_UV_SCROLL(s, _RimTex2);
        rim *= tex2D(_RimTex2, rimUv2).rgb;
    #endif
    
    s.emissiveColor += rim * aRimLight(_Rim2Weight * s.mask, _Rim2Bias, _Rim2Power, s.NdotV);
#endif
} 

#endif // ALLOY_SHADERS_FEATURE_RIM2_CGINC
