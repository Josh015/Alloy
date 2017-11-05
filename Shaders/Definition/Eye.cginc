// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Eye.cginc
/// @brief Eye surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFINITION_EYE_CGINC
#define ALLOY_SHADERS_DEFINITION_EYE_CGINC

#define A_EYE_ON
#define A_DETAIL_MASK_OFF
#define A_DETAIL_COLOR_MAP_OFF

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

void aSurfaceShader(
    inout ASurface s)
{
    aEye(s);
    aDetail(s);

    s.mask = 1.0h;
    aDissolve(s);
    aDecal(s);
    aEmission(s);
    aRim(s);
}

#endif // ALLOY_SHADERS_DEFINITION_EYE_CGINC
