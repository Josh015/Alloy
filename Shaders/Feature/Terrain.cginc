// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Terrain.cginc
/// @brief Unity terrain mapping.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_TERRAIN_CGINC
#define ALLOY_SHADERS_FEATURE_TERRAIN_CGINC

#ifdef A_TERRAIN_ON
    #ifndef A_ROUGHNESS_SOURCE_BASE_COLOR_ALPHA
        #define A_ROUGHNESS_SOURCE_BASE_COLOR_ALPHA
    #endif

    #ifndef A_TERRAIN_DISTANT
        #ifndef A_VIEW_DEPTH_ON
            #define A_VIEW_DEPTH_ON
        #endif
    #else
        // Needed for detail normal map.
        #ifndef A_NORMAL_MAPPING_ON
            #define A_NORMAL_MAPPING_ON 
        #endif
    #endif

    #ifndef A_METALLIC_ON
        #define A_METALLIC_ON
    #endif

    #ifndef A_SPECULAR_TINT_ON
        #define A_SPECULAR_TINT_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_TERRAIN_ON
    #ifdef A_TERRAIN_DISTANT
        sampler2D _MetallicTex;
    #else
        A_SAMPLER_2D(_Control);
        half _TriplanarBlendSharpness;
    
        A_SAMPLER_2D(_Splat0);
        sampler2D _Normal0;
        half _Metallic0;
        half _SplatSpecularity0;
        half _SplatSpecularTint0;

        A_SAMPLER_2D(_Splat1);
        sampler2D _Normal1;
        half _Metallic1;
        half _SplatSpecularity1;
        half _SplatSpecularTint1;

        A_SAMPLER_2D(_Splat2);
        sampler2D _Normal2;
        half _Metallic2;
        half _SplatSpecularity2;
        half _SplatSpecularTint2;

        A_SAMPLER_2D(_Splat3);
        sampler2D _Normal3;
        half _Metallic3;
        half _SplatSpecularity3;
        half _SplatSpecularTint3;
    
        half _FadeDist;
        half _FadeRange;
    #endif

    half _DistantSpecularity;
    half _DistantSpecularTint;
    half _DistantRoughness;
#endif

void aTerrain(
    inout ASurface s) 
{
#ifdef A_TERRAIN_ON
    #ifdef A_TERRAIN_DISTANT
        half4 col = aSampleBase(s);
    
        s.baseColor = col.rgb;
        s.metallic = tex2D (_MetallicTex, s.baseUv).r;	
        s.specularity = _DistantSpecularity;
        s.specularTint = _DistantSpecularTint;
        s.roughness = col.a * _DistantRoughness;
    #else
        // Create a smooth blend between near and distant terrain to hide transition.
        // NOTE: Can't kill specular completely since we have to worry about deferred.
        half fade = saturate((s.viewDepth - _FadeDist) / _FadeRange);
        half4 splatControl = tex2D(_Control, A_TEX_TRANSFORM(s, _Control));
        half weight = dot(splatControl, A_ONE4);
    
        #if !defined(SHADER_API_MOBILE) && defined(A_TERRAIN_NSPLAT_ADDPASS_SHADER)
            clip(weight == 0.0f ? -1 : 1);
        #endif

        // NOTE: 0.01 matches tiling of distant terrain combined maps.
        ASplatContext sc = aNewSplatContext(s, _TriplanarBlendSharpness, 0.01f);
        ASplat sp0 = aNewSplat(sc, A_SAMPLER_2D_INPUT(_Splat0), _Splat0, _Normal0, A_WHITE4, 0.0h, _Metallic0, _SplatSpecularity0, _SplatSpecularTint0, 1.0h, 1.0h, 1.0h);
        ASplat sp1 = aNewSplat(sc, A_SAMPLER_2D_INPUT(_Splat1), _Splat1, _Normal1, A_WHITE4, 0.0h, _Metallic1, _SplatSpecularity1, _SplatSpecularTint1, 1.0h, 1.0h, 1.0h);
        ASplat sp2 = aNewSplat(sc, A_SAMPLER_2D_INPUT(_Splat2), _Splat2, _Normal2, A_WHITE4, 0.0h, _Metallic2, _SplatSpecularity2, _SplatSpecularTint2, 1.0h, 1.0h, 1.0h);
        ASplat sp3 = aNewSplat(sc, A_SAMPLER_2D_INPUT(_Splat3), _Splat3, _Normal3, A_WHITE4, 0.0h, _Metallic3, _SplatSpecularity3, _SplatSpecularTint3, 1.0h, 1.0h, 1.0h);

        splatControl /= (weight + A_EPSILON);
        aApplyTerrainSplats(s, splatControl, sp0, sp1, sp2, sp3);
        
        #ifdef A_TERRAIN_NSPLAT_SHADER
            s.specularity = _DistantSpecularity;
            s.specularTint = _DistantSpecularTint;
        #else
            s.specularity = lerp(s.specularity, _DistantSpecularity, fade);
            s.specularTint = lerp(s.specularTint, _DistantSpecularTint, fade);
        #endif

        s.roughness *= aLerpOneTo(_DistantRoughness, fade);
        s.normalTangent = A_NT(s, normalize(lerp(s.normalTangent, A_FLAT_NORMAL, fade)));

        s.opacity = weight; // Last to avoid being overwritten.
    #endif
#endif
} 

#endif // ALLOY_SHADERS_FEATURE_TERRAIN_CGINC
