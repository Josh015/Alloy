// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file MeshParticleCore.cginc
/// @brief Shader designed for emissive mesh particles.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_MODS_SHADERS_DEFINITION_MESHPARTICLECORE_CGINC
#define ALLOY_MODS_SHADERS_DEFINITION_MESHPARTICLECORE_CGINC

#ifndef A_VERTEX_COLOR_IS_DATA
    #define A_VERTEX_COLOR_IS_DATA
#endif

#define A_METALLIC_ON
#define A_EMISSIVE_COLOR_ON

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

sampler2D _BaseColorRamp;
sampler2D _EmissionColorRamp;

// Assumes these are in linear space.
half _EmissionMin;
half _EmissionMax;

void aSurfaceShader(
    inout ASurface s)
{
    aDissolve(s);
    
    half4 base = _Color;
    s.baseColor = base.rgb * tex2D(_BaseColorRamp, float2(s.vertexColor.r, 0.0f)).rgb;
    s.opacity = base.a;
    
    aCutout(s);
          
    s.metallic = _Metal;
    s.specularity = _Specularity;
    s.roughness = _Roughness;
    
    half3 emissionColor = tex2D(_EmissionColorRamp, float2(s.vertexColor.g, 0.0f)).rgb;
    s.emissiveColor += emissionColor * lerp(_EmissionMin, _EmissionMax, s.vertexColor.a);

    aRim(s);
}

#endif // ALLOY_MODS_SHADERS_DEFINITION_MESHPARTICLECORE_CGINC
