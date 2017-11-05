// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Feature.cginc
/// @brief Features uber-header. Holds methods that rely on uniforms.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_FEATURE_CGINC
#define ALLOY_SHADERS_FRAMEWORK_FEATURE_CGINC

// Headers both for this file, and for all Definition and Feature modules.
#include "Assets/Alloy/Shaders/Config.cginc"
#include "Assets/Alloy/Shaders/Framework/Lighting.cginc"
#include "Assets/Alloy/Shaders/Framework/Utility.cginc"

#include "UnityCG.cginc"
#include "UnityStandardUtils.cginc"

/// Picks either UV0 or UV1.
#define A_TEX_UV(s, name) (aPickUv(s, name##UV))

/// Applies Unity texture transforms plus UV0.
#define A_TEX_TRANSFORM(s, name) (TRANSFORM_TEX(s.uv01.xy, name))

/// Applies Unity texture transforms plus UV-switching effect.
#define A_TEX_TRANSFORM_UV(s, name) (TRANSFORM_TEX(A_TEX_UV(s, name), name))

/// Applies Unity texture transforms plus UV-switching and our scrolling effects.
#define A_TEX_TRANSFORM_UV_SCROLL(s, name) (A_TEX_TRANSFORM_SCROLL(name, A_TEX_UV(s, name)))

/// Base UV assignment and update of associated fields.
#define A_BV(s, UV) UV; aUpdateBaseUv(s)

/// Contains accumulated splat material data.
struct ASplat {
    /// Non-TriPlanar transformed base UVs.
    float2 baseUv;

    /// (RGB) Base Color, (A) Opacity.
    /// Expects linear-space LDR color values.
    half4 material0;

    /// (R) Metallic, (G) AO/Specular Tint, (B) Specularity, (A) Roughness.
    /// Expects values in the range [0,1].
    half4 material1;

    /// (RGB) Emission, (A) Specular Tint.
    /// Expects linear-space HDR color values.
    half4 material2;

    /// World, Object, or Tangent normals.
    /// Expects a normalized vector.
    half3 normal;
};

/// Contains shared state for all splat functions, including TriPlanar data.
struct ASplatContext {
    /// Vertex color.
    /// Expects linear-space LDR color values.
    half4 vertexColor;

    /// The model's UV0 & UV1 texture coordinate data.
    /// Be aware that it can have parallax precombined with it.
    float4 uv01;

    /// X-axis TriPlanar tangent to world matrix.
    half3x3 xTangentToWorld;

    /// Y-axis TriPlanar tangent to world matrix.
    half3x3 yTangentToWorld;

    /// Z-axis TriPlanar tangent to world matrix.
    half3x3 zTangentToWorld;

    /// Blend weights between the top, middle, and bottom TriPlanar axis.
    half3 blend;

    /// Position in either world or object-space.
    float3 position;

    /// Binary masks for the positive values in the vertex normals.
    half3 axisMasks;
};

/// Cutoff value that controls where cutout occurs over opacity.
/// Expects values in the range [0,1].
half _Cutoff;

/// Toggles inverting the backface normals.
/// Expects the values 0 or 1.
float _TransInvertBackNormal;

/// The base tint color.
/// Expects a linear LDR color with alpha.
half4 _Color;

/// Base color map.
/// Expects an RGB(A) map with sRGB sampling.
A_SAMPLER_2D(_MainTex);

/// Base packed material map.
/// Expects an RGBA data map.
A_SAMPLER_2D(_SpecTex);

/// Metallic map.
/// Expects an RGB map with sRGB sampling
sampler2D _MetallicMap;

/// Ambient Occlusion map.
/// Expects an RGB map with sRGB sampling
sampler2D _AoMap;

/// Specularity map.
/// Expects an RGB map with sRGB sampling
sampler2D _SpecularityMap;

/// Roughness map.
/// Expects an RGB map with sRGB sampling
sampler2D _RoughnessMap;

/// Base normal map.
/// Expects a compressed normal map.
sampler2D _BumpMap;

/// Height map.
/// Expects an RGBA data map.
sampler2D _ParallaxMap;

/// Toggles tinting the base color by the vertex color.
/// Expects values in the range [0,1].
half _BaseColorVertexTint;

/// The base metallic scale.
/// Expects values in the range [0,1].
half _Metal; 

/// The base specularity scale.
/// Expects values in the range [0,1].
half _Specularity;

// Amount that f0 is tinted by the base color.
/// Expects values in the range [0,1].
half _SpecularTint;

/// The base roughness scale.
/// Expects values in the range [0,1].
half _Roughness;

/// Ambient Occlusion strength.
/// Expects values in the range [0,1].
half _Occlusion;

/// Normal map XY scale.
half _BumpScale;

/// Height scale of the heightmap.
/// Expects values in the range [0,0.08].
float _Parallax;

/// Splat data constructor.
ASplat aNewSplat();

/// Uses surface data to make shared splat data.
/// @param  s               Material surface data.
/// @param  sharpness       Sharpness of the blend between TriPlanar axis.
/// @param  positionScale   Scales the position used for TriPlanar UVs.
/// @return                 Splat context initialized with shared data.
ASplatContext aNewSplatContext(ASurface s, half sharpness, float positionScale);

/// Converts splat to material data and assigns it to a surface.
/// @param[in,out]  s   Material surface data.
/// @param[in]      sp  Combined splat data.
void aApplySplat(inout ASurface s, ASplat sp);

/// Uses mask to blend a splat into surface.
/// @param[in,out]  s       Material surface data.
/// @param[in]      sp      Combined splat data.
void aBlendSplat(inout ASurface s, ASplat sp);

/// Uses splat opacity and mask to blend a splat into surface.
/// @param[in,out]  s       Material surface data.
/// @param[in]      sp      Combined splat data.
void aBlendSplatWithOpacity(inout ASurface s, ASplat sp);

/// Combines two splats into one, accumulating into first splat.
/// @param[in,out]  sp0 Target for combined splat data ouput.
/// @param[in]      sp1 Second splat to be combined.
void aMergeSplats(inout ASplat sp0, ASplat sp1);

/// Applies constant material data to a splat.
/// @param[in,out]  sp              Splat being modified.
/// @param[in]      sc              Splat context.
/// @param[in]      tint            Base color tint.
/// @param[in]      vertexTint      Base color vertex color tint weight.
/// @param[in]      metallic        Metallic  weight.
/// @param[in]      specularity     Specularity.
/// @param[in]      specularTint    Specular tint weight.
/// @param[in]      roughness       Linear roughness.
void aSplatMaterial(inout ASplat sp, ASplatContext sc, half4 tint, half vertexTint, half metallic, half specularity, half specularTint, half roughness);

/// TriPlanar axis applied to a splat.
/// @param[in,out]  sp          Splat being modified.
/// @param[in]      mask        Masks where the effect is applied.
/// @param[in]      tbn         Local normal tangent to world matrix.
/// @param[in]      uv          Texture coordinates.
/// @param[in]      occlusion   Occlusion map weight.
/// @param[in]      bumpScale   Normal map XY scale.
/// @param[in]      base        Base color map.
/// @param[in]      material    Material map.
/// @param[in]      normal      Normal map.
void aTriPlanarAxis(inout ASplat sp, half mask, half3x3 tbn, float2 uv, half occlusion, half bumpScale, sampler2D base, sampler2D material, sampler2D normal);

/// X-axis triplanar material applied to a splat.
/// @param[in,out]  sp          Splat being modified.
/// @param[in]      sc          Splat context.
/// @param[in]      base        Base color map.
/// @param[in]      material    Material map.
/// @param[in]      normal      Normal map.
/// @param[in]      occlusion   Occlusion map weight.
/// @param[in]      bumpScale   Normal map XY scale.
void aTriPlanarX(inout ASplat sp, ASplatContext sc, A_SAMPLER_PARAM(base), sampler2D material, sampler2D normal, half occlusion, half bumpScale);

/// Y-axis triplanar material applied to a splat.
/// @param[in,out]  sp          Splat being modified.
/// @param[in]      sc          Splat context.
/// @param[in]      base        Base color map.
/// @param[in]      material    Material map.
/// @param[in]      normal      Normal map.
/// @param[in]      occlusion   Occlusion map weight.
/// @param[in]      bumpScale   Normal map XY scale.
void aTriPlanarY(inout ASplat sp, ASplatContext sc, A_SAMPLER_PARAM(base), sampler2D material, sampler2D normal, half occlusion, half bumpScale);

/// Z-axis triplanar material applied to a splat.
/// @param[in,out]  sp          Splat being modified.
/// @param[in]      sc          Splat context.
/// @param[in]      base        Base color map.
/// @param[in]      material    Material map.
/// @param[in]      normal      Normal map.
/// @param[in]      occlusion   Occlusion map weight.
/// @param[in]      bumpScale   Normal map XY scale.
void aTriPlanarZ(inout ASplat sp, ASplatContext sc, A_SAMPLER_PARAM(base), sampler2D material, sampler2D normal, half occlusion, half bumpScale);

/// Positive Y-axis triplanar material applied to a splat.
/// @param[in,out]  sp          Splat being modified.
/// @param[in]      sc          Splat context.
/// @param[in]      base        Base color map.
/// @param[in]      material    Material map.
/// @param[in]      normal      Normal map.
/// @param[in]      occlusion   Occlusion map weight.
/// @param[in]      bumpScale   Normal map XY scale.
void aTriPlanarPositiveY(inout ASplat sp, ASplatContext sc, A_SAMPLER_PARAM(base), sampler2D material, sampler2D normal, half occlusion, half bumpScale);

/// Negative Y-axis triplanar material applied to a splat.
/// @param[in,out]  sp          Splat being modified.
/// @param[in]      sc          Splat context.
/// @param[in]      base        Base color map.
/// @param[in]      material    Material map.
/// @param[in]      normal      Normal map.
/// @param[in]      occlusion   Occlusion map weight.
/// @param[in]      bumpScale   Normal map XY scale.
void aTriPlanarNegativeY(inout ASplat sp, ASplatContext sc, A_SAMPLER_PARAM(base), sampler2D material, sampler2D normal, half occlusion, half bumpScale);

/// Applies constant material data to a splat.
/// @param  sc              Splat context.
/// @param  base            Base color map.
/// @param  material        Material map.
/// @param  normal          Normal map.
/// @param  tint            Base color tint.
/// @param  vertexTint      Base vertex color tint.
/// @param  metallic        Metallic  weight.
/// @param  specularity     Specularity.
/// @param  specularTint    Specular tint weight.
/// @param  roughness       Linear roughness.
/// @param  occlusion       Occlusion map weight.
/// @param  bumpScale       Normal map XY scale.
/// @return                 Splat populated with terrain data.
ASplat aNewSplat(ASplatContext sc, A_SAMPLER_PARAM(base), sampler2D material, sampler2D normal, half4 tint, half vertexTint, half metallic, half specularity, half specularTint, half roughness, half occlusion, half bumpScale);

/// Combine splats and convert to material data to assign to a surface.
/// @param[in,out]  s       Material surface data.
/// @param[in]      weights Weights masking where splats are combined.
/// @param[in]      sp0     Splat data.
/// @param[in]      sp1     Splat data.
/// @param[in]      sp2     Splat data.
void aApplyTerrainSplats(inout ASurface s, half3 weights, ASplat sp0, ASplat sp1, ASplat sp2);

/// Combine splats and convert to material data to assign to a surface.
/// @param[in,out]  s       Material surface data.
/// @param[in]      weights Weights masking where splats are combined.
/// @param[in]      sp0     Splat data.
/// @param[in]      sp1     Splat data.
/// @param[in]      sp2     Splat data.
/// @param[in]      sp3     Splat data.
void aApplyTerrainSplats(inout ASurface s, half4 weights, ASplat sp0, ASplat sp1, ASplat sp2, ASplat sp3);

/// Converts AO to linear space and controls the strength of the effect.
/// @param  ao      Gamma-space LDR AO value.
/// @param  weight  Strength of the AO effect.
/// @return         Weighted, linear-space AO value.
half aOcclusionStrength(half ao, half weight);

/// Sets up base UV for the first time.
/// @param[in,out] s Material surface data.
void aBaseUvInit(inout ASurface s);

/// Update values dependent on base UV.
void aUpdateBaseUv(inout ASurface s);

/// Pick between UV0 & UV1.
float2 aPickUv(ASurface s, float nameUv);

/// Pick between UV0 & UV1.
float2 aPickUv(ASplatContext sc, float nameUv);

/// Sets whether backface normals are inverted.
/// @param[in,out] s Material surface data.
void aTwoSided(inout ASurface s);

/// Applies cutout effect.
/// @param s Material surface data.
void aCutout(ASurface s);

/// Samples the base color map.
/// @param  s   Material surface data.
/// @return     Base Color with alpha.
half4 aSampleBase(ASurface s);

/// Samples the base material map.
/// @param  s   Material surface data.
/// @return     Packed material.
half4 aSampleMaterial(ASurface s);

/// Samples  and scales the base bump map.
/// @param  s       Material surface data.
/// @param  scale   Normal XY scale factor.
/// @return         Normalized tangent-space normal.
half3 aSampleBumpScale(ASurface s, half scale);

/// Samples the base bump map.
/// @param  s   Material surface data.
/// @return     Normalized tangent-space normal.
half3 aSampleBump(ASurface s);

/// Samples the base bump map biasing the mipmap level sampled.
/// @param  s       Material surface data.
/// @param  bias    Mipmap level bias.
/// @return         Normalized tangent-space normal.
half3 aSampleBumpBias(ASurface s, float bias);

/// Samples the base bump map biasing the mipmap level sampled.
/// @param  s   Material surface data.
/// @return     Normalized tangent-space normal.
half aSampleHeight(ASurface s);

/// Applies color based on weight parameter.
/// @param  s           Material surface data.
/// @param  strength    Amount to blend in vertex color.
/// @return             Vertex color tint.
half3 aVertexColorTint(ASurface s, half strength);

/// Applies base vertex color.
/// @param  s   Material surface data.
/// @return     Vertex color tint.
half3 aBaseVertexColorTint(ASurface s);

/// Gets combined base color tint from uniform and vertex color.
/// @param  s   Material surface data.
/// @return     Base Color with alpha.
half4 aBaseTint(ASurface s);

/// Gets combined base color from main channels.
/// @param  s   Material surface data.
/// @return     Base Color with alpha.
half4 aBase(ASurface s);

/// Applies texture coordinate offsets to surface data.
/// @param[in,out]  s       Material surface data.
/// @param[in]      offset  Texture coordinate offset.
void aParallaxOffset(inout ASurface s, float2 offset);

/// Calculates Offset Bump Mapping texture offsets.
/// @param[in,out]  s   Material surface data.
void aOffsetBumpMapping(inout ASurface s);

/// Calculates Parallax Occlusion Mapping texture offsets.
/// @param[in,out]  s           Material surface data.
/// @param[in]      minSamples  Minimum number of samples for POM effect [1,n].
/// @param[in]      maxSamples  Maximum number of samples for POM effect [1,n].
void aParallaxOcclusionMapping(inout ASurface s, float minSamples, float maxSamples);

#endif // ALLOY_SHADERS_FRAMEWORK_FEATURE_CGINC
