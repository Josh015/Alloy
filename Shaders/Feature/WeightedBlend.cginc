// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file WeightedBlend.cginc
/// @brief Blending with a heightmap, a cutoff value, and the vertex color alpha.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_WEIGHTED_BLEND_CGINC
#define ALLOY_SHADERS_FEATURE_WEIGHTED_BLEND_CGINC

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_WEIGHTED_BLEND_ON
    /// Heightmap used for blending.
    /// Expects an RGB data map.
    A_SAMPLER_2D(_BlendMap);
    
    /// Heightmap Blend weight.
    /// Expects values in the range [0,1].
    half _BlendScale;
    
    /// Height cutoff where blend begins.
    /// Expects values in the range [0,1].
    half _BlendCutoff;
    
    /// Offset from cutoff where smooth blending occurs.
    /// Expects values in the range [0.0001,1].
    half _Blend; 
    
    /// Controls how much the vertex color alpha influences the cutoff.
    /// Expects values in the range [0,1].
    half _BlendAlphaVertexTint;
#endif

void aHeightmapBlend(
    inout ASurface s)
{
#ifdef A_WEIGHTED_BLEND_ON
    float2 blendUv = A_TEX_TRANSFORM_UV(s, _BlendMap);
    half mask = tex2D(_BlendMap, blendUv).g;
    
    aBlendRangeMask(s, mask, _BlendScale, _BlendCutoff, _Blend, _BlendAlphaVertexTint);
#endif
}

#endif // ALLOY_SHADERS_FEATURE_WEIGHTED_BLEND_CGINC
