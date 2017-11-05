// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file OrientedTextures.cginc
/// @brief Secondary set of textures using world/object position XZ as their UVs.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_ORIENTED_TEXTURES_CGINC
#define ALLOY_SHADERS_FEATURE_ORIENTED_TEXTURES_CGINC

#ifdef A_ORIENTED_TEXTURES_ON
    #ifndef A_TRIPLANAR_MAPPING_ON
        #define A_TRIPLANAR_MAPPING_ON
    #endif

    #ifndef _TRIPLANARMODE_WORLD
        #define _TRIPLANARMODE_WORLD
    #endif

    #ifndef A_NORMAL_WORLD_ON
        #define A_NORMAL_WORLD_ON
    #endif

    #ifndef A_POSITION_WORLD_ON
        #define A_POSITION_WORLD_ON
    #endif

    #ifndef A_METALLIC_ON
        #define A_METALLIC_ON
    #endif

    #ifndef A_SPECULAR_TINT_ON
        #define A_SPECULAR_TINT_ON
    #endif

    #if !defined(A_AMBIENT_OCCLUSION_ON) && !defined(A_ROUGHNESS_SOURCE_BASE_COLOR_ALPHA)
        #define A_AMBIENT_OCCLUSION_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_ORIENTED_TEXTURES_ON
    /// The world-oriented tint color.
    /// Expects a linear LDR color with alpha.
    half4 _OrientedColor;
    
    /// The world-oriented color map.
    /// Expects an RGB(A) map with sRGB sampling.
    A_SAMPLER_2D(_OrientedMainTex);

    /// The world-oriented packed material map.
    /// Expects an RGBA data map.
    sampler2D _OrientedMaterialMap;

    /// The world-oriented normal map.
    /// Expects a compressed normal map.
    sampler2D _OrientedBumpMap;
    
    /// Toggles tinting the world-oriented color by the vertex color.
    /// Expects values in the range [0,1].
    half _OrientedColorVertexTint;

    /// The world-oriented metallic scale.
    /// Expects values in the range [0,1].
    half _OrientedMetallic;

    /// The world-oriented specularity scale.
    /// Expects values in the range [0,1].
    half _OrientedSpecularity;
    
    // Amount that f0 is tinted by the base color.
    /// Expects values in the range [0,1].
    half _OrientedSpecularTint;

    /// The world-oriented roughness scale.
    /// Expects values in the range [0,1].
    half _OrientedRoughness;

    /// Ambient Occlusion strength.
    /// Expects values in the range [0,1].
    half _OrientedOcclusion;
    
    /// Normal map XY scale.
    half _OrientedNormalMapScale;
#endif

void aOrientedTextures(
    inout ASurface s)
{
#ifdef A_ORIENTED_TEXTURES_ON
    ASplatContext sc = aNewSplatContext(s, 1.0h, 1.0f);
    ASplat sp = aNewSplat();

    sc.blend = A_ONE;
    aTriPlanarY(sp, sc, A_SAMPLER_2D_INPUT(_OrientedMainTex), _OrientedMaterialMap, _OrientedBumpMap, _OrientedOcclusion, _OrientedNormalMapScale);
    aSplatMaterial(sp, sc, _OrientedColor, _OrientedColorVertexTint, _OrientedMetallic, _OrientedSpecularity, _OrientedSpecularTint, _OrientedRoughness);

    #ifdef A_ORIENTED_TEXTURES_BLEND_OFF
        aApplySplat(s, sp);
    #elif defined(A_ORIENTED_TEXTURES_ALPHA_BLEND_OFF)
        aBlendSplat(s, sp);
    #else
        aBlendSplatWithOpacity(s, sp);
    #endif
#endif
}

#endif // ALLOY_SHADERS_FEATURE_ORIENTED_TEXTURES_CGINC
