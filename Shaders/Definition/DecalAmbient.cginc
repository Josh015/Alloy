// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file DecalAmbient.cginc
/// @brief Ambient deferred decal surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFINITION_DECAL_AMBIENT_CGINC
#define ALLOY_SHADERS_DEFINITION_DECAL_AMBIENT_CGINC

#include "Assets/Alloy/Shaders/Lighting/Unlit.cginc"
#include "Assets/Alloy/Shaders/Type/DecalAmbient.cginc"

void aSurfaceShader(
    inout ASurface s)
{
    half4 base = aBase(s);

    s.baseColor = aLerpWhiteTo(base.rgb, base.a);
    aTeamColor(s);
}

#endif // ALLOY_SHADERS_DEFINITION_DECAL_AMBIENT_CGINC
