// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file DecalAlpha.cginc
/// @brief Alpha decal shader type callbacks.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_TYPE_DECAL_ALPHA_CGINC
#define ALLOY_SHADERS_TYPE_DECAL_ALPHA_CGINC

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
    aStandardColorShader(color, s);
}

void aGbufferShader(
    inout AGbuffer gb,
    ASurface s)
{
    // Deferred alpha decal two-pass solution.
    // cf http://forum.unity3d.com/threads/how-do-i-write-a-normal-decal-shader-using-a-newly-added-unity-5-2-finalgbuffer-modifier.356644/page-2
#ifdef A_DECAL_ALPHA_FIRSTPASS_SHADER
    gb.diffuseOcclusion.a = s.opacity;
    gb.specularSmoothness.a = s.opacity;
    gb.normalType.a = s.opacity;
    gb.emissionSubsurface.a = s.opacity;

    #ifdef A_SHADOW_MASKS_BUFFER_ON
        gb.shadowMasks.a = s.opacity;
    #endif
#else
    gb.diffuseOcclusion.a *= s.opacity;
    gb.specularSmoothness.a *= s.opacity;
    gb.normalType.a *= s.opacity;
    gb.emissionSubsurface.a *= s.opacity;

    #ifdef A_SHADOW_MASKS_BUFFER_ON
        gb.shadowMasks.a *= s.opacity;
    #endif
#endif
}

#endif // ALLOY_SHADERS_TYPE_DECAL_ALPHA_CGINC
