// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file SecondaryTextures.cginc
/// @brief Secondary set of textures.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_SECONDARY_TEXTURES_CGINC
#define ALLOY_SHADERS_FEATURE_SECONDARY_TEXTURES_CGINC

#ifdef A_SECONDARY_TEXTURES_ON
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

#ifdef A_SECONDARY_TEXTURES_ON
    /// The secondary tint color.
    /// Expects a linear LDR color with alpha.
    half4 _Color2;
    
    /// The secondary color map.
    /// Expects an RGB(A) map with sRGB sampling.
    A_SAMPLER_2D(_MainTex2);

    /// The secondary packed material map.
    /// Expects an RGBA data map.
    sampler2D _MaterialMap2;

    /// The secondary normal map.
    /// Expects a compressed normal map.
    sampler2D _BumpMap2;
    
    /// Toggles tinting the secondary color by the vertex color.
    /// Expects values in the range [0,1].
    half _BaseColorVertexTint2;

    /// The secondary metallic scale.
    /// Expects values in the range [0,1].
    half _Metallic2;

    /// The secondary specularity scale.
    /// Expects values in the range [0,1].
    half _Specularity2;

    // Amount that f0 is tinted by the base color.
    /// Expects values in the range [0,1].
    half _SpecularTint2;

    /// The secondary roughness scale.
    /// Expects values in the range [0,1].
    half _Roughness2;
    
    /// Ambient Occlusion strength.
    /// Expects values in the range [0,1].
    half _Occlusion2;

    /// Normal map XY scale.
    half _BumpScale2;
#endif

void aSecondaryTextures(
    inout ASurface s)
{
#ifdef A_SECONDARY_TEXTURES_ON
    ASplatContext sc = aNewSplatContext(s, 1.0h, 1.0f);
    ASplat sp = aNewSplat(sc, A_SAMPLER_2D_INPUT(_MainTex2), _MaterialMap2, _BumpMap2, _Color2, _BaseColorVertexTint2, _Metallic2, _Specularity2, _SpecularTint2, _Roughness2, _Occlusion2, _BumpScale2);

    #ifdef A_SECONDARY_TEXTURES_ALPHA_BLEND_OFF
        aBlendSplat(s, sp);
    #else
        aBlendSplatWithOpacity(s, sp);
    #endif

    // NOTE: These are applied in here so we can use baseUv2.
    float2 baseUv = s.baseUv;

    s.baseUv = A_BV(s, sp.baseUv);
    aEmission2(s);
    aRim2(s);
    s.baseUv = A_BV(s, baseUv);
#endif
}

#endif // ALLOY_SHADERS_FEATURE_SECONDARY_TEXTURES_CGINC
