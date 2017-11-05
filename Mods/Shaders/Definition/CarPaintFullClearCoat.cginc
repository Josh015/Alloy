// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file CarPaint.cginc
/// @brief Car Paint surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_MODS_SHADERS_DEFINITION_CAR_PAINT_CGINC
#define ALLOY_MODS_SHADERS_DEFINITION_CAR_PAINT_CGINC

#define _ALPHABLEND_ON

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

half4 _ClearCoatColor;
half _ClearCoatRoughness;

void aSurfaceShader(
    inout ASurface s)
{
    aParallax(s);
    aDissolve(s);

    // Clear coat should only appear over car paint mask.
    half4 base = _Color * aSampleBase(s);
    s.opacity = base.a * _ClearCoatColor.a;
    s.baseColor = _ClearCoatColor.rgb;
    s.roughness = _ClearCoatRoughness;
    s.specularity = 0.5h;
}

#endif // ALLOY_MODS_SHADERS_DEFINITION_CAR_PAINT_CGINC
