// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file CarPaint.cginc
/// @brief View-dependent secondary color tint and metal flakes layers.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_CAR_PAINT_CGINC
#define ALLOY_SHADERS_FEATURE_CAR_PAINT_CGINC

#ifdef A_CAR_PAINT_ON
    #ifndef A_METALLIC_ON
        #define A_METALLIC_ON
    #endif

    #ifndef A_NORMAL_WORLD_ON
        #define A_NORMAL_WORLD_ON
    #endif

    #ifndef A_VIEW_DIR_WORLD_ON
        #define A_VIEW_DIR_WORLD_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_CAR_PAINT_ON
    /// The primary paint tint color.
    /// Expects a linear LDR color.
    half3 _CarPrimaryColor;
    
    /// The secondary paint tint color.
    /// Expects a linear LDR color.
    half3 _CarSecondaryColor;
    
    /// The secondary paint tint color weight.
    /// Expects values in the range [0,1].
    half _CarSecondaryColorWeight;
    
    /// Controls the width of the secondary paint tint color rim effect.
    /// Expects values in the range [0,1].
    half _CarSecondaryColorFalloff;

    /// The metallic flake tint color.
    /// Expects a linear LDR color.
    half4 _CarFlakeColor;
    
    /// Metal flake color in RGB, and weight in A.
    /// Expects an RGBA map with sRGB sampling.
    A_SAMPLER_2D(_CarFlakeMap);
    
    /// Gamma applied to the metal flake weight map.
    /// Expects values in the range [0.01,n].
    half _CarFlakeMapFalloff;
    
    /// The metal flake weight.
    /// Expects values in the range [0,1].
    half _CarFlakeWeight;
    
    /// Controls the view-dependent spread of the metal flakes over the surface.
    /// Expects values in the range [0,1].
    half _CarFlakeSpread;
    
    /// Controls the view-dependent spread of highlights over the metal flakes.
    /// Expects values in the range [0,1].
    half _CarFlakeHighlightSpread;
#endif

void aCarPaint(
    inout ASurface s) 
{
#ifdef A_CAR_PAINT_ON
    // Multi-layer car paint.
    // cf http://www.elliottpacel.co.uk/blog/pbr-practice
    // cf http://blenderartists.org/forum/showthread.php?250127-Car-Paint-Materials-Iridescent-Layers-Carbon-Fiber-Leather&p=2083499&viewfull=1#post2083499
    
    // Two-Tone Paint
    half secondaryColorFalloff = 1.0h - pow(s.NdotV, 0.1 + 9.9h * _CarSecondaryColorFalloff);
    half secondaryColorWeight = _CarSecondaryColorWeight * secondaryColorFalloff;
    half3 paintColor = lerp(_CarPrimaryColor, _CarSecondaryColor, secondaryColorWeight);

    s.baseColor *= aLerpWhiteTo(paintColor, s.mask);
    
    // Metal Flakes
    // NOTE: Metal brightness will overpower clearcoat, hiding roughness difference.
    float2 flakeUv = A_TEX_TRANSFORM_UV(s, _CarFlakeMap);
    half4 flakes = _CarFlakeColor * tex2D(_CarFlakeMap, flakeUv);
    half flakeMask = pow(flakes.a, _CarFlakeMapFalloff);
    half flakeSpread = pow(s.NdotV, _CarFlakeSpread * -9.9h + 10.0h); //[10,0]
    half flakeWeight = s.mask * flakeMask * flakeSpread * _CarFlakeWeight;
    
    s.baseColor = lerp(s.baseColor, flakes.rgb, flakeWeight);
    s.metallic = lerp(s.metallic, 1.0h, flakeWeight);
    s.roughness = lerp(s.roughness, 1.0h, flakeWeight * _CarFlakeHighlightSpread);
        
    // Clear Coat
    // NOTE: Only added to metallic parts, as dielectrics already have it.
    s.baseColor += aSpecularityToF0(s.mask * s.specularity * s.metallic);
#endif
} 

#endif // ALLOY_SHADERS_FEATURE_CAR_PAINT_CGINC
