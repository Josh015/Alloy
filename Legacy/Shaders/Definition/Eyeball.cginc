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
#define A_AMBIENT_OCCLUSION_ON
#define A_SPECULAR_TINT_ON
#define A_CLEARCOAT_ON
#define A_EYE_PARALLAX_REFRACTION
#define A_DETAIL_MASK_OFF

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"
#include "Assets/Alloy/Legacy/Shaders/Feature/EyeParallax.cginc"

/// Cornea normals.
/// Expects a compressed normal map.
sampler2D _EyeBumpMap;

/// Cornea weight.
/// Expects values in the range [0,1].
half _EyeCorneaWeight;

/// Cornea roughness.
/// Expects values in the range [0,1].
half _EyeRoughness;

/// Schlera tint color.
/// Expects a linear LDR color.
half3 _EyeScleraColor;

/// Iris tint color.
/// Expects a linear LDR color.
half3 _EyeColor;

/// Iris specular tint by base color.
/// Expects values in the range [0,1].
half _EyeSpecularTint;

/// Samples  and scales the base bump map.
/// @param  s       Material surface data.
/// @param  scale   Normal XY scale factor.
/// @return         Normalized tangent-space normal.
half3 aSampleBumpScaleOld(
    ASurface s,
    half scale)
{
    half4 result = 0.0h;

#ifdef _VIRTUALTEXTURING_ON
    result = VTSampleNormal(s.baseVirtualCoord);
#else
    result = tex2D(_BumpMap, s.baseUv);
#endif

    return UnpackScaleNormal(result, _BumpScale * scale);
}

void aSurfaceShader(
    inout ASurface s)
{
    float4 uv01 = s.uv01;
        
    aEyeParallax(s);    
    aDissolve(s);
    
    // Iris
    half4 base = aBase(s);
    half4 material = aSampleMaterial(s);
    half irisMask = material.A_METALLIC_CHANNEL;

    s.baseColor = base.rgb * lerp(_EyeScleraColor, _EyeColor, irisMask);
    s.metallic = 0.0h;
    s.ambientOcclusion = aLerpOneTo(material.A_AO_CHANNEL, _Occlusion);
    s.specularity = _Specularity * material.A_SPECULARITY_CHANNEL;
    s.specularTint = _EyeSpecularTint * irisMask;
    s.roughness = _Roughness * material.A_ROUGHNESS_CHANNEL;

    // Cornea
    half bumpMask = s.clearCoat * 0.95h;
    half3 corneaNormalTangent = UnpackScaleNormal(tex2D(_EyeBumpMap, s.baseUv), bumpMask);
    half3 irisScleraNormalTangent = aSampleBumpScaleOld(s, 1.0h - bumpMask);

    s.clearCoat = _EyeCorneaWeight * irisMask;
    s.clearCoatRoughness = _EyeRoughness;
    s.normalTangent = A_NT(s, BlendNormals(irisScleraNormalTangent, corneaNormalTangent));

    s.mask = 1.0h - irisMask;
    aDetail(s); 
    s.mask = 1.0h;
    
    aEmission(s);
    
    // Remove parallax so these appears on top of the cornea!
    s.uv01 = uv01;
    aDecal(s); 
    aRim(s);
}

#endif // ALLOY_LEGACY_SHADERS_DEFINITION_EYEBALL_CGINC
