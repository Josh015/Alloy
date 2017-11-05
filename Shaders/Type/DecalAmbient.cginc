// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file DecalAmbient.cginc
/// @brief Ambient-only decal shader type callbacks.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_TYPE_DECAL_AMBIENT_CGINC
#define ALLOY_SHADERS_TYPE_DECAL_AMBIENT_CGINC

#include "Assets/Alloy/Shaders/Framework/Type.cginc"

void aVertexShader(
    inout AVertex v)
{
    aStandardVertexShader(v);
}

void aColorShader(
    inout half4 color,
    ASurface s)
{
    color.rgb = s.baseColor.rgb;
    color.a = 1.0h;
    aVolumetricMultiply(color, s);
}

void aGbufferShader(
    inout AGbuffer gb,
    ASurface s)
{
    gb.diffuseOcclusion.rgb = A_WHITE;
    gb.diffuseOcclusion.a = aLuminance(s.baseColor); // Deferred reflections.
    gb.specularSmoothness = A_WHITE4;
    gb.normalType = A_ONE4;
    gb.emissionSubsurface.rgb = s.baseColor;
    gb.emissionSubsurface.a = 1.0h;

#ifdef A_SHADOW_MASKS_BUFFER_ON
    gb.shadowMasks = A_ONE4;
#endif
}

#endif // ALLOY_SHADERS_TYPE_DECAL_AMBIENT_CGINC
