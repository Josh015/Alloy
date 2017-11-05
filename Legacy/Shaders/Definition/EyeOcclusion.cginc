// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file EyeOcclusion.cginc
/// @brief Eye Occlusion surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_LEGACY_SHADERS_DEFINITION_EYE_OCCLUSION_CGINC
#define ALLOY_LEGACY_SHADERS_DEFINITION_EYE_OCCLUSION_CGINC

#define A_AMBIENT_OCCLUSION_ON
#define A_EXPANDED_MATERIAL_MAPS

#include "Assets/Alloy/Shaders/Framework/Lighting.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

void aPreLighting(
    inout ASurface s)
{
    aStandardPreLighting(s);
    s.opacity *= 1.0h - s.specularOcclusion;
}

half3 aDirectLighting(
    ADirect d,
    ASurface s)
{
    return d.color * (d.shadow * d.NdotL * s.ambientOcclusion) * s.albedo;
}

half3 aIndirectLighting(
    AIndirect i,
    ASurface s)
{
    return i.diffuse * s.ambientOcclusion * s.albedo;
}

void aSurfaceShader(
    inout ASurface s)
{
    aDissolve(s);

    half4 base = aBase(s);

    s.baseColor = base.rgb;
    s.opacity = base.a;

    s.ambientOcclusion = aLerpOneTo(tex2D(_AoMap, s.baseUv).g, _Occlusion);
}

#endif // ALLOY_LEGACY_SHADERS_DEFINITION_EYE_OCCLUSION_CGINC
