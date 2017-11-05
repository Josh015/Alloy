// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file VertexBlend.cginc
/// @brief Vertex Blend shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_LEGACY_SHADERS_DEFINITION_VERTEX_BLEND_CGINC
#define ALLOY_LEGACY_SHADERS_DEFINITION_VERTEX_BLEND_CGINC

#define A_ROUGHNESS_SOURCE_BASE_COLOR_ALPHA

#ifndef A_VERTEX_COLOR_IS_DATA
    #define A_VERTEX_COLOR_IS_DATA
#endif

#define A_METALLIC_ON
#define A_SPECULAR_TINT_ON
#define A_DETAIL_MASK_OFF

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

half _TriplanarBlendSharpness;

half4 _Splat0Tint;
A_SAMPLER_2D(_Splat0);
sampler2D _Normal0;
half _Metallic0;
half _SplatSpecularity0;
half _SplatSpecularTint0;
half _SplatRoughness0;

half4 _Splat1Tint;
A_SAMPLER_2D(_Splat1);
sampler2D _Normal1;
half _Metallic1;
half _SplatSpecularity1;
half _SplatSpecularTint1;
half _SplatRoughness1;

half4 _Splat2Tint;
A_SAMPLER_2D(_Splat2);
sampler2D _Normal2;
half _Metallic2;
half _SplatSpecularity2;
half _SplatSpecularTint2;
half _SplatRoughness2;

half4 _Splat3Tint;
A_SAMPLER_2D(_Splat3);
sampler2D _Normal3;
half _Metallic3;
half _SplatSpecularity3;
half _SplatSpecularTint3;
half _SplatRoughness3;

void aSurfaceShader(
    inout ASurface s)
{	
    half4 splatControl = s.vertexColor;
    
    splatControl /= (dot(splatControl, A_ONE4) + A_EPSILON);

    ASplatContext sc = aNewSplatContext(s, _TriplanarBlendSharpness, 1.0f);
    ASplat sp0 = aNewSplat(sc, A_SAMPLER_2D_INPUT(_Splat0), _Splat0, _Normal0, _Splat0Tint, 0.0h, _Metallic0, _SplatSpecularity0, _SplatSpecularTint0, _SplatRoughness0, 1.0h, 1.0h);
    ASplat sp1 = aNewSplat(sc, A_SAMPLER_2D_INPUT(_Splat1), _Splat1, _Normal1, _Splat1Tint, 0.0h, _Metallic1, _SplatSpecularity1, _SplatSpecularTint1, _SplatRoughness1, 1.0h, 1.0h);
    ASplat sp2 = aNewSplat(sc, A_SAMPLER_2D_INPUT(_Splat2), _Splat2, _Normal2, _Splat2Tint, 0.0h, _Metallic2, _SplatSpecularity2, _SplatSpecularTint2, _SplatRoughness2, 1.0h, 1.0h);
    ASplat sp3 = aNewSplat(sc, A_SAMPLER_2D_INPUT(_Splat3), _Splat3, _Normal3, _Splat3Tint, 0.0h, _Metallic3, _SplatSpecularity3, _SplatSpecularTint3, _SplatRoughness3, 1.0h, 1.0h);
    
    aApplyTerrainSplats(s, splatControl, sp0, sp1, sp2, sp3);
    aCutout(s);
    aDetail(s);
}

#endif // ALLOY_LEGACY_SHADERS_DEFINITION_VERTEX_BLEND_CGINC
