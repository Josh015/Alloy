// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file DecalAdditive.cginc
/// @brief Additive deferred decal surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFINITION_DECAL_ADDITIVE_CGINC
#define ALLOY_SHADERS_DEFINITION_DECAL_ADDITIVE_CGINC

#define A_EMISSIVE_COLOR_ON
#define A_MAIN_TEXTURES_ON
#define A_MAIN_TEXTURES_MATERIAL_MAP_OFF

#include "Assets/Alloy/Shaders/Lighting/Unlit.cginc"
#include "Assets/Alloy/Shaders/Type/DecalAdditive.cginc"

void aSurfaceShader(
    inout ASurface s)
{
    aParallax(s);
    aDissolve(s);
    aMainTextures(s);
    aDetail(s);
    aTeamColor(s);
    aDecal(s);
    aRim(s);
    aEmission(s);

    s.emissiveColor += s.baseColor;
}

#endif // ALLOY_SHADERS_DEFINITION_DECAL_ADDITIVE_CGINC
