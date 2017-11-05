/////////////////////////////////////////////////////////////////////////////////
/// @file Eye.cginc
/// @brief Eye parallax, layer control, etc.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_EYE_CGINC
#define ALLOY_SHADERS_FEATURE_EYE_CGINC

#ifdef A_EYE_ON
    #ifndef A_NORMAL_MAPPING_ON
        #define A_NORMAL_MAPPING_ON
    #endif

    #ifndef A_VIEW_DIR_TANGENT_ON
        #define A_VIEW_DIR_TANGENT_ON
    #endif

    #ifndef A_METALLIC_ON
        #define A_METALLIC_ON
    #endif

    #if !defined(A_AMBIENT_OCCLUSION_ON) && !defined(A_ROUGHNESS_SOURCE_BASE_COLOR_ALPHA)
        #define A_AMBIENT_OCCLUSION_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_EYE_ON
    /// Cornea tint color.
    /// Expects a linear LDR color.
    half4 _CorneaColor;

    /// Cornea normal map.
    /// Expects a compressed normal map.
    sampler2D _CorneaNormalMap;

    /// Cornea metallic.
    /// Expects values in the range [0,1].
    half _CorneaMetallic;

    /// Cornea specularity.
    /// Expects values in the range [0,1].
    half _CorneaSpecularity;

    /// Cornea roughness.
    /// Expects values in the range [0,1].
    half _CorneaRoughness;

    /// Cornea normal map XY scale.
    half _CorneaNormalMapScale;

    /// Iris tint color.
    /// Expects a linear LDR color.
    half3 _IrisColor;

    /// Iris pupil dilation.
    /// Expects values in the range [0,1].
    half _IrisPupilSize;

    /// Iris fake shadowing at grazing angles.
    /// Expects values in the range [0.01,n].
    half _IrisShadowing;

    /// Iris fake scattering intensity.
    /// Expects values in the range [0,n].
    half _IrisScatterIntensity;

    /// Iris fake scattering falloff.
    /// Expects values in the range [0.01,n].
    half _IrisScatterPower;

    /// Sclera tint color.
    /// Expects a linear LDR color.
    half3 _ScleraColor;

    /// Sclera metallic.
    /// Expects values in the range [0,1].
    half _ScleraMetallic;

    /// Sclera specularity.
    /// Expects values in the range [0,1].
    half _ScleraSpecularity;

    /// Sclera roughness.
    /// Expects values in the range [0,1].
    half _ScleraRoughness;

    /// Sclera normal map XY scale.
    half _ScleraNormalMapScale;
#endif

void aEye(
    inout ASurface s)
{
#ifdef A_EYE_ON
    float2 baseUv = s.baseUv;
    float4 uv = s.uv01;

    // Cornea "Refraction".
    aParallaxOcclusionMapping(s, 10.0f, 25.0f);

    // Pupil Dilation
    // HACK: Use the heightmap as the gradient, since it matches the other maps.
    // http://www.polycount.com/forum/showpost.php?p=1511423&postcount=13
    half mask = 1.0h - aSampleHeight(s);
    float2 centeredUv = frac(s.baseUv) + float2(-0.5f, -0.5f);
    float2 dilationOffset = centeredUv * (mask * _IrisPupilSize);

    aParallaxOffset(s, -dilationOffset);

    // Materials.
    half4 base = aSampleBase(s);
    half irisMask = base.a;
    s.baseColor = base.rgb;

    // Iris.
    half3 irisBump = aSampleBumpScale(s, lerp(_ScleraNormalMapScale, 1.0h, irisMask));
    half irisNdotV = irisMask * aDotClamp(irisBump, s.viewDirTangent);

    s.baseColor += (_IrisScatterIntensity * pow(aLuminance(base) * irisNdotV, _IrisScatterPower)).rrr;
    s.baseColor *= aLerpOneTo(pow(irisNdotV, _IrisShadowing), irisMask);
    s.baseColor *= _Color * aBaseVertexColorTint(s) * lerp(_ScleraColor, _IrisColor, irisMask);

    // No Parallax.
    s.baseUv = A_BV(s, baseUv);
    s.uv01 = uv;

    // Cornea & Sclera.
    half3 corneaBump = UnpackScaleNormal(tex2D(_CorneaNormalMap, s.baseUv), _CorneaNormalMapScale);

    s.baseColor = lerp(s.baseColor, _CorneaColor, irisMask * _CorneaColor.a);
    s.metallic = lerp(_ScleraMetallic, _CorneaMetallic * _CorneaColor.a, irisMask);
    s.specularity = lerp(_ScleraSpecularity, _CorneaSpecularity, irisMask);
    s.roughness = lerp(_ScleraRoughness, _CorneaRoughness, irisMask);
    s.normalTangent = A_NT(s, BlendNormals(corneaBump, lerp(irisBump, A_FLAT_NORMAL, irisMask)));

    #ifndef A_ROUGHNESS_SOURCE_BASE_COLOR_ALPHA   
        half4 material = aSampleMaterial(s);

        s.metallic *= material.A_METALLIC_CHANNEL;
        s.ambientOcclusion = material.A_AO_CHANNEL;
        s.specularity *= material.A_SPECULARITY_CHANNEL;
        s.roughness *= material.A_ROUGHNESS_CHANNEL;
    #endif
    
    // Iris mask on outside effects.
    s.mask = 1.0h - irisMask;
#endif
}

#endif // ALLOY_SHADERS_FEATURE_EYE_CGINC
