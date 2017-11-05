// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Core.cginc
/// @brief Core & Glass surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_MODS_SHADERS_DEFINITION_CORE_CGINC
#define ALLOY_MODS_SHADERS_DEFINITION_CORE_CGINC

#define A_MAIN_TEXTURES_ON
#define A_DETAIL_MASK_OFF
#define A_EMISSION_MASK_MAP_OFF

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

sampler2D _MasksMap;
half4 _DetailMasks;
half4 _EmissionMasks;
half4 _RimMasks;

void aSurfaceShader(
    inout ASurface s)
{
    aParallax(s);
    aDissolve(s);
    aMainTextures(s);

#if defined(A_DETAIL_ON) || defined(A_EMISSION_ON) || defined(A_RIM_ON)
    half4 masks = tex2D(_MasksMap, s.baseUv);
#endif
#ifdef A_DETAIL_ON
    s.mask = aDotClamp(_DetailMasks, masks);
    aDetail(s);
    s.mask = 1.0h;
#endif

    aTeamColor(s);
    aAo2(s);
    aDecal(s);
    aWetness(s);

#ifdef A_EMISSION_ON
    s.mask = aGammaToLinear(aDotClamp(_EmissionMasks, masks));
    aEmission(s);
#endif
#ifdef A_RIM_ON
    s.mask = aGammaToLinear(aDotClamp(_RimMasks, masks));
    aRim(s);
#endif
}

#endif // ALLOY_MODS_SHADERS_DEFINITION_CORE_CGINC
