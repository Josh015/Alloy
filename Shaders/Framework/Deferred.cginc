// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Deferred.cginc
/// @brief Deferred passes uber-header.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_DEFERRED_CGINC
#define ALLOY_SHADERS_FRAMEWORK_DEFERRED_CGINC

#define A_DEFERRED_PASS
#define A_TANGENT_TO_WORLD_ON
#define A_REFLECTION_PROBES_ON

// Headers both for this file, and for all Definition and Feature modules.
#include "Assets/Alloy/Shaders/Config.cginc"
#include "Assets/Alloy/Shaders/Framework/LightingImpl.cginc"

#include "UnityCG.cginc"
#include "UnityDeferredLibrary.cginc"
#include "UnityGlobalIllumination.cginc"
#include "UnityImageBasedLighting.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityStandardBRDF.cginc"
#include "UnityStandardUtils.cginc"

sampler2D _CameraGBufferTexture0;
sampler2D _CameraGBufferTexture1;
sampler2D _CameraGBufferTexture2;

/// Creates a surface description from a Unity G-Buffer.
/// @param[in,out] i    Unity deferred vertex format.
/// @return             Material surface data.
ASurface aDeferredSurface(
    inout unity_v2f_deferred i)
{
    ASurface s = aNewSurface();

    // Set vertex data.
    i.ray = i.ray * (_ProjectionParams.z / i.ray.z);
    s.screenPosition = i.uv;
    s.screenUv = s.screenPosition.xy / s.screenPosition.w;

    // Convert G-Buffer to surface.
    float depth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, s.screenUv));
    half4 gbuffer0 = tex2D(_CameraGBufferTexture0, s.screenUv);
    half4 gbuffer1 = tex2D(_CameraGBufferTexture1, s.screenUv);
    half4 gbuffer2 = tex2D(_CameraGBufferTexture2, s.screenUv);
    float4 vpos = float4(i.ray * depth, 1.0f);

    s.viewDepth = vpos.z;
    s.positionWorld = mul(unity_CameraToWorld, vpos).xyz;
    s.viewDirWorld = normalize(UnityWorldSpaceViewDir(s.positionWorld));

    s.albedo = gbuffer0.rgb;
    s.specularOcclusion = gbuffer0.a;
    s.f0 = gbuffer1.rgb;
    s.roughness = 1.0h - gbuffer1.a;
    s.beckmannRoughness = aLinearToBeckmannRoughness(s.roughness);
    s.normalWorld = A_NW(s, normalize(gbuffer2.xyz * 2.0h - 1.0h));
    s.materialType = gbuffer2.w;
    aPreLighting(s);
    return s;
}

#endif // ALLOY_SHADERS_FRAMEWORK_DEFERRED_CGINC
