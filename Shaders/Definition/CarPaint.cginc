// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file CarPaint.cginc
/// @brief Car Paint surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFINITION_CAR_PAINT_CGINC
#define ALLOY_SHADERS_DEFINITION_CAR_PAINT_CGINC

#define A_MAIN_TEXTURES_ON
#define A_CAR_PAINT_ON

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
    
    s.mask = s.opacity;
    aCarPaint(s);

    s.mask = 1.0h;
    aAo2(s);
    aDecal(s);
    aWetness(s);
    aEmission(s);
    aRim(s);
}

#endif // ALLOY_SHADERS_DEFINITION_CAR_PAINT_CGINC
