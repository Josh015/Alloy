// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Hair.cginc
/// @brief Hair surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFINITION_HAIR_CGINC
#define ALLOY_SHADERS_DEFINITION_HAIR_CGINC

#define A_NORMAL_MAPPING_ON
#define A_AMBIENT_OCCLUSION_ON
#define A_WETNESS_POROSITY_OFF
#define A_WETNESS_NORMAL_MAP_OFF

#include "Assets/Alloy/Shaders/Lighting/Hair.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

void aSurfaceShader(
    inout ASurface s)
{

    aDissolve(s);

    half4 base = aBase(s);

    s.baseColor = base.rgb;
    s.opacity = base.a;
    aCutout(s);

    half4 material = aSampleMaterial(s);
    
    // Preshift down so a middle-gray texture can push the highlight up or down!
    half shift = material.A_METALLIC_CHANNEL - 0.5h;
    s.highlightTint0 = _HighlightTint0 * material.A_SPECULARITY_CHANNEL; // Noise
    s.highlightShift0 = _HighlightShift0 + shift;
    s.highlightShift1 = _HighlightShift1 + shift;
    
    s.metallic = 0.0h;
    s.ambientOcclusion = aLerpOneTo(material.A_AO_CHANNEL, _Occlusion);
    s.specularity = _HairSpecularity;
    s.roughness = material.A_ROUGHNESS_CHANNEL;
    
    half theta = radians(_AnisoAngle);
    s.highlightTangent = half3(cos(theta), sin(theta), 0.0h);
    s.normalTangent = A_NT(s, aSampleBump(s));
     
    aDecal(s);
    aWetness(s);
    aRim(s);
    aEmission(s);
}

#endif // ALLOY_SHADERS_DEFINITION_HAIR_CGINC
