// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Core.cginc
/// @brief Core & Glass surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFINITION_CORE_CGINC
#define ALLOY_SHADERS_DEFINITION_CORE_CGINC

#define A_MAIN_TEXTURES_ON

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

void aSurfaceShader(
    inout ASurface s)
{
    aParallax(s);
    aDissolve(s);
    aMainTextures(s);
    aDetail(s);
    aTeamColor(s);
    aAo2(s);
    aDecal(s);
    aWetness(s);
    aRim(s);
    aEmission(s);
}

#endif // ALLOY_SHADERS_DEFINITION_CORE_CGINC
