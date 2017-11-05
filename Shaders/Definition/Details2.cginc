// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Details2.cginc
/// @brief Unity Terrain BillboardWavingDoublePass surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFINITION_DETAILS2_CGINC
#define ALLOY_SHADERS_DEFINITION_DETAILS2_CGINC

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Details2.cginc"

void aSurfaceShader(
    inout ASurface s)
{
    half4 base = aSampleBase(s) * s.vertexColor;

    s.baseColor = base.rgb;
    s.opacity = base.a;
    aCutout(s);
    s.specularity = 0.5h;
    s.roughness = 1.0h;
    s.opacity *= s.vertexColor.a;
}

#endif // ALLOY_SHADERS_DEFINITION_DETAILS2_CGINC
