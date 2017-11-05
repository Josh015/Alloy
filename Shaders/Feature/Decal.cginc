// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Decal.cginc
/// @brief Handles vertex-weighted alpha-blended decals.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_DECAL_CGINC
#define ALLOY_SHADERS_FEATURE_DECAL_CGINC

#if !defined(A_DECAL_ON) && defined(_DECAL_ON)
    #define A_DECAL_ON
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_DECAL_ON
    /// The decal tint color.
    /// Expects a linear LDR color with alpha.
    half4 _DecalColor;
    
    /// Decal texture.
    /// Expects an RGBA map with sRGB sampling.
    A_SAMPLER_2D(_DecalTex);
    
    /// Weight of the decal effect.
    /// Expects values in the range [0,1].
    half _DecalWeight;
        
    /// The specularity that will be applied over the decal.
    /// Expects values in the range [0,1].
    half _DecalSpecularity;
    
    /// Toggles tinting the decal alpha by the vertex alpha.
    /// Expects values in the range [0,1].
    half _DecalAlphaVertexTint;
#endif

void aDecal(
    inout ASurface s)
{
#ifdef A_DECAL_ON
    float2 detailUv = A_TEX_TRANSFORM_UV(s, _DecalTex);
    half4 decal = _DecalColor * tex2D(_DecalTex, detailUv);
    half weight = s.mask * _DecalWeight * decal.a * aLerpOneTo(s.vertexColor.a, _DecalAlphaVertexTint);
    
    s.baseColor = lerp(s.baseColor, decal.rgb, weight);
    s.metallic *= 1.0h - weight;
    s.specularity = lerp(s.specularity, _DecalSpecularity, weight);
#endif 
} 

#endif // ALLOY_SHADERS_FEATURE_DECAL_CGINC
