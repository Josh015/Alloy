// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Eyeball.cginc
/// @brief Eyeball surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_LEGACY_SHADERS_DEFINITION_EYEBALL_CGINC
#define ALLOY_LEGACY_SHADERS_DEFINITION_EYEBALL_CGINC

#define A_NORMAL_MAPPING_ON
#define A_VIEW_DIR_TANGENT_ON
#define A_AMBIENT_OCCLUSION_ON
#define A_SPECULAR_TINT_ON
#define A_EYE_PARALLAX_REFRACTION
#define A_DETAIL_MASK_OFF

#define A_SURFACE_CUSTOM_FIELDS \
    half3 corneaNormalWorld; \
    half3 irisF0; \
    half scattering; \
    half irisMask; \
    half corneaSpecularity; \
    half corneaRoughness; \
    half irisSpecularOcclusion; \
    half irisRoughness; \
    half irisBeckmannRoughness; \
    half irisNdotV;

#include "Assets/Alloy/Shaders/Framework/Lighting.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"
#include "Assets/Alloy/Legacy/Shaders/Feature/EyeParallax.cginc"

/// Implements a scattering diffuse BRDF affected by roughness.
/// @param  albedo      Diffuse albedo LDR color.
/// @param  subsurface  Blend value between diffuse and scattering [0,1].
/// @param  roughness   Linear roughness [0,1].
/// @param  LdotH       Light and half-angle clamped dot product [0,1].
/// @param  NdotL       Normal and light clamped dot product [0,1].
/// @param  NdotV       Normal and view clamped dot product [0,1].
/// @return             Direct diffuse BRDF.
half3 aDiffuseBssrdf(
    half3 albedo,
    half subsurface,
    half roughness,
    half LdotH,
    half NdotL,
    half NdotV)
{
    // Impelementation of Brent Burley's diffuse scattering BRDF.
    // Subject to Apache License, version 2.0
    // cf https://github.com/wdas/brdf/blob/master/src/brdfs/disney.brdf
    half FL = aFresnel(NdotL);
    half FV = aFresnel(NdotV);
    half Fss90 = LdotH * LdotH * roughness;
    half Fd90 = 0.5h + (2.0h * Fss90);
    half Fd = aLerpOneTo(Fd90, FL) * aLerpOneTo(Fd90, FV);
    half Fss = aLerpOneTo(Fss90, FL) * aLerpOneTo(Fss90, FV);
    half ss = 1.25h * (Fss * (1.0h / max(NdotL + NdotV, A_EPSILON) - 0.5h) + 0.5h);

    // Pi is cancelled by implicit punctual lighting equation.
    // cf http://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/
    return albedo * lerp(Fd, ss, subsurface);
}

/// A specular BRDF.
/// @param  d   Direct lighting data.
/// @param  s   Material surface data.
/// @return     Direct specular BRDF.
half3 aLegacySpecularBrdf(
    ADirect d,
    ASurface s)
{
    // Schlick's Fresnel approximation.
    half3 F = lerp(s.f0, A_WHITE, aFresnel(d.LdotH));

    // GGX (Trowbridge-Reitz) NDF
    // cf http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
    half a2 = s.beckmannRoughness * s.beckmannRoughness;
    half denom = aLerpOneTo(a2, d.NdotH * d.NdotH);

    // John Hable's visibility function.
    // cf http://www.filmicworlds.com/2014/04/21/optimizing-ggx-shaders-with-dotlh/
    half V = lerp(a2 * 0.25h, 1.0h, d.LdotH * d.LdotH);

    // Pi is cancelled by implicit punctual lighting equation.
    // cf http://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/
    half DV = a2 / (4.0h * V * denom * denom);

    // Cook-Torrance microfacet model.
    // cf http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
    return F * (DV * s.specularOcclusion * d.specularIntensity);
}

/// Indirect specular BRDF.
/// @param  s   Material surface data.
/// @return     Environment BRDF.
half3 aLegacyEnvironmentBrdf(
    ASurface s)
{
    // Brian Karis' modification of Dimitar Lazarov's Environment BRDF.
    // cf https://www.unrealengine.com/blog/physically-based-shading-on-mobile
    const half4 c0 = half4(-1.0h, -0.0275h, -0.572h, 0.022h);
    const half4 c1 = half4(1.0h, 0.0425h, 1.04h, -0.04h);
    half4 r = s.roughness * c0 + c1;
    half a004 = min(r.x * r.x, exp2(-9.28h * s.NdotV)) * r.x + r.y;
    half2 AB = half2(-1.04h, 1.04h) * a004 + r.zw;
    return s.f0 * AB.x + AB.yyy;
}

/// Calculates standard indirect diffuse plus specular illumination.
/// @param d    Indirect light description.
/// @param s    Material surface data.
/// @return     Indirect illumination.
half3 aLegacyStandardIndirect(
    AIndirect i,
    ASurface s)
{
#ifdef A_REFLECTION_PROBES_ON
    half3 specular = i.specular * aLegacyEnvironmentBrdf(s);
#endif

#ifndef A_AMBIENT_OCCLUSION_ON
    half3 diffuse = s.albedo * i.diffuse;

    #ifndef A_REFLECTION_PROBES_ON
        return diffuse;
    #else
        return diffuse + specular;
    #endif
#else
    // Yoshiharu Gotanda's fake interreflection for specular occlusion.
    // Modified to better account for surface f0.
    // cf http://research.tri-ace.com/Data/cedec2011_RealtimePBR_Implementation_e.pptx pg65
    half3 ambient = i.diffuse * s.ambientOcclusion;

    #ifndef A_REFLECTION_PROBES_ON
        // Diffuse and fake interreflection only.
        return ambient * (s.albedo + s.f0 * (1.0h - s.specularOcclusion));
    #else
        // Full equation.
        return ambient * s.albedo
            + lerp(ambient * s.f0, specular, s.specularOcclusion);
    #endif
#endif
}

void aPreLighting(
    inout ASurface s)
{
    aStandardPreLighting(s);

    // Tint the iris specular to fake caustics.
    // cf http://game.watch.impress.co.jp/docs/news/20121129_575412.html

    // Iris & Sclera
    s.irisNdotV = s.NdotV;
    s.irisSpecularOcclusion = s.specularOcclusion;
    s.irisF0 = s.f0;
    s.irisRoughness = s.roughness;
    s.irisBeckmannRoughness = s.beckmannRoughness;

    // Cornea
    s.roughness = lerp(s.roughness, s.corneaRoughness, s.irisMask);
    s.corneaNormalWorld = normalize(lerp(s.normalWorld, s.vertexNormalWorld, s.irisMask));
    s.reflectionVectorWorld = reflect(-s.viewDirWorld, s.corneaNormalWorld);
    s.NdotV = aDotClamp(s.corneaNormalWorld, s.viewDirWorld);
    s.FV = aFresnel(s.NdotV);

    s.specularOcclusion = lerp(s.irisSpecularOcclusion, 1.0h, s.irisMask);
    s.f0 = lerp(s.irisF0, aSpecularityToF0(s.corneaSpecularity), s.irisMask);
}

half3 aDirectLighting(
    ADirect d,
    ASurface s)
{
    half3 illum = 0.0h;

    // Iris & Sclera		
    illum = d.NdotL * (
        aDiffuseBssrdf(s.albedo, s.scattering, s.irisRoughness, d.LdotH, d.NdotL, s.irisNdotV));
    //+ (s.irisSpecularOcclusion * AlloyAreaLightNormalization(s.irisBeckmannRoughness, d.solidAngle)
    //	* aLegacySpecularBrdf(s.irisF0, s.irisBeckmannRoughness, d.LdotH, d.NdotH, d.NdotL, s.irisNdotV)));

    // Cornea
    d.NdotH = aDotClamp(s.corneaNormalWorld, d.halfAngleWorld);
    d.NdotL = aDotClamp(s.corneaNormalWorld, d.direction);
    d.specularIntensity *= s.irisMask * d.NdotL;

    illum += aLegacySpecularBrdf(d, s);
    return illum * d.color * d.shadow;
}

half3 aIndirectLighting(
    AIndirect i,
    ASurface s)
{
    return aLegacyStandardIndirect(i, s);
}

/// Schlera tint color.
/// Expects a linear LDR color.
half3 _EyeScleraColor;

/// Schlera diffuse scattering amount.
/// Expects values in the range [0,1].
half _EyeScleraScattering;

/// Cornea specularity.
/// Expects values in the range [0,1].
half _EyeSpecularity;

/// Cornea roughness.
/// Expects values in the range [0,1].
half _EyeRoughness;

/// Iris tint color.
/// Expects a linear LDR color.
half3 _EyeColor;

/// Iris diffuse scattering amount.
/// Expects values in the range [0,1].
half _EyeIrisScattering;

/// Iris specular tint by base color.
/// Expects values in the range [0,1].
half _EyeSpecularTint;

void aSurfaceShader(
    inout ASurface s)
{
    float4 uv01 = s.uv01;
        
    aEyeParallax(s);
    aDissolve(s);
    
    half4 base = aBase(s);

    s.baseColor = base.rgb;

    half4 material = aSampleMaterial(s);

    s.irisMask = material.A_METALLIC_CHANNEL;
    s.metallic = 0.0h;
    s.ambientOcclusion = aLerpOneTo(material.A_AO_CHANNEL, _Occlusion);
    s.specularity = _Specularity * material.A_SPECULARITY_CHANNEL;
    s.roughness = _Roughness * material.A_ROUGHNESS_CHANNEL;
    
    s.normalTangent = A_NT(s, aSampleBump(s));
    
    s.baseColor *= lerp(_EyeScleraColor, _EyeColor, s.irisMask);
    s.specularTint = s.irisMask * _EyeSpecularTint;
    s.scattering = lerp(_EyeScleraScattering, _EyeIrisScattering, s.irisMask);
    s.corneaSpecularity = _EyeSpecularity;
    s.corneaRoughness = _EyeRoughness;
    
    // Don't allow detail normals in the iris.
    s.mask = 1.0h - s.irisMask;
    aDetail(s); 
    s.mask = 1.0h;
    
    aEmission(s);
    aRim(s);
    
    // Remove parallax so this appears on top of the cornea!
    s.uv01 = uv01;
    aDecal(s); 
}

#endif // ALLOY_LEGACY_SHADERS_DEFINITION_EYEBALL_CGINC
