// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Skin.cginc
/// @brief Skin surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_MODS_SHADERS_DEFINITION_SKIN_CGINC
#define ALLOY_MODS_SHADERS_DEFINITION_SKIN_CGINC

#ifndef A_VERTEX_COLOR_IS_DATA
    #define A_VERTEX_COLOR_IS_DATA
#endif

#define A_NORMAL_MAPPING_ON
#define A_SKIN_TEXTURES_ON
#define A_DETAIL_MASK_VERTEX_COLOR_ALPHA_ON
#define A_DETAIL_COLOR_MAP_OFF

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

// Red Detail.
half _RedDetailMaskStrength;
A_SAMPLER_2D(_RedDetailNormalMap);
half _RedDetailWeight;
half _RedDetailNormalMapScale;

// Green Detail.
half _GreenDetailMaskStrength;
A_SAMPLER_2D(_GreenDetailNormalMap);
half _GreenDetailWeight;
half _GreenDetailNormalMapScale;

// Blue Detail.
half _BlueDetailMaskStrength;
A_SAMPLER_2D(_BlueDetailNormalMap);
half _BlueDetailWeight;
half _BlueDetailNormalMapScale;

void aSurfaceShader(
    inout ASurface s)
{
    aParallax(s);
    aDissolve(s);
    aSkinTextures(s);
    
    // Red Detail.
    half mask = _RedDetailWeight * aLerpOneTo(s.vertexColor.r, _RedDetailMaskStrength);
    float2 detailUv = A_TEX_TRANSFORM_UV_SCROLL(s, _RedDetailNormalMap);
    half3 detailNormalTangent = UnpackScaleNormal(tex2D(_RedDetailNormalMap, detailUv), mask * _RedDetailNormalMapScale);
    s.normalTangent = A_NT(s, BlendNormals(s.normalTangent, detailNormalTangent));

    // Green Detail.
    mask = _GreenDetailWeight * aLerpOneTo(s.vertexColor.g, _GreenDetailMaskStrength);
    detailUv = A_TEX_TRANSFORM_UV_SCROLL(s, _GreenDetailNormalMap);
    detailNormalTangent = UnpackScaleNormal(tex2D(_GreenDetailNormalMap, detailUv), mask * _GreenDetailNormalMapScale);
    s.normalTangent = A_NT(s, BlendNormals(s.normalTangent, detailNormalTangent));

    // Blue Detail.
    mask = _BlueDetailWeight * aLerpOneTo(s.vertexColor.b, _BlueDetailMaskStrength);
    detailUv = A_TEX_TRANSFORM_UV_SCROLL(s, _BlueDetailNormalMap);
    detailNormalTangent = UnpackScaleNormal(tex2D(_BlueDetailNormalMap, detailUv), mask * _BlueDetailNormalMapScale);
    s.normalTangent = A_NT(s, BlendNormals(s.normalTangent, detailNormalTangent));

    aDetail(s);
    aTeamColor(s);
    aDecal(s);
    aWetness(s);	
    aRim(s);
    aEmission(s);
}

#endif // ALLOY_MODS_SHADERS_DEFINITION_SKIN_CGINC
