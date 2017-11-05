// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file VertexBlend.cginc
/// @brief 3-4 splat blending with vertex color weights.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_VERTEX_BLEND_CGINC
#define ALLOY_SHADERS_FEATURE_VERTEX_BLEND_CGINC

#if !defined(A_ALPHA_SPLAT_ON) && defined(_SPECGLOSSMAP)
    #define A_ALPHA_SPLAT_ON
#endif

#ifdef A_VERTEX_BLEND_ON
    #ifndef A_VERTEX_COLOR_IS_DATA
        #define A_VERTEX_COLOR_IS_DATA
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

#ifdef A_VERTEX_BLEND_ON
    half _TriplanarBlendSharpness;

    half4 _Splat0Tint;
    A_SAMPLER_2D(_Splat0);
    sampler2D _MaterialMap0;
    sampler2D _Normal0;
    half _Metallic0;
    half _SplatSpecularity0;
    half _SplatSpecularTint0;
    half _SplatRoughness0;
    half _SplatOcclusion0;
    half _SplatBumpScale0;

    half4 _Splat1Tint;
    A_SAMPLER_2D(_Splat1);
    sampler2D _MaterialMap1;
    sampler2D _Normal1;
    half _Metallic1;
    half _SplatSpecularity1;
    half _SplatSpecularTint1;
    half _SplatRoughness1;
    half _SplatOcclusion1;
    half _SplatBumpScale1;

    half4 _Splat2Tint;
    A_SAMPLER_2D(_Splat2);
    sampler2D _MaterialMap2;
    sampler2D _Normal2;
    half _Metallic2;
    half _SplatSpecularity2;
    half _SplatSpecularTint2;
    half _SplatRoughness2;
    half _SplatOcclusion2;
    half _SplatBumpScale2;

    #ifdef A_ALPHA_SPLAT_ON
        half4 _Splat3Tint;
        A_SAMPLER_2D(_Splat3);
        sampler2D _MaterialMap3;
        sampler2D _Normal3;
        half _Metallic3;
        half _SplatSpecularity3;
        half _SplatSpecularTint3;
        half _SplatRoughness3;
        half _SplatOcclusion3;
        half _SplatBumpScale3;
    #endif
#endif

void aVertexBlend(
    inout ASurface s)
{
#ifdef A_VERTEX_BLEND_ON
    ASplatContext sc = aNewSplatContext(s, _TriplanarBlendSharpness, 1.0f);
    ASplat sp0 = aNewSplat(sc, A_SAMPLER_2D_INPUT(_Splat0), _MaterialMap0, _Normal0, _Splat0Tint, 0.0h, _Metallic0, _SplatSpecularity0, _SplatSpecularTint0, _SplatRoughness0, _SplatOcclusion0, _SplatBumpScale0);
    ASplat sp1 = aNewSplat(sc, A_SAMPLER_2D_INPUT(_Splat1), _MaterialMap1, _Normal1, _Splat1Tint, 0.0h, _Metallic1, _SplatSpecularity1, _SplatSpecularTint1, _SplatRoughness1, _SplatOcclusion1, _SplatBumpScale1);
    ASplat sp2 = aNewSplat(sc, A_SAMPLER_2D_INPUT(_Splat2), _MaterialMap2, _Normal2, _Splat2Tint, 0.0h, _Metallic2, _SplatSpecularity2, _SplatSpecularTint2, _SplatRoughness2, _SplatOcclusion2, _SplatBumpScale2);

    #ifdef A_ALPHA_SPLAT_ON
        half4 splatControl = s.vertexColor;
        ASplat sp3 = aNewSplat(sc, A_SAMPLER_2D_INPUT(_Splat3), _MaterialMap3, _Normal3, _Splat3Tint, 0.0h, _Metallic3, _SplatSpecularity3, _SplatSpecularTint3, _SplatRoughness3, _SplatOcclusion3, _SplatBumpScale3);
    
        splatControl /= (dot(splatControl, A_ONE4) + A_EPSILON);
        aApplyTerrainSplats(s, splatControl, sp0, sp1, sp2, sp3);
    #else
        half3 splatControl = s.vertexColor.xyz;
    
        splatControl /= (dot(splatControl, A_ONE) + A_EPSILON);
        aApplyTerrainSplats(s, splatControl, sp0, sp1, sp2);
    #endif
    
    aCutout(s);
#endif
}

#endif // ALLOY_SHADERS_FEATURE_VERTEX_BLEND_CGINC
