// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file TransitionBlend.cginc
/// @brief Blending using an alpha mask and a cutoff, with a glow effect.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_TRANSITION_BLEND_CGINC
#define ALLOY_SHADERS_FEATURE_TRANSITION_BLEND_CGINC

#ifdef A_TRANSITION_BLEND_ON
    #ifndef A_EMISSIVE_COLOR_ON
        #define A_EMISSIVE_COLOR_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_TRANSITION_BLEND_ON
    /// Transition glow tint color.
    /// Expects a linear HDR color with alpha.
    half4 _TransitionGlowColor; 
    
    /// Transition glow color with effect ramp in the alpha.
    /// Expects an RGBA map with sRGB sampling.
    A_SAMPLER_2D(_TransitionTex);
    
    /// The cutoff value for the transition effect in the ramp map.
    /// Expects values in the range [0,1].
    half _TransitionCutoff;

    #ifndef A_TRANSITION_BLEND_GLOW_OFF
        /// The weight of the transition glow effect.
        /// Expects linear space value in the range [0,1].
        half _TransitionGlowWeight;
    
        /// The width of the transition glow effect.
        /// Expects values in the range [0,1].
        half _TransitionEdgeWidth;
    #endif
#endif

void aTransitionBlend(
    inout ASurface s)
{
#ifdef A_TRANSITION_BLEND_ON
    float2 transitionUv = A_TEX_TRANSFORM_UV(s, _TransitionTex);
    half4 transitionBase = _TransitionGlowColor * tex2D(_TransitionTex, transitionUv);
    half clipval = transitionBase.a * 0.99h - _TransitionCutoff;

    s.mask = clipval >= 0 ? 0.0h : s.mask;

    #ifndef A_TRANSITION_BLEND_GLOW_OFF
        // Transition glow
        half3 glow = s.emissiveColor + transitionBase.rgb * _TransitionGlowWeight;

        glow = clipval >= _TransitionEdgeWidth ? s.emissiveColor : glow; // Outer edge.
        s.emissiveColor = _TransitionCutoff < A_EPSILON ? s.emissiveColor : glow; // Kill when cutoff is zero.
    #endif
#endif
}

#endif // ALLOY_SHADERS_FEATURE_TRANSITION_BLEND_CGINC
