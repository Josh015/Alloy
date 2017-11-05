// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file MainTextures.cginc
/// @brief Main set of textures.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_MAIN_TEXTURES_CGINC
#define ALLOY_SHADERS_FEATURE_MAIN_TEXTURES_CGINC

#ifdef A_MAIN_TEXTURES_ON
    #ifndef A_MAIN_TEXTURES_MATERIAL_MAP_OFF
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
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

void aMainTextures(
    inout ASurface s)
{
#ifdef A_MAIN_TEXTURES_ON
    half4 tint = aBaseTint(s);
    half4 base = aSampleBase(s);

    #ifdef A_ROUGHNESS_SOURCE_BASE_COLOR_ALPHA
        s.baseColor = tint.rgb * base.rgb;
        s.opacity = tint.a;

        s.metallic = _Metal;
        s.ambientOcclusion = 1.0h;
        s.specularity = _Specularity;
        s.specularTint = _SpecularTint;
        s.roughness = _Roughness * base.a;
    #else
        base *= tint;
        s.baseColor = base.rgb;
        s.opacity = base.a;

        #ifndef A_MAIN_TEXTURES_CUTOUT_OFF
            aCutout(s);
        #endif
    
        #ifndef A_MAIN_TEXTURES_MATERIAL_MAP_OFF
            half4 material = aSampleMaterial(s);

            s.metallic = _Metal * material.A_METALLIC_CHANNEL;
            s.ambientOcclusion = aLerpOneTo(material.A_AO_CHANNEL, _Occlusion);
            s.specularity = _Specularity * material.A_SPECULARITY_CHANNEL;
            s.specularTint = _SpecularTint;
            s.roughness = _Roughness * material.A_ROUGHNESS_CHANNEL;
        #endif
    #endif

    s.normalTangent = A_NT(s, aSampleBump(s));
#endif
}

#endif // ALLOY_SHADERS_FEATURE_MAIN_TEXTURES_CGINC
