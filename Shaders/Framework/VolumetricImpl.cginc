// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Volumetric.cginc
/// @brief Volumetric fog, light shafts, etc implementations.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_VOLUMETRIC_IMPL_CGINC
#define ALLOY_SHADERS_FRAMEWORK_VOLUMETRIC_IMPL_CGINC

#include "Assets/Alloy/Shaders/Config.cginc"
#include "Assets/Alloy/Shaders/Framework/Volumetric.cginc"

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

#endif // ALLOY_SHADERS_FRAMEWORK_VOLUMETRIC_IMPL_CGINC
