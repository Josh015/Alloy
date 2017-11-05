// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file SPCarPaint.cginc
/// @brief SP Car Paint surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_MODS_SHADERS_DEFINITION_SP_CAR_PAINT_CGINC
#define ALLOY_MODS_SHADERS_DEFINITION_SP_CAR_PAINT_CGINC

#define A_CLEARCOAT_ON
#define A_MAIN_TEXTURES_ON

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

/// The secondary paint tint color.
/// Expects a linear LDR color.
half3 _CarPaintSecondaryColor;

/// The tertiary paint tint color.
/// Expects a linear LDR color.
half3 _CarPaintTertiaryColor;

/// Clear Coat weight.
/// Expects values in the range [0,1].
half _CarPaintClearCoatWeight;

/// Clear Coat roughness.
/// Expects values in the range [0,1].
half _CarPaintClearCoatRoughness;

/// The metallic flake tint color.
/// Expects a linear LDR color.
half3 _CarPaintFlakeColor;

/// Flake normal map.
/// Expects a compressed normal map.
A_SAMPLER_2D(_CarPaintFlakeNormalMap);

/// Flake weight.
/// Expects values in the range [0,1].
half _CarPaintFlakeWeight;

void aSurfaceShader(
    inout ASurface s)
{
    aParallax(s);
    aDissolve(s);
    aMainTextures(s);
    aDetail(s);	
    aTeamColor(s);
    
    s.mask = s.opacity;

    // Two-tone car paint with metal flakes.
    // http://www.chrisoat.com/papers/Oat-Tatarchuk-Isidoro-Layered_Car_Paint_Shader_Print.pdf
    float2 flakeUv = A_TEX_TRANSFORM_UV(s, _CarPaintFlakeNormalMap);
    half3 flakeNormalTangent = UnpackScaleNormal(tex2D(_CarPaintFlakeNormalMap, flakeUv), 1.0h);
    half3 paintNpWorld = aTangentToWorld(s, 0.2h * flakeNormalTangent + s.normalTangent);
    half3 flakeNpWorld = aTangentToWorld(s, _CarPaintFlakeWeight * flakeNormalTangent + s.normalTangent);
    half fresnel1 = aDotClamp(paintNpWorld, s.viewDirWorld);
    half fresnel2 = aDotClamp(flakeNpWorld, s.viewDirWorld);
    half fresnel1Sq = fresnel1 * fresnel1;
    half3 paintColor = fresnel1 * s.baseColor +
        fresnel1Sq * _CarPaintSecondaryColor +
        fresnel1Sq * fresnel1Sq * _CarPaintTertiaryColor +
        pow(fresnel2, 16.0h) * _CarPaintFlakeColor;

    // Clear Coat
    s.baseColor = lerp(s.baseColor, paintColor, s.mask);
    s.clearCoat = s.mask * _CarPaintClearCoatWeight;
    s.clearCoatRoughness = _CarPaintClearCoatRoughness;

    s.mask = 1.0h;
    aAo2(s);
    aDecal(s);
    aWetness(s);
    aEmission(s);
    aRim(s);
}

#endif // ALLOY_MODS_SHADERS_DEFINITION_SP_CAR_PAINT_CGINC
