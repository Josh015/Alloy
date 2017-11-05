// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file DecalMultiplicative.cginc
/// @brief Multiplicative decal shader type callbacks.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_TYPE_DECAL_MULTIPLICATIVE_CGINC
#define ALLOY_SHADERS_TYPE_DECAL_MULTIPLICATIVE_CGINC

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
    gb.diffuseOcclusion.rgb = s.baseColor;
    gb.diffuseOcclusion.a = 1.0h;
    gb.specularSmoothness = gb.diffuseOcclusion;
    gb.normalType = A_ONE4;
    gb.emissionSubsurface = gb.diffuseOcclusion;

#ifdef A_SHADOW_MASKS_BUFFER_ON
    gb.shadowMasks = A_ONE4;
#endif
}

#endif // ALLOY_SHADERS_TYPE_DECAL_MULTIPLICATIVE_CGINC
