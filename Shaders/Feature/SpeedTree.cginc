// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file SpeedTree.cginc
/// @brief SpeedTree standard material properties.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_SPEED_TREE_CGINC
#define ALLOY_SHADERS_FEATURE_SPEED_TREE_CGINC

#ifdef A_SPEED_TREE_ON
    // NOTE: AO on/off determined by matching SpeedTree(Billboard) Model.

    #if defined(GEOM_TYPE_FROND) || defined(GEOM_TYPE_LEAF) || defined(GEOM_TYPE_FACING_LEAF)
        #ifndef _ALPHATEST_ON
            #define _ALPHATEST_ON
        #endif

        #ifndef A_TWO_SIDED_SHADER
            #define A_TWO_SIDED_SHADER
        #endif

        #ifndef A_SUBSURFACE_ON
            #define A_SUBSURFACE_ON
        #endif
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_SPEED_TREE_ON
    #ifdef GEOM_TYPE_BRANCH_DETAIL
        sampler2D _DetailTex;

        sampler2D _DetailNormalMap;
    #endif

    #ifdef EFFECT_HUE_VARIATION
        half4 _HueVariation;
    #endif

    #ifdef A_SUBSURFACE_ON
        /// Transmission tint color.
        /// Expects a linear LDR color.
        half3 _TransColor;

        /// Transmission color * thickness texture.
        /// Expects an RGB map with sRGB sampling.
        sampler2D _TransTex;

        /// Weight of the transmission effect.
        /// Expects gamma-space values in the range [0,1].
        half _TransScale;
    #endif
#endif

void aSpeedTree(
    inout ASurface s) 
{
#ifdef A_SPEED_TREE_ON
    half4 base = aSampleBase(s);

    s.baseColor = base.rgb;
    s.opacity = _Color.a * base.a;
    aCutout(s);

    // AO content depends on matching Model header.
    s.ambientOcclusion = s.vertexColor.r;
    s.normalTangent = A_NT(s, aSampleBump(s));

    #ifdef A_SUBSURFACE_ON
        s.subsurface = A_SS(s, _TransScale * tex2D(_TransTex, s.baseUv).a);
        s.subsurfaceColor *= _TransColor;
    #endif

    #ifdef GEOM_TYPE_BRANCH_DETAIL
        half4 detailColor = tex2D(_DetailTex, s.uv01.zw);
        half weight = s.vertexColor.g < 2.0f ? saturate(s.vertexColor.g) : detailColor.a;
    
        s.baseColor = lerp(s.baseColor, detailColor.rgb, weight);
    
        half3 detailNormals = UnpackScaleNormal(tex2D(_DetailNormalMap, s.uv01.zw), weight);
        s.normalTangent = A_NT(s, BlendNormals(s.normalTangent, detailNormals));
    #endif

    #ifdef EFFECT_HUE_VARIATION
        half3 shiftedColor = lerp(s.baseColor, _HueVariation.rgb, s.vertexColor.b);
        half maxBase = max(s.baseColor.r, max(s.baseColor.g, s.baseColor.b));
        half newMaxBase = max(shiftedColor.r, max(shiftedColor.g, shiftedColor.b));

        maxBase /= newMaxBase;
        maxBase = maxBase * 0.5f + 0.5f;

        // preserve vibrance
        shiftedColor.rgb *= maxBase;
        s.baseColor = saturate(shiftedColor);
    #endif

    s.baseColor *= _Color.rgb;
#endif
} 

#endif // ALLOY_SHADERS_FEATURE_SPEED_TREE_CGINC
