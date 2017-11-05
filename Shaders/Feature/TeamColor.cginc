// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file TeamColor.cginc
/// @brief Team Color via texture color component masks and per-mask tint colors.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_TEAMCOLOR_CGINC
#define ALLOY_SHADERS_FEATURE_TEAMCOLOR_CGINC

#if !defined(A_TEAMCOLOR_ON) && defined(_TEAMCOLOR_ON)
    #define A_TEAMCOLOR_ON
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_TEAMCOLOR_ON
    /// Toggles using the mask texture as a color tint.
    /// Expects either 0 or 1.
    float _TeamColorMasksAsTint;

    /// Mask map that stores a tint mask in each channel.
    /// Expects an RGB(A) data map.
    sampler2D _TeamColorMaskMap;
    
    /// Toggles which channels to use from the masks map.
    /// Expects a vector where each component is either 0 or 1;
    half4 _TeamColorMasks;
    
    /// The red channel mask tint color.
    /// Expects a linear LDR color.
    half3 _TeamColor0;
    
    /// The green channel mask tint color.
    /// Expects a linear LDR color.
    half3 _TeamColor1;
    
    /// The blue channel mask tint color.
    /// Expects a linear LDR color.
    half3 _TeamColor2;
    
    /// The alpha channel mask tint color.
    /// Expects a linear LDR color.
    half3 _TeamColor3;
#endif

void aTeamColor(
    inout ASurface s) 
{
#ifdef A_TEAMCOLOR_ON
    half4 masksColor = tex2D(_TeamColorMaskMap, s.baseUv);
    half4 masks = s.mask * (_TeamColorMasks * masksColor);
    half weight = dot(masks, A_ONE4);
    
    // Renormalize masks when their combined weight sums to greater than one.
    masks /= max(1.0h, weight);
    
    // Combine colors, then fill to white where weights sum to less than one.
    half3 teamColor = _TeamColor0 * masks.r 
                    + _TeamColor1 * masks.g 
                    + _TeamColor2 * masks.b 
                    + _TeamColor3 * masks.a 
                    + saturate(1.0h - weight).rrr;

    s.baseColor *= _TeamColorMasksAsTint < 0.5f ? teamColor : masksColor.rgb;
#endif
} 

#endif // ALLOY_SHADERS_FEATURE_TEAMCOLOR_CGINC
