// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Transmission.cginc
/// @brief Basic transmission, handling render path differences.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_TRANSMISSION_CGINC
#define ALLOY_SHADERS_FEATURE_TRANSMISSION_CGINC

#ifdef A_TRANSMISSION_ON
    #ifndef A_SUBSURFACE_ON
        #define A_SUBSURFACE_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_TRANSMISSION_ON
    /// Transmission tint color.
    /// Expects a linear LDR color.
    half3 _TransColor;

    /// Transmission color * thickness texture.
    /// Expects an RGB map with sRGB sampling.
    sampler2D _TransTex;

    /// Weight of the transmission effect.
    /// Expects linear-space values in the range [0,1].
    half _TransScale;
#endif

void aTransmission(
    inout ASurface s) 
{
#ifdef A_TRANSMISSION_ON
    s.subsurfaceColor = A_SSC(s, _TransScale * tex2D(_TransTex, s.baseUv).rgb);
    s.subsurfaceColor *= _TransColor;
#endif
} 

#endif // ALLOY_SHADERS_FEATURE_TRANSMISSION_CGINC
