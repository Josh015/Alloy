// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file SpeedTreeBillboard.cginc
/// @brief SpeedTree Billboard surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFINITION_SPEED_TREE_BILLBOARD_CGINC
#define ALLOY_SHADERS_DEFINITION_SPEED_TREE_BILLBOARD_CGINC

#define A_SPEED_TREE_ON

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/SpeedTreeBillboard.cginc"

void aSurfaceShader(
    inout ASurface s)
{
    aSpeedTree(s);
    s.roughness = 1.0h;
}

#endif // ALLOY_SHADERS_DEFINITION_SPEED_TREE_BILLBOARD_CGINC
