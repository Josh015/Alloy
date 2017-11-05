// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file SpeedTree.cginc
/// @brief SpeedTree surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFINITION_SPEED_TREE_CGINC
#define ALLOY_SHADERS_DEFINITION_SPEED_TREE_CGINC

#define A_SPEED_TREE_ON
#define A_SPECULAR_TINT_ON

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/SpeedTree.cginc"

void aSurfaceShader(
    inout ASurface s)
{
    aParallax(s);
    aDissolve(s);
    aSpeedTree(s);
    s.specularity = _Specularity;
    s.specularTint = _SpecularTint;
    s.roughness = _Roughness;
    aTeamColor(s);
    aDecal(s);
    aWetness(s);
    aTwoSided(s);
    aRim(s);
    aEmission(s);
}

#endif // ALLOY_SHADERS_DEFINITION_SPEED_TREE_CGINC
