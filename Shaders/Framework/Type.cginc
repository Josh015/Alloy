// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Type.cginc
/// @brief Shader type uber-header.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_TYPE_CGINC
#define ALLOY_SHADERS_FRAMEWORK_TYPE_CGINC

#define A_VOLUMETRIC_DATA ASurface

// Headers both for this file, and for all Definition and Feature modules.
#include "Assets/Alloy/Shaders/Config.cginc"
#include "Assets/Alloy/Shaders/Framework/Feature.cginc"
#include "Assets/Alloy/Shaders/Framework/Lighting.cginc"
#include "Assets/Alloy/Shaders/Framework/Utility.cginc"
#include "Assets/Alloy/Shaders/Framework/Volumetric.cginc"

#include "UnityCG.cginc"
#include "UnityInstancing.cginc"

#if !defined(A_VERTEX_COLOR_IS_DATA) && defined(A_PROJECTIVE_DECAL_SHADER)
    #define A_VERTEX_COLOR_IS_DATA
#endif

#if !defined(A_SHADOW_MASKS_BUFFER_ON) && (defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4))
    #define A_SHADOW_MASKS_BUFFER_ON
#endif

#if !defined(A_ALPHA_BLENDING_ON) && (defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON))
    #define A_ALPHA_BLENDING_ON 
#endif

#if !defined(A_ROUGHNESS_SOURCE_BASE_COLOR_ALPHA) && defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
    #define A_ROUGHNESS_SOURCE_BASE_COLOR_ALPHA
#endif

#if !defined(A_NORMAL_MAPPING_ON) && (defined(EFFECT_BUMP) || defined(_TERRAIN_NORMAL_MAP))
    #define A_NORMAL_MAPPING_ON
#endif

// Features
#include "Assets/Alloy/Shaders/Feature/AO2.cginc"
#include "Assets/Alloy/Shaders/Feature/CarPaint.cginc"
#include "Assets/Alloy/Shaders/Feature/Decal.cginc"
#include "Assets/Alloy/Shaders/Feature/Detail.cginc"
#include "Assets/Alloy/Shaders/Feature/DirectionalBlend.cginc"
#include "Assets/Alloy/Shaders/Feature/Dissolve.cginc"
#include "Assets/Alloy/Shaders/Feature/Emission.cginc"
#include "Assets/Alloy/Shaders/Feature/Emission2.cginc"
#include "Assets/Alloy/Shaders/Feature/Eye.cginc"
#include "Assets/Alloy/Shaders/Feature/MainTextures.cginc"
#include "Assets/Alloy/Shaders/Feature/OrientedTextures.cginc"
#include "Assets/Alloy/Shaders/Feature/Parallax.cginc"
#include "Assets/Alloy/Shaders/Feature/Puddles.cginc"
#include "Assets/Alloy/Shaders/Feature/Rim.cginc"
#include "Assets/Alloy/Shaders/Feature/Rim2.cginc"
#include "Assets/Alloy/Shaders/Feature/SecondaryTextures.cginc"
#include "Assets/Alloy/Shaders/Feature/SkinTextures.cginc"
#include "Assets/Alloy/Shaders/Feature/SpeedTree.cginc"
#include "Assets/Alloy/Shaders/Feature/TeamColor.cginc"
#include "Assets/Alloy/Shaders/Feature/Terrain.cginc"
#include "Assets/Alloy/Shaders/Feature/TransitionBlend.cginc"
#include "Assets/Alloy/Shaders/Feature/Transmission.cginc"
#include "Assets/Alloy/Shaders/Feature/TriPlanar.cginc"
#include "Assets/Alloy/Shaders/Feature/VertexBlend.cginc"
#include "Assets/Alloy/Shaders/Feature/WeightedBlend.cginc"
#include "Assets/Alloy/Shaders/Feature/Wetness.cginc"

/// Vertex data to be modified for specific shader type.
struct AVertex {
    /// Vertex position in object space.
    float4 positionObject;

    /// Vertex normal in object space.
    /// Expects normalized vectors.
    half3 normalObject;

    /// Vertex tangent in object space and bitangent sign.
    /// XYZ: Normalized tangent, W: Bitangent sign.
    half4 tangentObject;

    /// UV0 texture coordinates.
    float4 uv0;

    /// UV1 texture coordinates.
    float4 uv1;

    /// UV2 texture coordinates.
    float4 uv2;

    /// UV3 texture coordinates.
    float4 uv3;

    /// Vertex color.
    /// Expects linear-space LDR color values.
    half4 color;
};

/// Deferred geometry buffer representation of surface data.
struct AGbuffer {
    /// RGB: Albedo, A: Specular occlusion.
    half4 diffuseOcclusion : SV_Target0;

    /// RGB: f0, A: 1-Roughness.
    half4 specularSmoothness : SV_Target1;

    /// RGB: Packed world-space normal, A: Material type.
    half4 normalType : SV_Target2;

    /// RGB: Emission, A: 1-Subsurface.
    half4 emissionSubsurface : SV_Target3;

#ifdef A_SHADOW_MASKS_BUFFER_ON
    /// RGBA: Shadow Masks.
    half4 shadowMasks : SV_Target4;
#endif
};

/// Abstract declaration for user-defined vertex shader.
void aVertexShader(inout AVertex v);

/// Abstract declaration for user-defined color shader.
void aColorShader(inout half4 color, ASurface s);

/// Abstract declaration for user-defined G-Buffer shader.
void aGbufferShader(inout AGbuffer gb, ASurface s);

/// Abstract declaration for user-defined surface shader.
void aSurfaceShader(inout ASurface s);

/// Vertex output data constructor.
AVertex aNewVertex();

/// Gbuffer output data constructor.
AGbuffer aNewGbuffer();

/// Applies standard vertex transformations.
void aStandardVertexShader(inout AVertex v);

/// Applies standard color transformations.
void aStandardColorShader(inout half4 color, ASurface s);

#endif // ALLOY_SHADERS_FRAMEWORK_TYPE_CGINC
