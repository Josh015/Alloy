// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Unity.cginc
/// @brief Code shared between Alloy shaders and Unity override headers.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_UNITY_CGINC
#define ALLOY_SHADERS_FRAMEWORK_UNITY_CGINC

// Headers both for this file, and for all Definition and Feature modules.
#include "Assets/Alloy/Shaders/Config.cginc"
#include "Assets/Alloy/Shaders/Framework/LightingImpl.cginc"
#include "Assets/Alloy/Shaders/Framework/Utility.cginc"

#include "AutoLight.cginc"
#include "UnityCG.cginc"
#include "UnityGlobalIllumination.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityShaderVariables.cginc"

/// Sets light range in light vector range ".w" component.
/// @param[in,out]  lightVectorRange    XYZ: Vector to light center, W: Light volume range.
/// @param[out]     lightCoord          Projection coordinates in light space.
void aLightRange(
    inout float4 lightVectorRange,
    unityShadowCoord4 lightCoord)
{
    // Light range = |light-space light vector| / |world-space light vector|
    // This works because the light vector's length is the same in both world
    // and light space, but it's scaled by the light range in light space.
    // cf http://forum.unity3d.com/threads/get-the-range-of-a-point-light-in-forward-add-mode.213430/#post-1433291
    lightVectorRange.w = length(lightVectorRange.xyz) * rsqrt(dot(lightCoord.xyz, lightCoord.xyz));
}

/// Calculates forward indirect illumination.
/// @param  gi      UnityGI populated with data.
/// @param  s       Material surface data.
/// @return         Indirect illumination.
half3 aUnityIndirectLighting(
    UnityGI gi,
    ASurface s)
{
    return aIndirectLighting(gi.indirect, s);
}

/// Calculates forward direct illumination.
/// @param  s                   Material surface data.
/// @param  shadow              Shadow attenuation.
/// @param  lightVectorRange    XYZ: Vector to light center, W: Light volume range.
/// @param  lightCoord          Light projection texture coordinates.
/// @return                     Direct illumination.
half3 aUnityDirectLighting(
    ASurface s,
    half shadow,
    float4 lightVectorRange,
    unityShadowCoord4 lightCoord)
{
    half3 lightAxis = A_ZERO;
    ADirect d = aNewDirect();

    d.color = _LightColor0.rgb;
    d.shadow = shadow;
        
#if !defined(ALLOY_SUPPORT_REDLIGHTS) && defined(DIRECTIONAL_COOKIE)
    aLightCookie(d, tex2D(_LightTexture0, lightCoord.xy));
#elif defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
    lightAxis = normalize(unity_WorldToLight[1].xyz);

    #if defined(POINT)
        A_UNITY_ATTENUATION(d, _LightTexture0, lightCoord.xyz, 1.0f)
    #elif defined(POINT_COOKIE)
        aLightCookie(d, texCUBE(_LightTexture0, lightCoord.xyz));
        A_UNITY_ATTENUATION(d, _LightTextureB0, lightCoord.xyz, 1.0f)
    #elif defined(SPOT)
        half4 cookie = tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5);
    
        cookie.a *= (lightCoord.z > 0);
        aLightCookie(d, cookie);
        A_UNITY_ATTENUATION(d, _LightTextureB0, lightCoord.xyz, 1.0f)
    #endif
#endif

#if !defined(ALLOY_SUPPORT_REDLIGHTS) || !defined(DIRECTIONAL_COOKIE)
    aAreaLight(d, s, _LightColor0, lightAxis, lightVectorRange.xyz, lightVectorRange.w);
#else
    d.direction = lightVectorRange.xyz;
    d.color *= redLightCalculateForward(_LightTexture0, s.positionWorld, s.normalWorld, s.viewDirWorld, d.direction);
    aDirectionalLight(d, s);
#endif

    return aDirectLighting(d, s);
}

/// Post-processing of Unity surface data into correct format.
/// @param[in,out] s Material surface data.
void aUnitySurface(
    inout ASurface s)
{
    s.beckmannRoughness = aLinearToBeckmannRoughness(s.roughness);
    s.specularOcclusion = aSpecularOcclusion(s.ambientOcclusion, s.NdotV);
}

/// Forward illumination with Unity inputs.
/// @param s        Material surface data.
/// @param gi       Unity GI descriptor.
/// @param shadow   Shadow for the given direct light.
/// @return         Combined lighting, emission, etc.
half4 aUnityLighting(
    ASurface s,
    UnityGI gi,
    half shadow)
{
    half4 c = 0.0h;
    unityShadowCoord4 lightCoord = 0.0f;
    float4 lightVectorRange = UnityWorldSpaceLightDir(s.positionWorld).xyzz;

#ifdef DIRECTIONAL
    lightCoord = 0.0h;
#else
    lightCoord = mul(unity_WorldToLight, unityShadowCoord4(s.positionWorld, 1.0f));

    #ifndef USING_DIRECTIONAL_LIGHT
        aLightRange(lightVectorRange, lightCoord);
    #endif
#endif

#ifdef UNITY_PASS_FORWARDBASE
    c.rgb = aUnityIndirectLighting(gi, s);

    // Extract shadow with combined baked occlusion.
    #ifdef HANDLE_SHADOWS_BLENDING_IN_GI
        shadow = gi.light.color.g;
    #endif
#endif

    c.rgb += aUnityDirectLighting(s, shadow, lightVectorRange, lightCoord);
    c.rgb = aHdrClamp(c.rgb);
    c.a = s.opacity;
    return c;
}

/// Fills the G-buffer with Unity-compatible material data.
/// @param[in]  s           Material surface data.
/// @param[in]  gi          Unity GI descriptor.
/// @param[out] outGBuffer0 RGB: albedo, A: specular occlusion.
/// @param[out] outGBuffer1 RGB: f0, A: 1-roughness.
/// @param[out] outGBuffer2 RGB: packed normal, A: 1-scattering mask.
/// @return                 RGB: emission, A: 1-transmission.
half4 aUnityLightingDeferred(
    ASurface s,
    UnityGI gi,
    out half4 outGBuffer0,
    out half4 outGBuffer1,
    out half4 outGBuffer2)
{
    half3 illum = aHdrClamp(s.emissiveColor + aUnityIndirectLighting(gi, s));
    outGBuffer0 = half4(s.albedo, s.specularOcclusion);
    outGBuffer1 = half4(s.f0, 1.0h - s.roughness);
    outGBuffer2 = half4(s.normalWorld * 0.5h + 0.5h, s.materialType);
    return half4(illum, s.subsurface);
}

/// Forward global illumination with Unity inputs.
/// @param[in,out]  gi          Unity GI descriptor.
/// @param[in]      data        GI input data.
/// @param[in]      normals     World-space normals.
/// @param[in]      smoothness  Surface smoothness.
/// @param[in]      specular    Surface f0.
void aUnityLightingGi(
    inout UnityGI gi,
    UnityGIInput data,
    half3 normals,
    half smoothness,
    half3 specular)
{
    // So we can extract shadow with baked occlusion.
#if defined(UNITY_PASS_FORWARDBASE) && defined(HANDLE_SHADOWS_BLENDING_IN_GI)
    data.light.color = A_WHITE;
#endif

    // Pass 1 for occlusion so we can manage that later.
#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    gi = UnityGlobalIllumination(data, 1.0h, normals);
#else
    Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(smoothness, data.worldViewDir, normals, specular);
    gi = UnityGlobalIllumination(data, 1.0h, normals, g);
#endif
}

#endif // ALLOY_SHADERS_FRAMEWORK_UNITY_CGINC
