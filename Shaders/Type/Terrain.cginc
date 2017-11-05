// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Terrain.cginc
/// @brief Terrain shader type callbacks.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_TYPE_TERRAIN_CGINC
#define ALLOY_SHADERS_TYPE_TERRAIN_CGINC

#ifndef A_TEX_UV_OFF
    #define A_TEX_UV_OFF
#endif

#ifndef A_TEX_SCROLL_OFF
    #define A_TEX_SCROLL_OFF
#endif

#ifndef A_VERTEX_COLOR_IS_DATA
    #define A_VERTEX_COLOR_IS_DATA
#endif

#include "Assets/Alloy/Shaders/Framework/Type.cginc"

void aVertexShader(
    inout AVertex v)
{
    v.tangentObject.xyz = cross(v.normalObject, A_AXIS_Z);
    v.tangentObject.w = -1.0f;
}

void aColorShader(
    inout half4 color,
    ASurface s)
{
#ifndef A_TERRAIN_NSPLAT_SHADER
    aStandardColorShader(color, s);
#else
    color *= s.opacity;

    #ifndef A_TERRAIN_NSPLAT_ADDPASS_SHADER
        aStandardColorShader(color, s);
    #else
        aVolumetricAdd(color, s);
    #endif
#endif
}

void aGbufferShader(
    inout AGbuffer gb,
    ASurface s)
{
#ifdef A_TERRAIN_NSPLAT_SHADER
    gb.diffuseOcclusion *= s.opacity;
    gb.specularSmoothness *= s.opacity;
    gb.normalType *= s.opacity;
    gb.emissionSubsurface *= s.opacity;

    #ifdef A_SHADOW_MASKS_BUFFER_ON
        gb.shadowMasks *= s.opacity;
    #endif
#endif
}

#endif // ALLOY_SHADERS_TYPE_TERRAIN_CGINC
