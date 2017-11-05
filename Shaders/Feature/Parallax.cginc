// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Parallax.cginc
/// @brief Surface heightmap-based texcoord modification.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_PARALLAX_CGINC
#define ALLOY_SHADERS_FEATURE_PARALLAX_CGINC

#if !defined(A_PARALLAX_ON) && defined(_PARALLAXMAP)
    #define A_PARALLAX_ON
#endif

#ifdef A_PARALLAX_ON
    #ifndef A_VIEW_DIR_TANGENT_ON
        #define A_VIEW_DIR_TANGENT_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"
    
#ifdef A_PARALLAX_ON    
    /// Number of samples used for direct view of POM effect.
    /// Expects values in the range [1,n].
    float _MinSamples;
    
    /// Number of samples used for grazing view of POM effect.
    /// Expects values in the range [1,n].
    float _MaxSamples;
#endif

void aParallax(
    inout ASurface s) 
{
#ifdef A_PARALLAX_ON
    #ifndef _BUMPMODE_POM
        aOffsetBumpMapping(s);
    #else
        aParallaxOcclusionMapping(s, _MinSamples, _MaxSamples);
    #endif 
#endif 
}

#endif // ALLOY_SHADERS_FEATURE_PARALLAX_CGINC
