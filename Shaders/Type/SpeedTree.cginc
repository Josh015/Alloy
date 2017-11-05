// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file SpeedTree.cginc
/// @brief SpeedTree shader type callbacks.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_TYPE_SPEED_TREE_CGINC
#define ALLOY_SHADERS_TYPE_SPEED_TREE_CGINC

#ifndef A_TEX_UV_OFF
    #define A_TEX_UV_OFF
#endif

#ifndef A_UV2_ON
    #define A_UV2_ON
#endif

#ifndef A_UV3_ON
    #define A_UV3_ON
#endif
    
#ifndef A_VERTEX_COLOR_IS_DATA
    #define A_VERTEX_COLOR_IS_DATA
#endif

#ifndef A_AMBIENT_OCCLUSION_ON
    #define A_AMBIENT_OCCLUSION_ON
#endif

#ifndef A_OPACITY_MASK_ON
    #define A_OPACITY_MASK_ON
#endif

#define ENABLE_WIND
#define SPEEDTREE_Y_UP

#ifdef GEOM_TYPE_BRANCH_DETAIL
    #define GEOM_TYPE_BRANCH
#endif

#include "Assets/Alloy/Shaders/Framework/Type.cginc"

#include "SpeedTreeVertex.cginc"

void aVertexShader(
    inout AVertex v)
{
    v.color.r = aOcclusionStrength(v.color.r, _Occlusion);

#ifdef EFFECT_HUE_VARIATION
    float hueVariationAmount = frac(unity_ObjectToWorld[0].w + unity_ObjectToWorld[1].w + unity_ObjectToWorld[2].w);
    hueVariationAmount += frac(v.positionObject.x + v.normalObject.y + v.normalObject.x) * 0.5f - 0.3f;
    v.color.b = saturate(hueVariationAmount * _HueVariation.a);
#endif

    // Adapt vertex data so we can reuse wind code.
    SpeedTreeVB IN;

    UNITY_INITIALIZE_OUTPUT(SpeedTreeVB, IN);
    IN.vertex = v.positionObject;
    IN.normal = v.normalObject;
    IN.texcoord = v.uv0;
    IN.texcoord1 = v.uv1;
    IN.texcoord2 = v.uv2;
    IN.texcoord3 = v.uv3;
    IN.color = v.color;
    
    OffsetSpeedTreeVertex(IN, unity_LODFade.x);
    v.positionObject = IN.vertex;

    // NOTE: Down here since it hijacks uv1 to pass uv2.
#ifdef GEOM_TYPE_BRANCH_DETAIL
    v.uv1.xy = v.uv2.xy;
    v.color.g = v.color.a == 0 ? v.uv2.z : 2.5f;
#endif
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

}

#endif // ALLOY_SHADERS_TYPE_SPEED_TREE_CGINC
