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

#include "UnityShaderVariables.cginc"

#ifdef A_VOLUMETRIC_PASS
    #if defined(VAPOR_TRANSLUCENT_FOG_ON)
        #ifndef A_POSITION_WORLD_ON
            #define A_POSITION_WORLD_ON
        #endif
    #elif defined(VTRANSPARENCY_ON)
        #ifndef A_SCREEN_UV_ON
            #define A_SCREEN_UV_ON
        #endif
        
        #ifndef A_VIEW_DEPTH_ON
            #define A_VIEW_DEPTH_ON
        #endif
    #endif

    #if !defined(A_FOG_ON) && (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
        #define A_FOG_ON
    #endif
#endif

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

void aVolumetricBase(
    inout half4 color,
    ASurface s)
{
#ifdef A_VOLUMETRIC_PASS
    UNITY_APPLY_FOG_COLOR(s.fogCoord, color, unity_FogColor);

    #if defined(VAPOR_TRANSLUCENT_FOG_ON)
        color = VaporApplyFog(s.positionWorld, color);
    #elif defined(VTRANSPARENCY_ON)
        float4 data = s.screenPosition;

        data.z = s.viewDepth;
        color = VolumetricTransparencyBase(color, data);
    #endif
#endif
}

void aVolumetricAdd(
    inout half4 color,
    ASurface s)
{
#ifdef A_VOLUMETRIC_PASS
    UNITY_APPLY_FOG_COLOR(s.fogCoord, color, A_BLACK4);

    #if defined(VAPOR_TRANSLUCENT_FOG_ON)
        color = VaporApplyFogAdd(s.positionWorld, color);
    #elif defined(VTRANSPARENCY_ON)
        float4 data = s.screenPosition;

        data.z = s.viewDepth;
        color = VolumetricTransparencyAdd(color, data);
    #endif
#endif
}

void aVolumetricMultiply(
    inout half4 color,
    ASurface s)
{
#ifdef A_VOLUMETRIC_PASS
    UNITY_APPLY_FOG_COLOR(s.fogCoord, color, A_WHITE4);

    #if defined(VAPOR_TRANSLUCENT_FOG_ON)
        color = VaporApplyFogFade(s.positionWorld, color, A_WHITE);
    #elif defined(VTRANSPARENCY_ON)
//        float4 data = s.screenPosition;
//
//        data.z = s.viewDepth;
//        color = VolumetricTransparencyAdd(color, data);
    #endif
#endif
}

#endif // ALLOY_SHADERS_FRAMEWORK_TYPE_IMPL_CGINC
