// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Terrain.cginc
/// @brief Terrain surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFINITION_TERRAIN_CGINC
#define ALLOY_SHADERS_DEFINITION_TERRAIN_CGINC

#define A_TERRAIN_ON
#define A_DETAIL_MASK_OFF

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Terrain.cginc"

void aSurfaceShader(
    inout ASurface s)
{
    aTerrain(s);
    aDetail(s);
}

#endif // ALLOY_SHADERS_DEFINITION_TERRAIN_CGINC
