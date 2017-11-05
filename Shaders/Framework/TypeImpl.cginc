// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Type.cginc
/// @brief Shader type method implementations to allow disabling of features.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_TYPE_IMPL_CGINC
#define ALLOY_SHADERS_FRAMEWORK_TYPE_IMPL_CGINC

#if !defined(A_VERTEX_COLOR_IS_DATA) && defined(A_USE_VERTEX_MOTION)
    #define A_VERTEX_COLOR_IS_DATA
#endif

#include "Assets/Alloy/Shaders/Config.cginc"
#include "Assets/Alloy/Shaders/Framework/LightingImpl.cginc"
#include "Assets/Alloy/Shaders/Framework/Type.cginc"
#include "Assets/Alloy/Shaders/Framework/Utility.cginc"
#include "Assets/Alloy/Shaders/Framework/VolumetricImpl.cginc"

AVertex aNewVertex() {
    AVertex v;

    UNITY_INITIALIZE_OUTPUT(AVertex, v);
    return v;
}

AGbuffer aNewGbuffer() {
    AGbuffer gb;

    UNITY_INITIALIZE_OUTPUT(AGbuffer, gb);

#ifdef A_SHADOW_MASKS_BUFFER_ON
    gb.shadowMasks = A_ZERO4;
#endif
    return gb;
}

void aStandardVertexShader(
    inout AVertex v)
{
#ifdef A_USE_VERTEX_MOTION
    v.positionObject = VertExmotion(v.positionObject, v.color);
#elif !defined(A_VERTEX_COLOR_IS_DATA)
    /// Convert in vertex shader to interpolate in linear space.
    v.color.rgb = aGammaToLinear(v.color.rgb);
#endif
}

void aStandardColorShader(
    inout half4 color,
    ASurface s)
{
#ifdef A_BASE_PASS
    aVolumetricBase(color, s);
#else
    aVolumetricAdd(color, s);
#endif
}

#endif // ALLOY_SHADERS_FRAMEWORK_TYPE_IMPL_CGINC
