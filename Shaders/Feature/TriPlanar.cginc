// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file TriPlanar.cginc
/// @brief TriPlanar mapping.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FEATURE_TRIPLANAR_CGINC
#define ALLOY_SHADERS_FEATURE_TRIPLANAR_CGINC

#ifdef A_TRIPLANAR_ON
    #ifndef A_TRIPLANAR_MAPPING_ON
        #define A_TRIPLANAR_MAPPING_ON
    #endif

    #ifndef A_METALLIC_ON
        #define A_METALLIC_ON
    #endif

    #ifndef A_SPECULAR_TINT_ON
        #define A_SPECULAR_TINT_ON
    #endif

    #if !defined(A_AMBIENT_OCCLUSION_ON) && !defined(A_ROUGHNESS_SOURCE_BASE_COLOR_ALPHA)
        #define A_AMBIENT_OCCLUSION_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"

#ifdef A_TRIPLANAR_ON
    half _TriplanarBlendSharpness;
    
    half4 _PrimaryColor;
    A_SAMPLER_2D(_PrimaryMainTex);
    sampler2D _PrimaryMaterialMap;
    sampler2D _PrimaryBumpMap;
    half _PrimaryColorVertexTint;
    half _PrimaryMetallic;
    half _PrimarySpecularity;
    half _PrimarySpecularTint;
    half _PrimaryOcclusion;
    half _PrimaryRoughness;
    half _PrimaryBumpScale;

    #ifdef _SECONDARY_TRIPLANAR_ON
        half4 _SecondaryColor;
        A_SAMPLER_2D(_SecondaryMainTex);
        sampler2D _SecondaryMaterialMap;
        sampler2D _SecondaryBumpMap;
        half _SecondaryColorVertexTint;
        half _SecondaryMetallic;
        half _SecondarySpecularity;
        half _SecondarySpecularTint;
        half _SecondaryOcclusion;
        half _SecondaryRoughness;
        half _SecondaryBumpScale;
    #endif

    #ifdef _TERTIARY_TRIPLANAR_ON
        half4 _TertiaryColor;
        A_SAMPLER_2D(_TertiaryMainTex);
        sampler2D _TertiaryMaterialMap;
        sampler2D _TertiaryBumpMap;
        half _TertiaryColorVertexTint;
        half _TertiaryMetallic;
        half _TertiarySpecularity;
        half _TertiarySpecularTint;
        half _TertiaryOcclusion;
        half _TertiaryRoughness;
        half _TertiaryBumpScale;
    #endif

    #ifdef _QUATERNARY_TRIPLANAR_ON
        half4 _QuaternaryColor;
        A_SAMPLER_2D(_QuaternaryMainTex);
        sampler2D _QuaternaryMaterialMap;
        sampler2D _QuaternaryBumpMap;
        half _QuaternaryColorVertexTint;
        half _QuaternaryMetallic;
        half _QuaternarySpecularity;
        half _QuaternarySpecularTint;
        half _QuaternaryRoughness;
        half _QuaternaryOcclusion;
        half _QuaternaryBumpScale;
    #endif
#endif

void aTriPlanar(
    inout ASurface s) 
{
#ifdef A_TRIPLANAR_ON
    ASplatContext sc = aNewSplatContext(s, _TriplanarBlendSharpness, 1.0h);
    ASplat sp0 = aNewSplat();
    
    #if 1 // PRIMARY
        #if defined(_SECONDARY_TRIPLANAR_ON) || defined(_TERTIARY_TRIPLANAR_ON)
            aTriPlanarPositiveY(sp0, sc, A_SAMPLER_2D_INPUT(_PrimaryMainTex), _PrimaryMaterialMap, _PrimaryBumpMap, _PrimaryOcclusion, _PrimaryBumpScale);
        #else
            aTriPlanarY(sp0, sc, A_SAMPLER_2D_INPUT(_PrimaryMainTex), _PrimaryMaterialMap, _PrimaryBumpMap, _PrimaryOcclusion, _PrimaryBumpScale);
        #endif
        #ifndef _SECONDARY_TRIPLANAR_ON	
            aTriPlanarX(sp0, sc, A_SAMPLER_2D_INPUT(_PrimaryMainTex), _PrimaryMaterialMap, _PrimaryBumpMap, _PrimaryOcclusion, _PrimaryBumpScale);

            #ifndef _QUATERNARY_TRIPLANAR_ON
                aTriPlanarZ(sp0, sc, A_SAMPLER_2D_INPUT(_PrimaryMainTex), _PrimaryMaterialMap, _PrimaryBumpMap, _PrimaryOcclusion, _PrimaryBumpScale);
            #endif
        #endif

        aSplatMaterial(sp0, sc, _PrimaryColor, _PrimaryColorVertexTint, _PrimaryMetallic, _PrimarySpecularity, _PrimarySpecularTint, _PrimaryRoughness);
    #endif
    #ifdef _SECONDARY_TRIPLANAR_ON	
        ASplat sp1 = aNewSplat();
        aTriPlanarX(sp1, sc, A_SAMPLER_2D_INPUT(_SecondaryMainTex), _SecondaryMaterialMap, _SecondaryBumpMap, _SecondaryOcclusion, _SecondaryBumpScale);

        #ifndef _TERTIARY_TRIPLANAR_ON
            aTriPlanarNegativeY(sp1, sc, A_SAMPLER_2D_INPUT(_SecondaryMainTex), _SecondaryMaterialMap, _SecondaryBumpMap, _SecondaryOcclusion, _SecondaryBumpScale);
        #endif
        #ifndef _QUATERNARY_TRIPLANAR_ON
            aTriPlanarZ(sp1, sc, A_SAMPLER_2D_INPUT(_SecondaryMainTex), _SecondaryMaterialMap, _SecondaryBumpMap, _SecondaryOcclusion, _SecondaryBumpScale);
        #endif

        aSplatMaterial(sp1, sc, _SecondaryColor, _SecondaryColorVertexTint, _SecondaryMetallic, _SecondarySpecularity, _SecondarySpecularTint, _SecondaryRoughness);
        aMergeSplats(sp0, sp1);
    #endif
    #ifdef _TERTIARY_TRIPLANAR_ON	
        ASplat sp2 = aNewSplat();
        aTriPlanarNegativeY(sp2, sc, A_SAMPLER_2D_INPUT(_TertiaryMainTex), _TertiaryMaterialMap, _TertiaryBumpMap, _TertiaryOcclusion, _TertiaryBumpScale);
        aSplatMaterial(sp2, sc, _TertiaryColor, _TertiaryColorVertexTint, _TertiaryMetallic, _TertiarySpecularity, _TertiarySpecularTint, _TertiaryRoughness);
        aMergeSplats(sp0, sp2);
    #endif
    #ifdef _QUATERNARY_TRIPLANAR_ON
        ASplat sp3 = aNewSplat();
        aTriPlanarZ(sp3, sc, A_SAMPLER_2D_INPUT(_QuaternaryMainTex), _QuaternaryMaterialMap, _QuaternaryBumpMap, _QuaternaryOcclusion, _QuaternaryBumpScale);
        aSplatMaterial(sp3, sc, _QuaternaryColor, _QuaternaryColorVertexTint, _QuaternaryMetallic, _QuaternarySpecularity, _QuaternarySpecularTint, _QuaternaryRoughness);
        aMergeSplats(sp0, sp3);
    #endif

    aApplySplat(s, sp0);
    aCutout(s);
#endif
} 

#endif // ALLOY_SHADERS_FEATURE_TRIPLANAR_CGINC
