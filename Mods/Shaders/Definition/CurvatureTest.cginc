// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Unlit.cginc
/// @brief Unlit surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_MODS_SHADERS_DEFINITION_UNLIT_CGINC
#define ALLOY_MODS_SHADERS_DEFINITION_UNLIT_CGINC

#define A_POSITION_WORLD_ON
#define A_NORMAL_WORLD_ON
#define A_EMISSIVE_COLOR_ON

#include "Assets/Alloy/Shaders/Lighting/Unlit.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

half _CurvatureScale;

void aSurfaceShader(
    inout ASurface s)
{
    // Otherwise stick with ddx or dFdx, which can be replaced with fwidth.
    float deltaWorldNormal = length(fwidth(s.normalWorld));
    float deltaWorldPosition = length(fwidth(s.positionWorld));

    s.emissiveColor = ((deltaWorldNormal / deltaWorldPosition) * _CurvatureScale).rrr;
}

#endif // ALLOY_MODS_SHADERS_DEFINITION_UNLIT_CGINC
