// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Lighting.cginc
/// @brief Lighting uber-header.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_LIGHTING_CGINC
#define ALLOY_SHADERS_FRAMEWORK_LIGHTING_CGINC

// Headers both for this file, and for all Definition and Feature modules.
#include "Assets/Alloy/Shaders/Framework/Utility.cginc"

#include "UnityLightingCommon.cginc"

#ifndef A_SURFACE_CUSTOM_FIELDS
    #define A_SURFACE_CUSTOM_FIELDS
#endif

/// Tangent-space normal assignment and update of associated fields.
#define A_NT(s, n) n; aUpdateNormalTangent(s) 

/// World-space normal assignment and update of associated fields.
#define A_NW(s, n) n; aUpdateNormalWorld(s) 

/// Subsurface assignment and update of associated fields.
#define A_SS(s, ss) ss; aUpdateSubsurface(s) 

/// Subsurface color assignment and update of associated fields.
#define A_SSC(s, ssc) ssc; aUpdateSubsurfaceColor(s) 

// Use Unity's struct directly to avoid copying since the fields are the same.
#define AIndirect UnityIndirect

/// Collection of direct illumination data.
struct ADirect {
    /////////////////////////////////////////////////////////////////////////////
    // Material lighting.
    /////////////////////////////////////////////////////////////////////////////

    /// Light color, attenuation, and cookies.
    /// Expects linear-space HDR color values.
    half3 color;
        
    /// Shadowing.
    /// Expects values in the range [0,1].
    half shadow;
    
    /// Specular highlight intensity.
    /// Expects values in the range [0,n].
    half specularIntensity;

    /// Light direction in world-space.
    /// Expects normalized vectors.
    half3 direction;
    
    /// Direction halfway between the light and view vectors in world space.
    /// Expects normalized vectors.
    half3 halfAngleWorld;

    /// Clamped L.H.
    /// Expects values in the range [0,1].
    half LdotH;

    /// Clamped N.H.
    /// Expects values in the range [0,1].
    half NdotH;

    /// Clamped N.L.
    /// Expects values in the range [0,1].
    half NdotL;

    /// Unclamped N.L.
    /// Expects values in the range [0,1].
    half NdotLm;


    /////////////////////////////////////////////////////////////////////////////
    // Internal.
    /////////////////////////////////////////////////////////////////////////////

    /// Diffuse area light vector.
    /// Expects a non-normalized vector.
    float3 Ldiff;

    /// Specular area light vector.
    /// Expects a non-normalized vector.
    float3 Lspec;

    /// One over the distance to the center of the light volume.
    /// Expects values in the range [0,n).
    half centerDistInverse;
};

/// Contains ALL data and state for rendering a surface.
/// Can set state to control how features are combined into the surface data.
struct ASurface {
    /////////////////////////////////////////////////////////////////////////////
    // Vertex inputs.
    /////////////////////////////////////////////////////////////////////////////

    /// Screen-space position.
    float4 screenPosition;
    
    /// Screen-space texture coordinates.
    float2 screenUv;

    /// Position in world space.
    float3 positionWorld;

    /// View direction in world space.
    /// Expects a normalized vector.
    half3 viewDirWorld;

    /// Distance from the camera to the given fragement.
    /// Expects values in the range [0,n].
    half viewDepth;

    /// Unity's fog data.
    float fogCoord;
        
    /// Tangent space to World space rotation matrix.
    half3x3 tangentToWorld;
        
    /// View direction in tangent space.
    /// Expects a normalized vector.
    half3 viewDirTangent;
    
    /// Vertex color.
    /// Expects linear-space LDR color values.
    half4 vertexColor;

    /// Vertex normal in world space.
    /// Expects normalized vectors.
    half3 vertexNormalWorld;

    /// Indicates via sign whether a triangle is front or back facing.
    /// Positive is front-facing, negative is back-facing. 
    half facingSign;


    /////////////////////////////////////////////////////////////////////////////
    // Feature layering inputs.
    /////////////////////////////////////////////////////////////////////////////
    
    /// Masks where the next feature layer will be applied.
    /// Expects values in the range [0,1].
    half mask;
        
    /// The base map's texture transform tiling amount.
    float2 baseTiling;
        
    /// Transformed texture coordinates for the base map.
    float2 baseUv;

#ifdef _VIRTUALTEXTURING_ON
    /// Transformed texture coordinates for the virtual base map.
    VirtualCoord baseVirtualCoord;
#endif

    /// The model's UV0 & UV1 texture coordinate data.
    /// Be aware that it can have parallax precombined with it.
    float4 uv01;


    /////////////////////////////////////////////////////////////////////////////
    // Surface inputs.
    /////////////////////////////////////////////////////////////////////////////

    /// Albedo and/or Metallic f0 based on settings. Used by Enlighten.
    /// Expects linear-space LDR color values.
    half3 baseColor;

    /// Controls opacity or cutout regions.
    /// Expects values in the range [0,1].
    half opacity;

    /// Interpolates material from dielectric to metal.
    /// Expects values in the range [0,1].
    half metallic;

    /// Diffuse ambient occlusion.
    /// Expects values in the range [0,1].
    half ambientOcclusion;

    /// Linear control of dielectric f0 from [0.00,0.08].
    /// Expects values in the range [0,1].
    half specularity;

    /// Tints the dielectric specularity by the base color chromaticity.
    /// Expects values in the range [0,1].
    half specularTint;

    /// Linear roughness value, where zero is smooth and one is rough.
    /// Expects values in the range [0,1].
    half roughness;

    /// Light emission by the material.
    /// Expects linear-space HDR color values.
    half3 emissiveColor;

    /// Color tint for transmission effect.
    /// Expects linear-space LDR color values.
    half3 subsurfaceColor;

    /// Monochrome transmission thickness.
    /// Expects gamma-space LDR values.
    half subsurface;

    /// Strength of clearcoat layer, used to apply masks.
    /// Expects values in the range [0,1].
    half clearCoat;

    /// Roughness of clearcoat layer.
    /// Expects values in the range [0,1].
    half clearCoatRoughness;

    /// Normal in world space.
    /// Expects a normalized vector.
    half3 normalWorld;

    /// Normal in tangent space.
    /// Expects a normalized vector.
    half3 normalTangent;

    /// Blurred normal in tangent space.
    /// Expects a normalized vector.
    half3 blurredNormalTangent;


    /////////////////////////////////////////////////////////////////////////////
    // BRDF inputs.
    /////////////////////////////////////////////////////////////////////////////
    
    /// Diffuse albedo.
    /// Expects linear-space LDR color values.
    half3 albedo;

    /// Fresnel reflectance at incidence zero.
    /// Expects linear-space LDR color values.
    half3 f0;

    /// Beckmann roughness.
    /// Expects values in the range [0,1].
    half beckmannRoughness;

    /// Specular occlusion.
    /// Expects values in the range [0,1].
    half specularOcclusion;

    /// Ambient diffuse normal in world space.
    /// Expects normalized vectors.
    half3 ambientNormalWorld;

    /// View reflection vector in world space.
    /// Expects a non-normalized vector.
    half3 reflectionVectorWorld;

    /// Clamped N.V.
    /// Expects values in the range [0,1].
    half NdotV;

    /// Fresnel weight of N.V.
    /// Expects values in the range [0,1].
    half FV;

    /// Deferred material lighting type.
    /// Expects the values 0, 1/3, 2/3, or 1.
    half materialType;

    A_SURFACE_CUSTOM_FIELDS

    half _skinScatteringMask;
    half _skinScattering;
    half _subsurfaceShadowWeight;
};

/// Maximum linear-space non-metal specular reflectivity.
static const half A_MAX_DIELECTRIC_F0 = 0.08h;

/// Minimum roughness that won't cause specular artifacts.
static const half A_MIN_AREA_ROUGHNESS = 0.05h;

/// Front-faces cull mode.
static const half A_CULL_MODE_FRONT = 1.0h;

/// Opaque shading type.
static const half A_MATERIAL_TYPE_OPAQUE = 1.0h;

/// Shadowed subsurface transmission shading type.
static const half A_MATERIAL_TYPE_SHADOWED_SUBSURFACE = 2.0h / 3.0h;

/// Unshadowed subsurface transmission shading type.
static const half A_MATERIAL_TYPE_UNSHADOWED_SUBSURFACE = 1.0h / 3.0h;

/// Subsurface scattering shading type.
static const half A_MATERIAL_TYPE_SUBSURFACE_SCATTERING = 0.0h;

#ifdef A_DEFERRED_PASS
    /// RGB=Blurred normals, A=Subsurface thickness.
    /// Expects value in the buffer alpha.
    sampler2D _DeferredPlusBuffer;
#endif

#ifdef A_FORWARD_ONLY_SHADER
    /// Pre-Integrated scattering LUT.
    sampler2D _SssBrdfTex;

    /// Weight of the scattering effect.
    /// Expects values in the range [0,1].
    half _SssWeight;

    /// Cutoff value used to convert tranmission data to scattering mask.
    /// Expects values in the range [0.01,1].
    half _SssMaskCutoff;

    /// Biases the thickness value used to look up in the skin LUT.
    /// Expects values in the range [0,1].
    half _SssBias;

    /// Scales the thickness value used to look up in the skin LUT.
    /// Expects values in the range [0,1].
    half _SssScale;

    /// Increases the bluriness of the normal map for diffuse lighting.
    /// Expects values in the range [0,1].
    half _SssBumpBlur;

    /// Per-channel weights for thickness-based subsurface color absorption.
    half3 _SssTransmissionAbsorption;

    /// Per-channel RGB gamma weights for colored AO.
    /// Expects a vector of non-zero values.
    half3 _SssColorBleedAoWeights;

    /// Weight of the subsurface effect.
    /// Expects linear-space values in the range [0,1].
    half _TransWeight;
#else
    /// Pre-Integrated scattering LUT.
    sampler2D _DeferredSkinLut;

    /// X=Scattering Weight, Y=1/Mask Cutoff, Z=Blur Weight.
    /// Expects a vector of non-zero values.
    half3 _DeferredSkinParams;

    /// Per-channel weights for thickness-based subsurface color absorption.
    /// LUT Bias in alpha.
    half4 _DeferredSkinTransmissionAbsorption;

    /// Per-channel RGB gamma weights for colored AO. LUT Scale in alpha.
    /// Expects a vector of non-zero values.
    half4 _DeferredSkinColorBleedAoWeights;
#endif

/// The current culling mode for transmission shadows.
float _ShadowCullMode;

#ifdef A_FORWARD_ONLY_SHADER
    /// Shadow influence on the subsurface effect.
    /// Expects values in the range [0,1].
    half _TransShadowWeight;

    /// Amount that the subsurface is distorted by surface normals.
    /// Expects values in the range [0,1].
    half _TransDistortion;

    /// Falloff of the subsurface effect.
    /// Expects values in the range [1,n).
    half _TransPower;
#else
    /// X=Linear Weight, Y=Falloff, Z=Bump Distortion, W=Shadow Weight.
    /// Expects a vector of non-zero values.
    half4 _DeferredTransmissionParams;
#endif

/// Abstract declaration for user-defined pre-lighting callback.
void aPreLighting(inout ASurface s);

/// Abstract declaration for user-defined direct lighting callback.
half3 aDirectLighting(ADirect d, ASurface s);

/// Abstract declaration for user-defined indirect lighting callback.
half3 aIndirectLighting(AIndirect i, ASurface s);

/// Indirect lighting data constructor. 
AIndirect aNewIndirect();

/// Direct lighting data constructor. 
ADirect aNewDirect();

/// Applies light cookie to description.
/// @param[in,out]  d       Direct lighting data.
/// @param[in]      cookie  Cookie map sample.
void aLightCookie(inout ADirect d, half4 cookie);

/// Light range limit falloff.
/// @param[in,out]  d       Direct lighting data.
/// @param[in]      range   Light volume radius.
void aSetLightRangeLimit(inout ADirect d, half range);

/// Populates light with brdf dot products, except N.L.
/// @param[in,out]  d Direct lighting data.
/// @param[in]      s Material surface data.
void aUpdateLightingInputs(inout ADirect d, ASurface s);

/// Populates specular lighting data for an area light.
/// @param[in,out]  d       Direct lighting data.
/// @param[in]      s       Material surface data.
/// @param[in]      radius  Area light radius.
void aSetAreaSpecularInputs(inout ADirect d, ASurface s, half radius);

/// Populates material lighting data for an area light.
/// @param[in,out]  d       Direct lighting data.
/// @param[in]      s       Material surface data.
/// @param[in]      radius  Area light radius.
/// @return                 One over area diffuse light vector length.
half aSetAreaLightingInputs(inout ADirect d, ASurface s, half radius);

/// Populates data for a directional light.
/// @param[in,out]  d Direct lighting data.
/// @param[in]      s Material surface data.
void aDirectionalLight(inout ADirect d, ASurface s);

/// Populates data for a directional light.
/// @param[in,out]  d           Direct lighting data.
/// @param[in]      s           Material surface data.
/// @param[in]      direction   Light normalized direction.
/// @param[in]      radius      Disc light radius.
void aDirectionalDiscLight(inout ADirect d, ASurface s, half3 direction, half radius);

/// Populates data for a sphere area light.
/// @param[in,out]  d       Direct lighting data.
/// @param[in]      s       Material surface data.
/// @param[in]      L       Vector to light center.
/// @param[in]      radius  Sphere light radius.
void aSphereLight(inout ADirect d, ASurface s, float3 L, half radius);

/// Populates data for a sphere area light.
/// @param[in,out]  d           Direct lighting data.
/// @param[in]      s           Material surface data.
/// @param[in]      L           Vector to light center.
/// @param[in]      axis        Tube light normalized axis direction.
/// @param[in]      radius      Tube light radius.
/// @param[in]      halfLength  Half the length of the tube light.
void aTubeLight(inout ADirect d, ASurface s, float3 L, half3 axis, half radius, half halfLength);

/// Populates data for an area light.
/// @param[in,out]  d       Direct lighting data.
/// @param[in]      s       Material surface data.
/// @param[in]      color   Light color, size weight in alpha. +/- sign.
/// @param[in]      axis    Tube light normalized axis direction.
/// @param[in]      L       Vector to light center.
/// @param[in]      range   Light bounding volume range.
void aAreaLight(inout ADirect d, ASurface s, half4 color, half3 axis, float3 L, half range);

/// Surface data constructor. 
ASurface aNewSurface();

/// Sets the feature mask by using a gradient input mask.
/// @param[in,out]  s           Material surface data.
/// @param[in]      mask        Gradient where effect goes from black to white.
/// @param[in]      weight      Weight of the effect.
/// @param[in]      cutoff      Value below which the gradient becomes a mask.
/// @param[in]      blendRange  Range of smooth blend above cutoff.
/// @param[in]      vertexTint  Weight of vertex color alpha cutoff override.
void aBlendRangeMask(inout ASurface s, half mask, half weight, half cutoff, half blendRange, half vertexTint);

/// Transforms a normal from tangent-space to world-space.
half3 aTangentToWorld(ASurface s, half3 normalTangent);

/// Transforms a normal from world-space to tangent-space.
half3 aWorldToTangent(ASurface s, half3 normalWorld);

/// Calculates and sets normal and view-dependent data.
void aUpdateViewData(inout ASurface s);

/// Update values dependent on tangent-space normal.
void aUpdateNormalTangent(inout ASurface s);

/// Update values dependent on world-space normal.
void aUpdateNormalWorld(inout ASurface s);

/// Update values dependent on subsurface.
void aUpdateSubsurface(inout ASurface s);

/// Update values dependent on subsurface color.
void aUpdateSubsurfaceColor(inout ASurface s);

/// Calculates the fresnel at incidence zero from a normalized specularity.
/// @param  specularity Normalized specularity [0,1].
/// @return             F0 [0,0.08].
half3 aSpecularityToF0(half specularity);

/// Convert linear roughness to Beckmann roughness.
/// @param  roughness   Linear roughness [0,1].
/// @return             Beckmann Roughness.
half aLinearToBeckmannRoughness(half roughness);

/// Blend weight portion of Schlick fresnel equation.
/// @param  w   Clamped dot product of two normalized vectors.
/// @return     Fresnel blend weight.
half aFresnel(half w);

/// Switches off specular lighting per-pixel where surface f0 is black.
half3 aSpecularLightingToggle(ASurface s, half3 specular);

/// Calculates specular occlusion.
/// @param  ao      Linear ambient occlusion.
/// @param  NdotV   Normal and eye vector dot product [0,1].
/// @return         Specular occlusion.
half aSpecularOcclusion(half ao, half NdotV);

/// Pre-calculate material data shared between direct & indirect lighting.
void aStandardPreLighting(inout ASurface s);

/// Calculate direct illumination from a light and a surface.
/// @param  d   Direct lighting data.
/// @param  s   Material surface data.
/// @return     Direct illumination.
half3 aStandardDirectLighting(ADirect d, ASurface s);

/// Calculate indirect illumination from a light and a surface.
/// @param  i   Indirect lighting data.
/// @param  s   Material surface data.
/// @return     Indirect illumination.
half3 aStandardIndirectLighting(AIndirect i, ASurface s);

#endif // ALLOY_SHADERS_FRAMEWORK_LIGHTING_CGINC
