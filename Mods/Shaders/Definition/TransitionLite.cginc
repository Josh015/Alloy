// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file TransitionLite.cginc
/// @brief Transition Lite shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_MODS_SHADERS_DEFINITION_TRANSITION_LITE_CGINC
#define ALLOY_MODS_SHADERS_DEFINITION_TRANSITION_LITE_CGINC

#define A_DISSOLVE_GLOW_OFF
#define A_MAIN_TEXTURES_ON
#define A_TRANSITION_BLEND_ON
#define A_TRANSITION_BLEND_GLOW_OFF
#define A_SECONDARY_TEXTURES_ON

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

void aSurfaceShader(
    inout ASurface s)
{
    aDissolve(s);
    aMainTextures(s);
    aTransitionBlend(s);
    aSecondaryTextures(s);
}

#endif // ALLOY_MODS_SHADERS_DEFINITION_TRANSITION_LITE_CGINC
