// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Transition.cginc
/// @brief Transition & Weighted Blend shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFINITION_TRANSITION_CGINC
#define ALLOY_SHADERS_DEFINITION_TRANSITION_CGINC

#define A_MAIN_TEXTURES_ON
#define A_MAIN_TEXTURES_CUTOUT_OFF
#define A_TRANSITION_BLEND_ON
#define A_SECONDARY_TEXTURES_ON
#define A_SECONDARY_TEXTURES_ALPHA_BLEND_OFF

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

void aSurfaceShader(
    inout ASurface s)
{
    aTransitionBlend(s);

    s.mask = 1.0h - s.mask;
    aParallax(s);
    aMainTextures(s);

    s.mask = 1.0h - s.mask;
    aSecondaryTextures(s);
    aCutout(s);

    s.mask = 1.0h - s.mask;
    aDetail(s);
    aTeamColor(s);
    aDecal(s);
    aWetness(s);
    aEmission(s);
    aRim(s);
    
    s.mask = 1.0h;
    aDissolve(s);
    aAo2(s);
}

#endif // ALLOY_SHADERS_DEFINITION_TRANSITION_CGINC
