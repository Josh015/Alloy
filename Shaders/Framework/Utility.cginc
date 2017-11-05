// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Utility.cginc
/// @brief Minimum functions and constants common to surfaces and particles.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_UTILITY_CGINC
#define ALLOY_SHADERS_FRAMEWORK_UTILITY_CGINC

#include "Assets/Alloy/Shaders/Config.cginc"

#include "UnityShaderVariables.cginc"

/// Defines all texture transform uniform variables, inlcuding additional transforms.
/// Spin is in radians.
#define A_SAMPLER_2D(name) \
    sampler2D name; \
    float4 name##_ST; \
    float2 name##Velocity; \
    float name##Spin; \
    float name##UV;

/// Allows passing all of a texture's transform uniforms into a function.
#define A_SAMPLER_2D_INPUT(name) name, name##_ST, name##Velocity, name##UV

/// Allows accessing all of a texture's transform uniforms inside a function.
#define A_SAMPLER_PARAM(name) sampler2D name, float4 name##_ST, float2 name##Velocity, float name##UV

// NOTE: To make it rotate around a "center" point, the order of operations
// needs to be offset, rotate, scale. So that means that we have to apply 
// offset & scroll first divided by tiling. Then when we apply tiling later 
// it will cancel.

/// Applies our scrolling effect.
#ifdef A_TEX_SCROLL_OFF
    #define A_TEX_SCROLL(name, tex) (tex)
#else
    #define A_TEX_SCROLL(name, tex) (tex + ((name##Velocity * _Time.y + name##_ST.zw) / name##_ST.xy))
#endif

/// Applies our spinning effect.
#define A_TEX_SPIN(name, tex) (aRotateTextureCoordinates(name##Spin * _Time.y, tex.xy))

/// Applies Unity texture transforms plus our spinning effect. 
#define A_TEX_TRANSFORM_SPIN(name, tex) (A_TEX_SPIN(name, tex + (name##_ST.zw / name##_ST.xy)) * name##_ST.xy)

/// Applies Unity texture transforms plus our spinning and scrolling effects.
#define A_TEX_TRANSFORM_SCROLL(name, tex) (A_TEX_SCROLL(name, tex) * name##_ST.xy)

/// Applies Unity texture transforms plus our spinning and scrolling effects.
#define A_TEX_TRANSFORM_SCROLL_SPIN(name, tex) (A_TEX_SPIN(name, A_TEX_SCROLL(name, tex)) * name##_ST.xy)

/// A value close to zero.
/// This is used for preventing NaNs in cases where you can divide by zero.
static const float A_EPSILON = 1e-6f;

/// Multi-component zero.
static const half3 A_ZERO = half3(0.0h, 0.0h, 0.0h);

/// Multi-component zero.
static const half4 A_ZERO4 = half4(0.0h, 0.0h, 0.0h, 0.0h);

/// Multi-component one.
static const half3 A_ONE = half3(1.0h, 1.0h, 1.0h);

/// Multi-component one.
static const half4 A_ONE4 = half4(1.0h, 1.0h, 1.0h, 1.0h);

/// Color Black.
static const half3 A_BLACK = A_ZERO;

/// Multi-component zero.
static const half4 A_BLACK4 = A_ZERO4;

/// Color White.
static const half3 A_WHITE = A_ONE;

/// Multi-component one.
static const half4 A_WHITE4 = A_ONE4;

/// X-Axis normal.
static const half3 A_AXIS_X = half3(1.0h, 0.0h, 0.0h);

/// Y-Axis normal.
static const half3 A_AXIS_Y = half3(0.0h, 1.0h, 0.0h);

/// Z-Axis normal.
static const half3 A_AXIS_Z = half3(0.0h, 0.0h, 1.0h);

/// Flat normal in tangent space.
static const half3 A_FLAT_NORMAL = A_AXIS_Z;

/// Applies 2D texture rotation around the point (0.5,0.5) in UV-space.
/// @param  rotation    Rotation in radians.
/// @param  texcoords   Texture coordinates to be rotated.
/// @return             Rotated texture coordinates.
float2 aRotateTextureCoordinates(
    float rotation,
    float2 texcoords)
{
    // Texture Rotation
    // cf http://forum.unity3d.com/threads/rotation-of-texture-uvs-directly-from-a-shader.150482/#post-1031763 
    float2 centerOffset = float2(0.5f, 0.5f);
    float sinTheta = sin(rotation);
    float cosTheta = cos(rotation);
    float2x2 rotationMatrix = float2x2(cosTheta, -sinTheta, sinTheta, cosTheta);
    return mul(texcoords - centerOffset, rotationMatrix) + centerOffset;
}

/// Dot product of two vectors, clamped to range [0,1].
half aDotClamp(
    half2 x,
    half2 y)
{
    return saturate(dot(x, y));
}

/// Dot product of two vectors, clamped to range [0,1].
half aDotClamp(
    half3 x,
    half3 y)
{
    return saturate(dot(x, y));
}

/// Dot product of two vectors, clamped to range [0,1].
half aDotClamp(
    half4 x,
    half4 y)
{
    return saturate(dot(x, y));
}

/// Screen Blends two colors.
half3 aScreenBlend(
    half3 a,
    half3 b)
{
    return A_ONE - ((A_ONE - a) * (A_ONE - b));
}

/// Converts an LDR color from gamma-space to linear-space.
half3 aGammaToLinear(
    half3 sRGB)
{
    // sRGB curve approximation.
    // cf http://chilliant.blogspot.com.au/2012/08/srgb-approximations-for-hlsl.html?m=1
    return sRGB * (sRGB * (sRGB * 0.305306011h + 0.682171111h) + 0.012522878h);
}

/// Converts an LDR value from gamma-space to linear-space.
half aGammaToLinear(
    half sRGB)
{
    return aGammaToLinear(sRGB.rrr).r;
}

/// Interpolate from one to another value.
half aLerpOneTo(
    half b,
    half alpha)
{
    // Use lerp intrinsic for better optimization.
    return lerp(1.0h, b, alpha); 
}

/// Interpolate from the color white to another color.
half3 aLerpWhiteTo(
    half3 b,
    half alpha)
{
    // Use lerp intrinsic for better optimization.
    return lerp(A_WHITE, b, alpha);
}

/// Calculates a linear color's luminance.
/// @param  color   Linear LDR color.
/// @return         Color's chromaticity.
half aLuminance(
    half3 color)
{
    // Linear-space luminance coefficients.
    // cf https://en.wikipedia.org/wiki/Luma_(video)
    return dot(color, half3(0.2126h, 0.7152h, 0.0722h));
}

/// Calculates a linear color's chromaticity.
/// @param  color   Linear LDR color.
/// @return         Color's chromaticity.
half3 aChromaticity(
    half3 color)
{
    return color / max(aLuminance(color), A_EPSILON).rrr;
}

/// Clamp HDR output to avoid excess bloom and blending errors.
/// @param  value   Linear HDR value.
/// @return         Range-limited HDR color [0,32].
half aHdrClamp(
    half value)
{
#if A_USE_HDR_CLAMP
    value = min(value, A_HDR_CLAMP_MAX_INTENSITY);
#endif
    return value;
}

/// Clamp HDR output to avoid excess bloom and blending errors.
/// @param  color   Linear HDR color.
/// @return         Range-limited HDR color [0,32].
half3 aHdrClamp(
    half3 color)
{
#if A_USE_HDR_CLAMP
    color = min(color, (A_HDR_CLAMP_MAX_INTENSITY).rrr);
#endif
    return color;
}

/// Clamp HDR output to avoid excess bloom and blending errors.
/// @param  color   Linear HDR color.
/// @return         Range-limited HDR color [0,32].
half4 aHdrClamp(
    half4 color)
{
#if A_USE_HDR_CLAMP
    color = min(color, (A_HDR_CLAMP_MAX_INTENSITY).rrrr);
#endif
    return color;
}

/// Used to calculate a rim light effect.
/// @param  weight  Scales the intensity of the effect.
/// @param  bias    Bias rim towards constant emission.
/// @param  power   Rim falloff.
/// @param  NdotV   Normal and view vector dot product.
/// @return         Rim lighting.
half aRimLight(
    half weight,
    half bias, 
    half power, 
    half NdotV) 
{
    return weight * lerp(bias, 1.0h, pow(1.0h - NdotV, power));
}

/// Gets distance from a point to an Axis-Aligned Bounding Box.
/// @param  p       Starting point.
/// @param  aabbMin AABB min extents.
/// @param  aabbMax AABB max extents.
/// @return         Per-axis distance from AABB extents.
half3 aDistanceFromAabb(
    half3 p,
    half3 aabbMin,
    half3 aabbMax)
{
    return max(max(p - aabbMax, aabbMin - p), half3(0.0h, 0.0h, 0.0h));
}

/// Applies four closest lights per-vertex using Alloy's attenuation.
/// @param  lightPosX       Four lights' position X in world-space.
/// @param  lightPosY       Four lights' position Y in world-space.
/// @param  lightPosZ       Four lights' position Z in world-space.
/// @param  lightColor0     First light color.
/// @param  lightColor1     Second light color.
/// @param  lightColor2     Third light color.
/// @param  lightColor3     Fourth light color.
/// @param  lightAttenSq    Four lights' Unity attenuation.
/// @param  positionWorld   Position in world-space.
/// @param  normalWorld     Normal in world-space.
/// @return                 Per-vertex direct lighting.
float3 aShade4PointLights(
    float4 lightPosX, 
    float4 lightPosY, 
    float4 lightPosZ,
    float3 lightColor0, 
    float3 lightColor1, 
    float3 lightColor2, 
    float3 lightColor3,
    float4 lightAttenSq,
    float3 positionWorld,
    float3 normalWorld)
{
    // to light vectors
    float4 toLightX = lightPosX - positionWorld.x;
    float4 toLightY = lightPosY - positionWorld.y;
    float4 toLightZ = lightPosZ - positionWorld.z;

    // squared lengths
    float4 lengthSq = 0;
    lengthSq += toLightX * toLightX;
    lengthSq += toLightY * toLightY;
    lengthSq += toLightZ * toLightZ;

    // NdotL
    float4 ndotl = 0;
    ndotl += toLightX * normalWorld.x;
    ndotl += toLightY * normalWorld.y;
    ndotl += toLightZ * normalWorld.z;

    // correct NdotL
    float4 corr = rsqrt(lengthSq);
    ndotl = max (float4(0.0f, 0.0f, 0.0f, 0.0f), ndotl * corr);

    // attenuation
#if A_USE_UNITY_ATTENUATION
    float4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
#else
    // NOTE: Get something close to Alloy attenuation by undoing Unity's calculations.
    // http://forum.unity3d.com/threads/easiest-way-to-change-point-light-attenuation-with-deferred-path.254337/#post-1681835
    float4 invRangeSqr = lightAttenSq / 25.0f;
    
    // Inverse Square attenuation, with light range falloff.
    // cf http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf p12
    float4 ratio2 = lengthSq * invRangeSqr;
    float4 num = saturate(float4(1.0f, 1.0f, 1.0f, 1.0f) - (ratio2 * ratio2));
    float4 atten = (num * num) / (lengthSq + float4(1.0f, 1.0f, 1.0f, 1.0f));
#endif
    
    float4 diff = ndotl * atten;

    // final color
    float3 col = 0;
    col += lightColor0 * diff.x;
    col += lightColor1 * diff.y;
    col += lightColor2 * diff.z;
    col += lightColor3 * diff.w;
    return col;
}

/// Applies four closest lights per-vertex using Alloy's attenuation.
/// @param  positionWorld   Position in world-space.
/// @param  normalWorld     Normal in world-space.
/// @return                 Per-vertex direct lighting.
float3 aShade4PointLights(
    float3 positionWorld, 
    float3 normalWorld) 
{
    return aShade4PointLights(
        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
        unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
        unity_4LightAtten0, positionWorld, normalWorld);
}

#endif // ALLOY_SHADERS_FRAMEWORK_UTILITY_CGINC
