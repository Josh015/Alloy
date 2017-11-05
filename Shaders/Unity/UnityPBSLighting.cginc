// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_PBS_LIGHTING_INCLUDED
#define UNITY_PBS_LIGHTING_INCLUDED

// Alloy.
#define A_TANGENT_TO_WORLD_ON

#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD) || defined(UNITY_PASS_DEFERRED)
    #define A_AMBIENT_OCCLUSION_ON
#endif

#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_DEFERRED) || defined(UNITY_PASS_META)
    #define A_EMISSIVE_COLOR_ON
#endif

#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD)
    #define A_DIRECT_LIGHTING_PASS
#endif

#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_DEFERRED)
    #define A_INDIRECT_LIGHTING_PASS
#endif

#if defined(UNITY_PASS_DEFERRED)
    #define A_GBUFFER_PASS
#endif

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Framework/Unity.cginc"

#include "UnityShaderVariables.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityGBuffer.cginc"
#include "UnityGlobalIllumination.cginc"

//-------------------------------------------------------------------------------------
// Default BRDF to use:
#if !defined (UNITY_BRDF_PBS) // allow to explicitly override BRDF in custom shader
    // still add safe net for low shader models, otherwise we might end up with shaders failing to compile
    #if SHADER_TARGET < 30
        #define UNITY_BRDF_PBS BRDF3_Unity_PBS
    #elif defined(UNITY_PBS_USE_BRDF3)
        #define UNITY_BRDF_PBS BRDF3_Unity_PBS
    #elif defined(UNITY_PBS_USE_BRDF2)
        #define UNITY_BRDF_PBS BRDF2_Unity_PBS
    #elif defined(UNITY_PBS_USE_BRDF1)
        #define UNITY_BRDF_PBS BRDF1_Unity_PBS
    #elif defined(SHADER_TARGET_SURFACE_ANALYSIS)
        // we do preprocess pass during shader analysis and we dont actually care about brdf as we need only inputs/outputs
        #define UNITY_BRDF_PBS BRDF1_Unity_PBS
    #else
        #error something broke in auto-choosing BRDF
    #endif
#endif

//-------------------------------------------------------------------------------------
// little helpers for GI calculation
// CAUTION: This is deprecated and not use in Untiy shader code, but some asset store plugin still use it, so let here for compatibility

#if !defined (UNITY_BRDF_GI)
    #define UNITY_BRDF_GI BRDF_Unity_Indirect
#endif

inline half3 BRDF_Unity_Indirect (half3 baseColor, half3 specColor, half oneMinusReflectivity, half smoothness, half3 normal, half3 viewDir, half occlusion, UnityGI gi)
{
    return half3(0,0,0);
}

#define UNITY_GLOSSY_ENV_FROM_SURFACE(x, s, data)               \
    Unity_GlossyEnvironmentData g;                              \
    g.roughness /* perceptualRoughness */   = SmoothnessToPerceptualRoughness(s.Smoothness); \
    g.reflUVW = reflect(-data.worldViewDir, s.Normal);  \


#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    #define UNITY_GI(x, s, data) x = UnityGlobalIllumination (data, s.Occlusion, s.Normal);
#else
    #define UNITY_GI(x, s, data)                                \
        UNITY_GLOSSY_ENV_FROM_SURFACE(g, s, data);              \
        x = UnityGlobalIllumination (data, s.Occlusion, s.Normal, g);
#endif

// Surface shader output structure to be used with physically
// based shading model.

//-------------------------------------------------------------------------------------
// Metallic workflow

struct SurfaceOutputStandard
{
	fixed3 Albedo;		// base (diffuse or specular) color
	fixed3 Normal;		// tangent space normal, if written
	half3 Emission;
	half Metallic;		// 0=non-metal, 1=metal
	// Smoothness is the user facing name, it should be perceptual smoothness but user should not have to deal with it.
	// Everywhere in the code you meet smoothness it is perceptual smoothness
	half Smoothness;	// 0=rough, 1=smooth
	half Occlusion;		// occlusion (default 1)
	fixed Alpha;		// alpha for transparencies
    float3 PositionWorld; // Alloy
    half Shadow; // Alloy
};

ASurface aStandardSurface(
    SurfaceOutputStandard si,
    half3 viewDir)
{
    half oneMinusReflectivity;
    ASurface s = aNewSurface();

    s.albedo = DiffuseAndSpecularFromMetallic(si.Albedo, si.Metallic, /*out*/ s.f0, /*out*/ oneMinusReflectivity);

#ifndef UNITY_PASS_DEFERRED
    s.albedo = PreMultiplyAlpha(s.albedo, si.Alpha, oneMinusReflectivity, /*out*/ s.opacity);
#endif

    s.viewDirWorld = viewDir;
    s.positionWorld = si.PositionWorld;
    s.normalWorld = A_NW(s, normalize(si.Normal));
    s.roughness = 1.0h - si.Smoothness;
    s.ambientOcclusion = si.Occlusion;
    s.emissiveColor = si.Emission;
    aUnitySurface(s);
    return s;
}

inline half4 LightingStandard (SurfaceOutputStandard si, half3 viewDir, UnityGI gi)
{
    ASurface s = aStandardSurface(si, viewDir);
    return aUnityLighting(s, gi, si.Shadow);
}

inline half4 LightingStandard_Deferred (SurfaceOutputStandard si, half3 viewDir, UnityGI gi, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
{
    ASurface s = aStandardSurface(si, viewDir);
    return aUnityLightingDeferred(s, gi, outGBuffer0, outGBuffer1, outGBuffer2);
}

inline void LightingStandard_GI (
	SurfaceOutputStandard s,
	UnityGIInput data,
	inout UnityGI gi)
{
    aUnityLightingGi(gi, data, s.Normal, s.Smoothness, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
}

//-------------------------------------------------------------------------------------
// Specular workflow

struct SurfaceOutputStandardSpecular
{
	fixed3 Albedo;		// diffuse color
	fixed3 Specular;	// specular color
	fixed3 Normal;		// tangent space normal, if written
	half3 Emission;
	half Smoothness;	// 0=rough, 1=smooth
	half Occlusion;		// occlusion (default 1)
	fixed Alpha;		// alpha for transparencies
    float3 PositionWorld; // Alloy
    half Shadow; // Alloy
};

ASurface aStandardSpecularSurface(
    SurfaceOutputStandardSpecular si,
    half3 viewDir)
{
    half oneMinusReflectivity;
    ASurface s = aNewSurface();

    s.albedo = EnergyConservationBetweenDiffuseAndSpecular(si.Albedo, si.Specular, /*out*/ oneMinusReflectivity);
    s.f0 = si.Specular;

#ifndef UNITY_PASS_DEFERRED
    s.albedo = PreMultiplyAlpha(s.albedo, si.Alpha, oneMinusReflectivity, /*out*/ s.opacity);
#endif

    s.viewDirWorld = viewDir;
    s.positionWorld = si.PositionWorld;
    s.normalWorld = A_NW(s, normalize(si.Normal));
    s.roughness = 1.0h - si.Smoothness;
    s.ambientOcclusion = si.Occlusion;
    s.emissiveColor = si.Emission;
    aUnitySurface(s);
    return s;
}

inline half4 LightingStandardSpecular (SurfaceOutputStandardSpecular si, half3 viewDir, UnityGI gi)
{
    ASurface s = aStandardSpecularSurface(si, viewDir);
    return aUnityLighting(s, gi, si.Shadow);
}

inline half4 LightingStandardSpecular_Deferred (SurfaceOutputStandardSpecular si, half3 viewDir, UnityGI gi, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
{
    ASurface s = aStandardSpecularSurface(si, viewDir);
    return aUnityLightingDeferred(s, gi, outGBuffer0, outGBuffer1, outGBuffer2);
}

inline void LightingStandardSpecular_GI (
	SurfaceOutputStandardSpecular s,
	UnityGIInput data,
	inout UnityGI gi)
{
    aUnityLightingGi(gi, data, s.Normal, s.Smoothness, s.Specular);
}

#endif // UNITY_PBS_LIGHTING_INCLUDED
