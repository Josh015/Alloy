// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file DirectionalBlend.cginc
/// @brief Allows blending based how much a normal faces a given direction.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_DIRECTIONAL_BLEND_CGINC
#define ALLOY_SHADERS_FEATURE_DIRECTIONAL_BLEND_CGINC

#ifdef A_DIRECTIONAL_BLEND_ON
    #ifndef _DIRECTIONALBLENDMODE_WORLD
        #ifdef A_DIRECTIONAL_BLEND_MODE_OFF
            #define _DIRECTIONALBLENDMODE_WORLD
        #else
            #define A_WORLD_TO_OBJECT_ON
        #endif
    #endif

    #ifndef A_NORMAL_WORLD_ON
        #define A_NORMAL_WORLD_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_DIRECTIONAL_BLEND_ON
    /// Direction around which the blending occurs.
    /// Expects a normalized direction vector.
    half3 _DirectionalBlendDirection;
    
    /// Directional Blend weight.
    /// Expects values in the range [0,1].
    half _OrientedScale;
    
    /// Hemispherical cutoff where blend begins.
    /// Expects values in the range [0,1].
    half _OrientedCutoff;
    
    /// Offset from cutoff where smooth blending occurs.
    /// Expects values in the range [0.0001,1].
    half _OrientedBlend;

    /// Controls how much the vertex color alpha influences the cutoff.
    /// Expects values in the range [0,1].
    half _DirectionalBlendAlphaVertexTint;
#endif

void aDirectionalBlend(
    inout ASurface s)
{
#ifdef A_DIRECTIONAL_BLEND_ON    
    #ifdef _DIRECTIONALBLENDMODE_WORLD
        half3 normal = s.normalWorld;
    #else
        half3 normal = UnityWorldToObjectDir(s.normalWorld);
    #endif	

    // Convert [-1,1] -> [1,0] to flip direction for free.
    half mask = dot(normal, _DirectionalBlendDirection) * -0.5h + 0.5h;
    aBlendRangeMask(s, mask, _OrientedScale, _OrientedCutoff, _OrientedBlend, _DirectionalBlendAlphaVertexTint);
#endif
}

#endif // ALLOY_SHADERS_FEATURE_DIRECTIONAL_BLEND_CGINC
