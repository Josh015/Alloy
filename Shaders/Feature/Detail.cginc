// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Detail.cginc
/// @brief Surface detail materials and normals.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_DETAIL_CGINC
#define ALLOY_SHADERS_FEATURE_DETAIL_CGINC

#if !defined(A_DETAIL_ON) && defined(_DETAIL_MULX2)
    #define A_DETAIL_ON
#endif

#if !defined(A_DETAIL_MASK_VERTEX_COLOR_ALPHA_ON) && defined(_NORMALMAP)
    #define A_DETAIL_MASK_VERTEX_COLOR_ALPHA_ON
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_DETAIL_ON
    #ifndef A_DETAIL_MASK_OFF
        /// Mask that controls the detail influence on the base material.
        /// Expects an alpha data map.
        sampler2D _DetailMask;
    #endif
    
    /// Controls how much the vertex alpha masks the detail maps.
    /// Expects values in the range [0,1].
    half _DetailMaskStrength;

    #ifndef A_DETAIL_COLOR_MAP_OFF
        /// Detail base color blending mode.
        /// Expects either 0 or 1.
        float _DetailMode;

        /// Detail base color map.
        /// Expects an RGB map with sRGB sampling.
        A_SAMPLER_2D(_DetailAlbedoMap);
    #endif
        
    #ifndef A_DETAIL_NORMAL_MAP_OFF
        /// Detail normal map.
        /// Expects a compressed normal map.
        A_SAMPLER_2D(_DetailNormalMap);
    #endif

    /// Controls the detail influence on the base material.
    /// Expects values in the range [0,1].
    half _DetailWeight;

    #ifndef A_DETAIL_NORMAL_MAP_OFF
        /// Normal map XY scale.
        half _DetailNormalMapScale;
    #endif
#endif

void aDetail(
    inout ASurface s) 
{
#ifdef A_DETAIL_ON
    half mask = s.mask * _DetailWeight;
    
    #ifndef A_DETAIL_MASK_OFF
        #ifdef A_DETAIL_MASK_VERTEX_COLOR_ALPHA_ON
            half alpha = s.vertexColor.a;
        #else
            half alpha = tex2D(_DetailMask, s.baseUv).a;
        #endif

        mask *= aLerpOneTo(alpha, _DetailMaskStrength);
    #endif
    
    #ifndef A_DETAIL_COLOR_MAP_OFF
        float2 detailUv = A_TEX_TRANSFORM_UV_SCROLL(s, _DetailAlbedoMap);
    #else
        float2 detailUv = A_TEX_TRANSFORM_UV_SCROLL(s, _DetailNormalMap);
    #endif
    
    #ifndef A_DETAIL_COLOR_MAP_OFF
        half3 detailAlbedo = tex2D(_DetailAlbedoMap, detailUv).rgb;
        half3 colorScale = _DetailMode < 0.5f ? A_WHITE : unity_ColorSpaceDouble.rgb;
        
        s.baseColor *= aLerpWhiteTo(detailAlbedo * colorScale, mask);
    #endif

    #ifndef A_DETAIL_NORMAL_MAP_OFF
        half3 detailNormalTangent = UnpackScaleNormal(tex2D(_DetailNormalMap, detailUv), mask * _DetailNormalMapScale);
        s.normalTangent = A_NT(s, BlendNormals(s.normalTangent, detailNormalTangent));
    #endif
#endif
} 

#endif // ALLOY_SHADERS_FEATURE_DETAIL_CGINC
