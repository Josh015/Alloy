// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file LightingImpl.cginc
/// @brief Lighting method implementations to allow disabling of features.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_LIGHTING_IMPL_CGINC
#define ALLOY_SHADERS_FRAMEWORK_LIGHTING_IMPL_CGINC

// Headers both for this file, and for all Definition and Feature modules.
#include "Assets/Alloy/Shaders/Config.cginc"
#include "Assets/Alloy/Shaders/Framework/Lighting.cginc"
#include "Assets/Alloy/Shaders/Framework/Utility.cginc"

#include "HLSLSupport.cginc"
#include "UnityCG.cginc"
#include "UnityShaderVariables.cginc"

#if !A_USE_UNITY_ATTENUATION || defined(USING_DIRECTIONAL_LIGHT)
    #define A_UNITY_ATTENUATION(d, tex, lightCoord, scale)
#else
    #define A_UNITY_ATTENUATION(d, tex, lightCoord, scale) d.color *= tex2D(tex, (dot(lightCoord, lightCoord) * scale).rr).UNITY_ATTEN_CHANNEL;
#endif

#if !defined(A_REFLECTION_PROBES_ON) && (!defined(A_GBUFFER_PASS) || !UNITY_ENABLE_REFLECTION_BUFFERS)
    #define A_REFLECTION_PROBES_ON
#endif

// Lighting required vertex data flags.
#ifndef A_UNLIT_MODE
    #ifdef A_DIRECT_LIGHTING_PASS
        #define A_DIRECT_ON
    #endif

    #ifdef A_INDIRECT_LIGHTING_PASS
        #define A_INDIRECT_ON
    #endif

    #if defined(A_DIRECT_ON) || defined(A_INDIRECT_ON)
        #define A_LIGHTING_ON
    #endif
#endif

#ifndef A_LIGHTING_ON
    #if !defined(A_NORMAL_WORLD_ON) && defined(A_GBUFFER_PASS)
        #define A_NORMAL_WORLD_ON
    #endif
#else
    #ifndef A_NORMAL_WORLD_ON
        #define A_NORMAL_WORLD_ON
    #endif

    #ifndef A_VIEW_DIR_WORLD_ON
        #define A_VIEW_DIR_WORLD_ON
    #endif
        
    #ifndef A_POSITION_WORLD_ON
        #define A_POSITION_WORLD_ON
    #endif
            
    #if !defined(A_REFLECTION_VECTOR_WORLD_ON) && (defined(A_DIRECT_ON) || defined(A_REFLECTION_PROBES_ON))
        #define A_REFLECTION_VECTOR_WORLD_ON
    #endif
#endif

#if !defined(A_TANGENT_TO_WORLD_ON) && defined(A_NORMAL_MAPPED_PASS) && (defined(A_VIEW_DIR_TANGENT_ON) || defined(A_NORMAL_MAPPING_ON))
    #define A_TANGENT_TO_WORLD_ON
#endif

#ifndef A_SCATTERING_ON
    #define A_SKIN_SUBSURFACE_WEIGHT 1.0h
#else
    #define A_SKIN_SUBSURFACE_WEIGHT _TransWeight

    #ifdef A_FORWARD_ONLY_SHADER
        #define A_SCATTERING_LUT _SssBrdfTex
        #define A_SCATTERING_WEIGHT _SssWeight
        #define A_SCATTERING_INV_MASK_CUTOFF 1.0h / _SssMaskCutoff
        #define A_SCATTERING_BIAS _SssBias
        #define A_SCATTERING_SCALE _SssScale
        #define A_SCATTERING_NORMAL_BLUR _SssBumpBlur
        #define A_SCATTERING_ABSORPTION _SssTransmissionAbsorption
        #define A_SCATTERING_AO_COLOR_BLEED _SssColorBleedAoWeights
    #else
        #define A_SCATTERING_LUT _DeferredSkinLut
        #define A_SCATTERING_WEIGHT _DeferredSkinParams.x
        #define A_SCATTERING_INV_MASK_CUTOFF _DeferredSkinParams.y
        #define A_SCATTERING_BIAS _DeferredSkinTransmissionAbsorption.w
        #define A_SCATTERING_SCALE _DeferredSkinColorBleedAoWeights.w
        #define A_SCATTERING_NORMAL_BLUR _DeferredSkinParams.z
        #define A_SCATTERING_ABSORPTION _DeferredSkinTransmissionAbsorption.xyz
        #define A_SCATTERING_AO_COLOR_BLEED _DeferredSkinColorBleedAoWeights.xyz
    #endif
#endif

#ifdef A_SUBSURFACE_ON
    #ifdef A_FORWARD_ONLY_SHADER
        #define A_SUBSURFACE_WEIGHT A_SKIN_SUBSURFACE_WEIGHT
        #define A_SUBSURFACE_FALLOFF _TransPower
        #define A_SUBSURFACE_DISTORTION _TransDistortion
        #define A_SUBSURFACE_SHADOW _TransShadowWeight
    #else
        #define A_SUBSURFACE_WEIGHT _DeferredTransmissionParams.x
        #define A_SUBSURFACE_FALLOFF _DeferredTransmissionParams.y
        #define A_SUBSURFACE_DISTORTION _DeferredTransmissionParams.z
        #define A_SUBSURFACE_SHADOW _DeferredTransmissionParams.w
    #endif
#endif

#if !A_USE_DEFERRED_MATERIAL_TYPE_BRANCHING || !defined(A_DEFERRED_PASS)
    #define A_DEFERRED_BRANCH(CONDITION)
#else
    #define A_DEFERRED_BRANCH(CONDITION) \
        UNITY_BRANCH \
        if (CONDITION)
#endif

AIndirect aNewIndirect() {
    AIndirect i;

    UNITY_INITIALIZE_OUTPUT(AIndirect, i);
    i.diffuse = 0.0h;
    i.specular = 0.0h;

    return i;
}

ADirect aNewDirect() 
{
    ADirect d;

    UNITY_INITIALIZE_OUTPUT(ADirect, d);
    d.color = 0.0h;
    d.shadow = 1.0h;
    d.specularIntensity = 1.0h;
    d.direction = A_AXIS_Y;
        
    return d;
}

void aLightCookie(
    inout ADirect d,
    half4 cookie)
{
#if defined(UNITY_PASS_FORWARDBASE) || A_USE_UNITY_LIGHT_COOKIES
    d.color *= cookie.a;
#else
    d.color *= cookie.rgb * cookie.a;
#endif
}

void aSetLightRangeLimit(
    inout ADirect d,
    half range) 
{
#if !A_USE_UNITY_ATTENUATION
    // Light Range Limit Falloff.
    // cf http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf p12-13
    half ratio = 1.0h / (range * d.centerDistInverse);
    half ratio2 = ratio * ratio;
    half num = saturate(1.0h - (ratio2 * ratio2));

    d.color *= num * num;
#endif
}

void aUpdateLightingInputs(
    inout ADirect d,
    ASurface s)
{
    d.halfAngleWorld = normalize(d.direction + s.viewDirWorld);
    d.LdotH = aDotClamp(d.direction, d.halfAngleWorld);
    d.NdotH = aDotClamp(s.normalWorld, d.halfAngleWorld);
}

void aSetAreaSpecularInputs(
    inout ADirect d,
    ASurface s,
    half radius)
{
    // Representative Point Area Lights.
    // cf http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf p14-16
#ifdef A_AREA_SPECULAR_OFF
    d.direction = d.Ldiff;
#else
    float3 R = s.reflectionVectorWorld;
    float3 centerToRay = dot(d.Lspec, R) * R - d.Lspec;
    float3 closestPoint = d.Lspec + centerToRay * saturate(radius * rsqrt(dot(centerToRay, centerToRay)));
    half LspecLengthInverse = rsqrt(dot(closestPoint, closestPoint));
    half a = s.beckmannRoughness;
    half normalizationFactor = a / saturate(a + (radius * 0.5h * LspecLengthInverse));

    d.direction = closestPoint * LspecLengthInverse;
    d.specularIntensity = normalizationFactor * normalizationFactor;
#endif

    aUpdateLightingInputs(d, s);
}

half aSetAreaLightingInputs(
    inout ADirect d,
    ASurface s,
    half radius)
{
    // Specular.
    aSetAreaSpecularInputs(d, s, radius);

    // Diffuse.
    // Set diffuse light direction last to fix transmission & hair.
    half LdiffLengthSquared = dot(d.Ldiff, d.Ldiff);
    half LdiffLengthInverse = rsqrt(LdiffLengthSquared);

    d.direction = d.Ldiff * LdiffLengthInverse;
    d.NdotLm = dot(s.normalWorld, d.direction);
    d.NdotL = saturate(d.NdotLm);

#if !A_USE_UNITY_ATTENUATION
    d.color /= (LdiffLengthSquared + 1.0h); // Attenuation.
#endif

    return LdiffLengthInverse;
}

void aDirectionalLight(
    inout ADirect d,
    ASurface s)
{
    d.NdotLm = dot(s.normalWorld, d.direction);
    d.NdotL = saturate(d.NdotLm);
    aUpdateLightingInputs(d, s);
}

void aDirectionalDiscLight(
    inout ADirect d,
    ASurface s,
    half3 direction,
    half radius)
{
    d.Ldiff = direction;
    d.Lspec = direction;

    // Specular.
    aSetAreaSpecularInputs(d, s, radius);

    // Diffuse.
    // Set diffuse light direction last to fix transmission & hair.
    d.direction = d.Ldiff;
    d.NdotLm = dot(s.normalWorld, d.direction);
    d.NdotL = saturate(d.NdotLm);
}

void aSphereLight(
    inout ADirect d,
    ASurface s,
    float3 L,
    half radius)
{
    // Sphere Area Light.
    // cf http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf p15-16
    d.Ldiff = L;
    d.Lspec = L;
    d.centerDistInverse = aSetAreaLightingInputs(d, s, radius);
}

void aTubeLight(
    inout ADirect d,
    ASurface s,
    float3 L,
    half3 axis,
    half radius,
    half halfLength)
{
    // Tube Area Light.
    // cf http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf p16-18
    float3 R = s.reflectionVectorWorld;
    float3 tubeLightDir = axis * halfLength;
    float3 L0 = L + tubeLightDir;
    float3 L1 = L - tubeLightDir;
    float3 Ld = tubeLightDir * -2.0f;
    float RdotL0 = dot(R, L0);
    float RdotLd = dot(R, Ld);
    float L0dotLd = dot(L0, Ld);
    float t = (RdotL0 * RdotLd - L0dotLd) / (dot(Ld, Ld) - RdotLd * RdotLd);

    // Modified diffuse term for true tube diffuse lighting.
    d.Ldiff = L - clamp(dot(L, axis), -halfLength, halfLength) * axis;
    d.Lspec = L0 + Ld * saturate(t);
    d.centerDistInverse = rsqrt(dot(L, L));

    // Attentuation normalization.
    d.color /= 1.0h + (0.25h * halfLength * aSetAreaLightingInputs(d, s, radius));
}

void aAreaLight(
    inout ADirect d,
    ASurface s,
    half4 color,
    half3 axis,
    float3 L,
    half range)
{
    // Packed float light configuration.
    // +/- llll.rrrr: l=length, r=radius, and sign as specular toggle.
    // Radius externally clamped to .999 max to simplify math.
    half lightParams = abs(color.a);
    
#ifdef USING_DIRECTIONAL_LIGHT
    // 0.1 needed to make material inspector look okay.
    aDirectionalDiscLight(d, s, L, lightParams * 0.1h); 
#else
    #if !defined(SPOT) && A_USE_TUBE_LIGHTS
        // Enable when length is non-zero, and specular is enabled.
        UNITY_BRANCH
        if (color.a >= 1) {
            half dec = frac(lightParams);
            half radius = dec * range;
            half halfLength = (lightParams - dec) * 0.001f * range;

            aTubeLight(d, s, L, axis, radius, halfLength);
        }
        else
    #endif
    {
        aSphereLight(d, s, L, lightParams * range);
    }

    aSetLightRangeLimit(d, range);
#endif

    // Specular highlight toggle.
    d.specularIntensity = color.a > 0.0h ? d.specularIntensity : 0.0h;
}

ASurface aNewSurface() {
    ASurface s;

    UNITY_INITIALIZE_OUTPUT(ASurface, s);
    s.vertexNormalWorld = A_FLAT_NORMAL;
    s.normalWorld = A_FLAT_NORMAL;
    s.viewDirWorld = A_AXIS_X;
    s.viewDirTangent = A_AXIS_X;
    s.reflectionVectorWorld = A_AXIS_X;
    s.tangentToWorld = 0.0h;
    s.normalTangent = A_FLAT_NORMAL;
    s.blurredNormalTangent = A_FLAT_NORMAL;
    s.facingSign = 1.0h;
    s.fogCoord = 0.0f;
    s.NdotV = 0.0h;
    s.FV = 0.0h;
    s.materialType = 1.0h;
    s.mask = 1.0h;

    s.baseColor = 0.0h;
    s.opacity = 1.0h;
    s.metallic = 0.0h;
    s.ambientOcclusion = 1.0h;
    s.specularity = 0.5h;
    s.specularTint = 0.0h;
    s.roughness = 0.0h;
    s.emissiveColor = 0.0h;
    s.subsurfaceColor = 0.0h;
    s.subsurface = 0.0h;
    s.clearCoat = 0.0h;
    s.clearCoatRoughness = 0.0h;

    return s;
}

void aBlendRangeMask(
    inout ASurface s,
    half mask,
    half weight,
    half cutoff,
    half blendRange,
    half vertexTint)
{
    cutoff = lerp(cutoff, 1.0h, s.vertexColor.a * vertexTint);
    mask = 1.0h - saturate((mask - cutoff) / blendRange);
    s.mask *= weight * mask;
}

half3 aTangentToWorld(
    ASurface s,
    half3 normalTangent)
{
#ifndef A_TANGENT_TO_WORLD_ON
    return s.vertexNormalWorld;
#else
    return normalize(mul(normalTangent, s.tangentToWorld));
#endif
}

half3 aWorldToTangent(
    ASurface s,
    half3 normalWorld)
{
#ifndef A_TANGENT_TO_WORLD_ON
    return A_FLAT_NORMAL;
#else
    return normalize(mul(s.tangentToWorld, normalWorld));
#endif
}

void aUpdateViewData(
    inout ASurface s)
{
#if defined(A_NORMAL_WORLD_ON) && defined(A_VIEW_DIR_WORLD_ON)
    // Area lights need this to be per-pixel.
    #ifdef A_REFLECTION_VECTOR_WORLD_ON
        s.reflectionVectorWorld = reflect(-s.viewDirWorld, s.normalWorld);
    #endif

    // Skip re-calculating world normals in some cases.
    #ifndef A_VIEW_DIR_TANGENT_ON
        s.NdotV = aDotClamp(s.normalWorld, s.viewDirWorld);
    #else
        s.NdotV = aDotClamp(s.normalTangent, s.viewDirTangent);
    #endif

    s.FV = aFresnel(s.NdotV);
#endif
}

void aUpdateNormalTangent(
    inout ASurface s)
{
#ifndef A_TANGENT_TO_WORLD_ON
    s.normalTangent = A_FLAT_NORMAL;
#else
    s.normalWorld = aTangentToWorld(s, s.normalTangent);
    s.ambientNormalWorld = s.normalWorld;
    aUpdateViewData(s);
#endif
}

void aUpdateNormalWorld(
    inout ASurface s)
{
#ifndef A_TANGENT_TO_WORLD_ON
    s.normalWorld = s.vertexNormalWorld;
#else
    s.normalTangent = aWorldToTangent(s, s.normalWorld);
    s.ambientNormalWorld = s.normalWorld;
    aUpdateViewData(s);
#endif
}

void aUpdateSubsurface(
    inout ASurface s)
{
    s.subsurfaceColor = aGammaToLinear(s.subsurface).rrr;
}

void aUpdateSubsurfaceColor(
    inout ASurface s)
{
    s.subsurface = LinearToGammaSpace(s.subsurfaceColor).g;
}

half3 aSpecularityToF0(
    half specularity)
{
    return (specularity * A_MAX_DIELECTRIC_F0).rrr;
}

half aLinearToBeckmannRoughness(
    half roughness)
{
    // Remap roughness to prevent specular artifacts.
    roughness = lerp(A_MIN_AREA_ROUGHNESS, 1.0h, roughness);
    return roughness * roughness;
}

half aFresnel(
    half w)
{
    // Sebastien Lagarde's spherical gaussian approximation of Schlick fresnel.
    // cf http://seblagarde.wordpress.com/2011/08/17/hello-world/
    return exp2((-5.55473h * w - 6.98316h) * w);
}

half3 aSpecularLightingToggle( 
    ASurface s,
    half3 specular)
{
#if !A_USE_BLACK_SPECULAR_COLOR_TOGGLE
    return specular;
#else
    return any(s.f0) ? specular : A_BLACK;
#endif
}

half aSpecularOcclusion(
    half ao,
    half NdotV)
{
    // Yoshiharu Gotanda's specular occlusion approximation:
    // cf http://research.tri-ace.com/Data/cedec2011_RealtimePBR_Implementation_e.pptx pg59
    half d = NdotV + ao;
    return saturate((d * d) - 1.0h + ao);
}

void aStandardPreLighting(
    inout ASurface s)
{
    // In Forward mode, set material type.
#ifndef A_DEFERRED_PASS
    s.baseColor = saturate(s.baseColor);
    s.albedo = s.baseColor;
    s.f0 = aSpecularityToF0(s.specularity);

    #ifndef A_SPECULAR_TINT_ON
        s.specularTint = 0.0h;
    #else
        s.f0 *= aLerpWhiteTo(aChromaticity(s.baseColor), s.specularTint);
    #endif

    #ifndef A_METALLIC_ON
        s.metallic = 0.0h;
    #else
        half metallicInv = 1.0h - s.metallic;

        s.albedo *= metallicInv; // Affects transmission through albedo.
        s.f0 = lerp(s.f0, s.baseColor, s.metallic);

        #ifdef _ALPHAPREMULTIPLY_ON
            // Interpolate from a translucent dielectric to an opaque metal.
            s.opacity = s.metallic + metallicInv * s.opacity;
        #endif
    #endif

    #ifndef A_CLEARCOAT_ON
        s.clearCoat = 0.0h;
        s.clearCoatRoughness = 0.0h;
    #else
        // f0 of 0.04 gives us a polyurethane-like coating.
        half clearCoat = s.clearCoat * lerp(0.04h, 1.0h, s.FV);

        s.albedo *= aLerpOneTo(0.0h, clearCoat);
        s.f0 = lerp(s.f0, A_WHITE, clearCoat);
        s.roughness = lerp(s.roughness, s.clearCoatRoughness, clearCoat);
    #endif

    #ifdef _ALPHAPREMULTIPLY_ON
        // Premultiply opacity with albedo for translucent shaders.
        s.albedo *= s.opacity;
    #endif

    s.beckmannRoughness = aLinearToBeckmannRoughness(s.roughness);

    #ifndef A_AMBIENT_OCCLUSION_ON
        s.ambientOcclusion = 1.0h;
        s.specularOcclusion = 1.0h;
    #else
        s.specularOcclusion = aSpecularOcclusion(s.ambientOcclusion, s.NdotV);
    #endif

    #if defined(A_SCATTERING_ON)
        s.materialType = A_MATERIAL_TYPE_SUBSURFACE_SCATTERING;
        s._subsurfaceShadowWeight = 0.0h;
        s._skinScatteringMask = 1.0h;
        s.ambientNormalWorld = aTangentToWorld(s, s.blurredNormalTangent);
    #elif defined(A_SUBSURFACE_ON)
        #ifdef A_TWO_SIDED_SHADER
            s.materialType = A_MATERIAL_TYPE_SHADOWED_SUBSURFACE;
            s._subsurfaceShadowWeight = A_SUBSURFACE_SHADOW;
        #else
            s.materialType = _ShadowCullMode == A_CULL_MODE_FRONT ? A_MATERIAL_TYPE_SHADOWED_SUBSURFACE : A_MATERIAL_TYPE_UNSHADOWED_SUBSURFACE;
            s._subsurfaceShadowWeight = _ShadowCullMode == A_CULL_MODE_FRONT ? A_SUBSURFACE_SHADOW : 0.0h;
        #endif
    #else
        s.materialType = A_MATERIAL_TYPE_OPAQUE;
    #endif
#endif

#if defined(A_SCATTERING_ON) || defined(A_SUBSURFACE_ON)
    A_DEFERRED_BRANCH(s.materialType != A_MATERIAL_TYPE_OPAQUE)
    {
    // In Deferred mode, determine material type and sample extra G-buffer data.
    #if defined(A_DEFERRED_PASS)
        half4 buffer = tex2Dlod(_DeferredPlusBuffer, float4(s.screenUv, 0.0f, 0.0f));

        s.subsurface = buffer.a;
        s._subsurfaceShadowWeight = s.materialType == A_MATERIAL_TYPE_SHADOWED_SUBSURFACE ? A_SUBSURFACE_SHADOW : 0.0h;

        #if defined(A_SCATTERING_ON)
            s._skinScatteringMask = s.materialType == A_MATERIAL_TYPE_SUBSURFACE_SCATTERING ? 1.0h : 0.0h;
            s.ambientNormalWorld = normalize(buffer.xyz * 2.0h - 1.0h);
        #endif
    #endif

    // Subsurface color calculation.
    #ifdef A_SUBSURFACE_ON
        #ifdef A_FORWARD_ONLY_SHADER
            s.subsurfaceColor *= s.albedo;
        #else
            s.subsurfaceColor = s.albedo * aGammaToLinear(s.subsurface);
        #endif
    #endif

    // Scattering input data.
    #ifdef A_SCATTERING_ON
        A_DEFERRED_BRANCH(s.materialType == A_MATERIAL_TYPE_SUBSURFACE_SCATTERING)
        {
            // Scattering mask.
            s._skinScatteringMask *= A_SCATTERING_WEIGHT * saturate(A_SCATTERING_INV_MASK_CUTOFF * s.subsurface);
            s._skinScattering = saturate(s.subsurface * A_SCATTERING_SCALE + A_SCATTERING_BIAS);

            // Skin subsurface depth absorption tint.
            // cf http://www.crytek.com/download/2014_03_25_CRYENGINE_GDC_Schultz.pdf pg 35
            half3 absorption = exp((1.0h - s.subsurface) * A_SCATTERING_ABSORPTION);

            // Albedo scale for absorption assumes ~0.5 luminance for Caucasian skin.
            absorption *= saturate(s.albedo * unity_ColorSpaceDouble.rgb);
            s.subsurfaceColor = lerp(s.subsurfaceColor, absorption, s._skinScatteringMask);

            // Blurred normals for indirect diffuse and direct scattering.
            s.ambientNormalWorld = normalize(lerp(s.normalWorld, s.ambientNormalWorld, A_SCATTERING_NORMAL_BLUR * s._skinScatteringMask));
        }
    #endif

    // Subsurface color weight.
    #ifdef A_SUBSURFACE_ON
        s.subsurfaceColor *= A_SUBSURFACE_WEIGHT;
    #endif
    }
#endif
}

half3 aStandardDirectLighting(
    ADirect d,
    ASurface s)
{
    half3 illum = A_BLACK;
    half3 specular = A_BLACK;

#if defined(A_SCATTERING_ON) || defined(A_SUBSURFACE_ON)
    A_DEFERRED_BRANCH(s.materialType != A_MATERIAL_TYPE_OPAQUE)
    {
    #ifdef A_SUBSURFACE_ON
        // Subsurface transmission.
        // cf http://www.farfarer.com/blog/2012/09/11/translucent-shader-unity3d/
        half3 transLightDir = d.direction + s.normalWorld * A_SUBSURFACE_DISTORTION;
        half transLight = pow(aDotClamp(s.viewDirWorld, -transLightDir), A_SUBSURFACE_FALLOFF);
        half shadow = aLerpOneTo(d.shadow, s._subsurfaceShadowWeight);

        illum += s.subsurfaceColor * (shadow * transLight);
    #endif

    #ifdef A_SCATTERING_ON
        A_DEFERRED_BRANCH(s.materialType == A_MATERIAL_TYPE_SUBSURFACE_SCATTERING)
        {
            // Pre-Integrated Skin Shading.
            // cf http://www.farfarer.com/blog/2013/02/11/pre-integrated-skin-shader-unity-3d/
            float ndlBlur = dot(s.ambientNormalWorld, d.direction) * 0.5h + 0.5h;
            float4 sssLookupUv = float4(ndlBlur, s._skinScattering * aLuminance(d.color), 0.0f, 0.0f);
            half3 sss = (s._skinScatteringMask * d.shadow) * tex2Dlod(A_SCATTERING_LUT, sssLookupUv).rgb;

            illum += s.albedo * sss;
            s.albedo *= 1.0h - s._skinScatteringMask;
        }
    #endif
    }
#endif

    // Cook-Torrance microfacet model.
    // cf http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
    half LdotH2 = d.LdotH * d.LdotH;

    // Brent Burley diffuse BRDF.
    // cf https://disney-animation.s3.amazonaws.com/library/s2012_pbs_disney_brdf_notes_v2.pdf pg14
    half FL = aFresnel(d.NdotL);
    half Fd90 = 0.5h + (2.0h * LdotH2 * s.roughness);
    half Fd = aLerpOneTo(Fd90, FL) * aLerpOneTo(Fd90, s.FV);
    half3 diffuse = s.albedo * Fd;

#ifndef _SPECULARHIGHLIGHTS_OFF
    // Schlick's Fresnel approximation.
    half3 F = lerp(s.f0, A_WHITE, aFresnel(d.LdotH));

    // John Hable's Visibility function.
    // cf http://www.filmicworlds.com/2014/04/21/optimizing-ggx-shaders-with-dotlh/
    half a2 = s.beckmannRoughness * s.beckmannRoughness;
    half k2 = a2 * 0.25h; // k = a/2; k*k = (a*a)/(2*2) = (a^2)/4.
    half invV = lerp(k2, 1.0h, LdotH2);

    // GGX (Trowbridge-Reitz) NDF.
    // cf http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
    half denom = aLerpOneTo(a2, d.NdotH * d.NdotH);
    half mDV = k2 / (invV * denom * denom); // k2 is GGX a^2 and microfacet 1/4.

    specular = aSpecularLightingToggle(s, F * (mDV * s.specularOcclusion * d.specularIntensity));
#endif

    // Punctual lighting equation.
    // cf http://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/
    illum += (d.shadow * d.NdotL) * (diffuse + specular);

    return d.color * illum;
}

half3 aStandardIndirectLighting(
    AIndirect i,
    ASurface s)
{
    half3 illum = A_BLACK;

#if defined(A_DEFERRED_PASS) || defined(A_REFLECTION_PROBES_ON)
    // Brian Karis' modification of Dimitar Lazarov's Environment BRDF.
    // cf https://www.unrealengine.com/blog/physically-based-shading-on-mobile
    const half4 c0 = half4(-1.0h, -0.0275h, -0.572h, 0.022h);
    const half4 c1 = half4(1.0h, 0.0425h, 1.04h, -0.04h);
    half4 r = s.roughness * c0 + c1;
    half a004 = min(r.x * r.x, exp2(-9.28h * s.NdotV)) * r.x + r.y;
    half2 AB = half2(-1.04h, 1.04h) * a004 + r.zw;
    half3 specular = i.specular * (s.f0 * AB.x + AB.yyy);
#endif

#ifdef A_DEFERRED_PASS
    illum = aSpecularLightingToggle(s, specular * s.specularOcclusion);
#else
    #ifndef A_AMBIENT_OCCLUSION_ON
        half3 diffuse = s.albedo * i.diffuse;

        #ifndef A_REFLECTION_PROBES_ON
            illum = diffuse;
        #else
            illum = diffuse + aSpecularLightingToggle(s, specular);
        #endif
    #else
        #ifndef A_SCATTERING_ON
            half ao = s.ambientOcclusion;
        #else
            // Color Bleed AO.
            // cf http://www.iryoku.com/downloads/Next-Generation-Character-Rendering-v6.pptx pg113
            half3 ao = pow(s.ambientOcclusion.rrr, A_ONE - (A_SCATTERING_AO_COLOR_BLEED * s._skinScatteringMask));
        #endif

        // Yoshiharu Gotanda's fake interreflection for specular occlusion.
        // Modified to better account for surface f0.
        // cf http://research.tri-ace.com/Data/cedec2011_RealtimePBR_Implementation_e.pptx pg65
        half3 ambient = i.diffuse * ao;

        #ifndef A_REFLECTION_PROBES_ON
            // Diffuse and fake interreflection only.
            illum = ambient * (s.albedo + aSpecularLightingToggle(s, s.f0 * (1.0h - s.specularOcclusion)));
        #else
            // Full equation.
            illum = ambient * s.albedo
                + aSpecularLightingToggle(s, lerp(ambient * s.f0, specular, s.specularOcclusion));
        #endif
    #endif
#endif

    return illum;
}

#endif // ALLOY_SHADERS_FRAMEWORK_LIGHTING_IMPL_CGINC
