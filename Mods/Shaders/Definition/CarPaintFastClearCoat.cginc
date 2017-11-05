// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file CarPaintFastClearCoat.cginc
/// @brief Car Paint surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_MODS_SHADERS_DEFINITION_CAR_PAINT_FAST_CLEARCOAT_CGINC
#define ALLOY_MODS_SHADERS_DEFINITION_CAR_PAINT_FAST_CLEARCOAT_CGINC

#define A_METALLIC_ON
#define A_CLEARCOAT_ON
#define A_MAIN_TEXTURES_ON
#define A_CAR_PAINT_ON

#ifndef A_NORMAL_WORLD_ON
    #define A_NORMAL_WORLD_ON
#endif

#ifndef A_VIEW_DIR_WORLD_ON
    #define A_VIEW_DIR_WORLD_ON
#endif

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

/// Clear Coat weight.
/// Expects values in the range [0,1].
half _CarPaintClearCoatWeight;

/// Clear Coat roughness.
/// Expects values in the range [0,1].
half _CarPaintClearCoatRoughness;

void aSurfaceShader(
    inout ASurface s)
{
    aParallax(s);
    aDissolve(s);
    aMainTextures(s);
    aDetail(s);	
    aTeamColor(s);
    
    s.mask = s.opacity;

    // Multi-layer car paint.
    // cf http://www.elliottpacel.co.uk/blog/pbr-practice
    // cf http://blenderartists.org/forum/showthread.php?250127-Car-Paint-Materials-Iridescent-Layers-Carbon-Fiber-Leather&p=2083499&viewfull=1#post2083499
    
    // Two-Tone Paint
    half secondaryColorFalloff = 1.0h - pow(s.NdotV, 0.1 + 9.9h * _CarSecondaryColorFalloff);
    half secondaryColorWeight = _CarSecondaryColorWeight * secondaryColorFalloff;
    half3 paintColor = lerp(_CarPrimaryColor, _CarSecondaryColor, secondaryColorWeight);

    s.baseColor *= aLerpWhiteTo(paintColor, s.mask);

    // Metal Flakes
    // NOTE: Metal brightness will overpower clearcoat, hiding roughness difference.
    float2 flakeUv = A_TEX_TRANSFORM_UV(s, _CarFlakeMap);
    half4 flakes = _CarFlakeColor * tex2D(_CarFlakeMap, flakeUv);
    half flakeMask = pow(flakes.a, _CarFlakeMapFalloff);
    half flakeSpread = pow(s.NdotV, _CarFlakeSpread * -9.9h + 10.0h); //[10,0]
    half flakeWeight = s.mask * flakeMask * flakeSpread * _CarFlakeWeight;

    s.baseColor = lerp(s.baseColor, flakes.rgb, flakeWeight);
    s.metallic = lerp(s.metallic, 1.0h, flakeWeight);
    s.roughness = lerp(s.roughness, 1.0h, flakeWeight * _CarFlakeHighlightSpread);

    s.clearCoat = s.mask * _CarPaintClearCoatWeight;
    s.clearCoatRoughness = _CarPaintClearCoatRoughness;

    s.mask = 1.0h;
    aAo2(s);
    aDecal(s);
    aWetness(s);
    aEmission(s);
    aRim(s);
}

#endif // ALLOY_MODS_SHADERS_DEFINITION_CAR_PAINT_FAST_CLEARCOAT_CGINC
