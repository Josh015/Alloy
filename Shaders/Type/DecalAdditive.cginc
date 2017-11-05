// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file DecalAdditive.cginc
/// @brief Additive decal shader type callbacks.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_TYPE_DECAL_ADDITIVE_CGINC
#define ALLOY_SHADERS_TYPE_DECAL_ADDITIVE_CGINC

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
    aVolumetricAdd(color, s);
}

void aGbufferShader(
    inout AGbuffer gb,
    ASurface s)
{
    gb.diffuseOcclusion = A_BLACK4;
    gb.specularSmoothness = A_BLACK4;
    gb.normalType = A_ZERO4;
    gb.emissionSubsurface.w = 0.0h;

#ifdef A_SHADOW_MASKS_BUFFER_ON
    gb.shadowMasks = A_ZERO4;
#endif
}

#endif // ALLOY_SHADERS_TYPE_DECAL_ADDITIVE_CGINC
