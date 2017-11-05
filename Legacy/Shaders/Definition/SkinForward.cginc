// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Skin.cginc
/// @brief Skin surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_LEGACY_SHADERS_DEFINITION_SKIN_CGINC
#define ALLOY_LEGACY_SHADERS_DEFINITION_SKIN_CGINC

#define A_AMBIENT_OCCLUSION_ON

#define A_SURFACE_CUSTOM_FIELDS \
    half scatteringMask; \
    half scattering;

#include "Assets/Alloy/Shaders/Framework/Lighting.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

// Jon Moore recommended this value in his blog post.
#define A_SKIN_BUMP_BLUR_BIAS (3.0)

sampler2D _SssBrdfTex;

/// Biases the thickness value used to look up in the skin LUT.
/// Expects values in the range [0,1].
half _SssBias;

/// Scales the thickness value used to look up in the skin LUT.
/// Expects values in the range [0,1].
half _SssScale;

/// Amount to colorize and darken AO to simulate local scattering.
/// Expects values in the range [0,1].
half _SssAoSaturation;

/// Increases the bluriness of the normal map for diffuse lighting.
/// Expects values in the range [0,1].
half _SssBumpBlur;

/// Transmission tint color.
/// Expects a linear LDR color.
half3 _TransColor;

/// Weight of the transmission effect.
/// Expects linear space value in the range [0,1].
half _TransScale;

/// Falloff of the transmission effect.
/// Expects values in the range [1,n).
half _TransPower;

/// Amount that the transmission is distorted by surface normals.
/// Expects values in the range [0,1].
half _TransDistortion;

/// Calculates standard indirect diffuse plus specular illumination.
/// @param  d       Direct lighting data.
/// @param  s       Material surface data.
/// @param  skinLut Pre-Integrated scattering LUT.
/// @return         Direct diffuse illumination with scattering effect.
half3 aLegacySkin(
    ADirect d,
    ASurface s,
    sampler2D skinLut)
{
    // Scattering
    // cf http://www.farfarer.com/blog/2013/02/11/pre-integrated-skin-shader-unity-3d/
    float ndlBlur = dot(s.ambientNormalWorld, d.direction) * 0.5h + 0.5h;
    float2 sssLookupUv = float2(ndlBlur, s.scattering * aLuminance(d.color));
    half3 sss = s.scatteringMask * d.shadow * tex2D(skinLut, sssLookupUv).rgb;

    //#if !defined(SHADOWS_SCREEN) && !defined(SHADOWS_DEPTH) && !defined(SHADOWS_CUBE)
    //    // If shadows are off, we need to reduce the brightness
    //    // of the scattering on polys facing away from the light.		
    //    sss *= saturate(ndlBlur * 4.0h - 1.0h); // [-1,3], then clamp
    //#else
    //    sss *= d.shadow;
    //#endif

    return d.color * s.albedo * sss;
}

/// Calculates direct light transmission effect using per-pixel thickness.
/// @param d                    Indirect light description.
/// @param s                    Material surface data.
/// @param weight               Weight of the transmission effect.
/// @param distortion           Distortion due to surface normals.
/// @param falloff              Tightness of the transmitted light.
/// @param shadowWeight         Amount that the transsmision is shadowed.
/// @return                     Transmission effect.
half3 aLegacyTransmission(
    ADirect d,
    ASurface s,
    half weight,
    half distortion,
    half falloff,
    half shadowWeight)
{
    // Transmission 
    // cf http://www.farfarer.com/blog/2012/09/11/translucent-shader-unity3d/
    half3 transLightDir = d.direction + s.normalWorld * distortion;
    half transLight = pow(aDotClamp(s.viewDirWorld, -transLightDir), falloff);

    transLight *= weight * aLerpOneTo(d.shadow, shadowWeight);
    return d.color * s.subsurfaceColor * transLight;
}

/// Direct diffuse and specular BRDF.
/// @param  d   Direct lighting data.
/// @param  s   Material surface data.
/// @return     Direct diffuse BRDF.
half3 aLegacyDirectBrdf(
    ADirect d,
    ASurface s,
    half diffuseWeight)
{
    // Cook-Torrance microfacet model.
    // cf http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
    half LdotH2 = d.LdotH * d.LdotH;

    // Brent Burley diffuse BRDF.
    // cf https://disney-animation.s3.amazonaws.com/library/s2012_pbs_disney_brdf_notes_v2.pdf pg14
    half FL = aFresnel(d.NdotL);
    half Fd90 = 0.5h + (2.0h * LdotH2 * s.roughness);
    half Fd = aLerpOneTo(Fd90, FL) * aLerpOneTo(Fd90, s.FV);

    // Schlick's Fresnel approximation.
    half3 F = lerp(s.f0, A_WHITE, aFresnel(d.LdotH));

    // John Hable's Visibility function.
    // cf http://www.filmicworlds.com/2014/04/21/optimizing-ggx-shaders-with-dotlh/
    half a2 = s.beckmannRoughness * s.beckmannRoughness;
    half k2 = a2 * 0.25h; // k = a/2; k*k = (a*a)/(2*2) = (a^2)/4.
    half V = lerp(k2, 1.0h, LdotH2);

    // GGX (Trowbridge-Reitz) NDF.
    // cf http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
    half denom = aLerpOneTo(a2, d.NdotH * d.NdotH);
    half mDV = k2 / (V * denom * denom); // k2 is GGX a^2 and microfacet 1/4.

                                         // Punctual lighting equation.
                                         // cf http://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/
    return (d.shadow * d.NdotL) * (
        (s.albedo * (Fd * diffuseWeight)) + (F * (mDV * s.specularOcclusion * d.specularIntensity)));
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

    // Blurred normals for indirect diffuse and direct scattering.
    s.blurredNormalTangent = normalize(lerp(s.normalTangent, s.blurredNormalTangent, s.scatteringMask * _SssBumpBlur));
    s.ambientNormalWorld = aTangentToWorld(s, s.blurredNormalTangent);
    s.subsurfaceColor = _TransScale * _TransColor * s.albedo * s.subsurface.rrr;
    s.scattering = saturate(s.subsurface * _SssScale + _SssBias);
}

half3 aDirectLighting(
    ADirect d,
    ASurface s)
{
    return (d.color * aLegacyDirectBrdf(d, s, 1.0h - s.scatteringMask))
        + aLegacySkin(d, s, _SssBrdfTex)
        + aLegacyTransmission(d, s, 1.0h, _TransDistortion, _TransPower, 0.0h);
}

half3 aIndirectLighting(
    AIndirect i,
    ASurface s)
{
    // Saturated AO.
    // cf http://www.iryoku.com/downloads/Next-Generation-Character-Rendering-v6.pptx pg110
    half saturation = s.scatteringMask * _SssAoSaturation;

    s.albedo = pow(s.albedo, (1.0h + saturation) - saturation * s.ambientOcclusion);
    return aLegacyStandardIndirect(i, s);
}

void aSurfaceShader(
    inout ASurface s)
{
    aDissolve(s);
    
    half4 base = aBase(s);

    s.baseColor = base.rgb;
    s.subsurface = A_SS(s, base.a);
    
    half4 material = aSampleMaterial(s);

    s.scatteringMask = material.A_METALLIC_CHANNEL;
    s.metallic = 0.0h;
    s.ambientOcclusion = aLerpOneTo(material.A_AO_CHANNEL, _Occlusion);
    s.specularity = _Specularity * material.A_SPECULARITY_CHANNEL;
    s.roughness = _Roughness * material.A_ROUGHNESS_CHANNEL;
    
    s.normalTangent = A_NT(s, aSampleBump(s));
    s.blurredNormalTangent = aSampleBumpBias(s, A_SKIN_BUMP_BLUR_BIAS);
    
    aDetail(s);
    aTeamColor(s);
    aDecal(s);
    aRim(s);
    aEmission(s);
}

#endif // ALLOY_LEGACY_SHADERS_DEFINITION_SKIN_CGINC
