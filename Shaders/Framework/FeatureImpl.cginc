// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Feature.cginc
/// @brief Feature method implementations to allow disabling of features.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_FEATURE_IMPL_CGINC
#define ALLOY_SHADERS_FRAMEWORK_FEATURE_IMPL_CGINC

#if !defined(A_TEX_UV_OFF) && defined(A_PROJECTIVE_DECAL_SHADER)
    #define A_TEX_UV_OFF
#endif

#if !defined(A_TRIPLANAR_MAPPING_ON) && defined(_METALLICGLOSSMAP)
    #define A_TRIPLANAR_MAPPING_ON
#endif

#ifdef A_TRIPLANAR_MAPPING_ON
    #ifndef _TRIPLANARMODE_WORLD
        #define A_WORLD_TO_OBJECT_ON
    #endif   

    #ifndef A_NORMAL_WORLD_ON
        #define A_NORMAL_WORLD_ON
    #endif

    #ifndef A_POSITION_WORLD_ON
        #define A_POSITION_WORLD_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Config.cginc"
#include "Assets/Alloy/Shaders/Framework/Feature.cginc"
#include "Assets/Alloy/Shaders/Framework/LightingImpl.cginc"
#include "Assets/Alloy/Shaders/Framework/Utility.cginc"

#include "HLSLSupport.cginc"
#include "UnityCG.cginc"
#include "UnityStandardUtils.cginc"

#define A_BASE_COLOR material0.rgb
#define A_OPACITY material0.a

#define A_METALLIC material1.A_METALLIC_CHANNEL
#define A_AMBIENT_OCCLUSION material1.A_AO_CHANNEL
#define A_SPECULARITY material1.A_SPECULARITY_CHANNEL
#define A_ROUGHNESS material1.A_ROUGHNESS_CHANNEL

#ifdef A_AMBIENT_OCCLUSION_ON
    #define A_SPECULAR_TINT material2.a
#else
    #define A_SPECULAR_TINT material1.g
#endif

#define A_EMISSIVE_COLOR material2.rgb

ASplat aNewSplat()
{
    ASplat sp;

    UNITY_INITIALIZE_OUTPUT(ASplat, sp);
    sp.material0 = 0.0h;
    sp.material1 = 0.0h;
    sp.material2 = 0.0h;
    sp.normal = 0.0h;
    return sp;
}

ASplatContext aNewSplatContext(
    ASurface s,
    half sharpness,
    float positionScale)
{
    ASplatContext sc;

    UNITY_INITIALIZE_OUTPUT(ASplatContext, sc);
    sc.uv01 = s.uv01;
    sc.vertexColor = s.vertexColor;

#ifdef A_TRIPLANAR_MAPPING_ON
    // Triplanar mapping
    // cf http://www.gamedev.net/blog/979/entry-2250761-triplanar-texturing-and-normal-mapping/
    #ifdef _TRIPLANARMODE_WORLD
        half3 geoNormal = s.vertexNormalWorld;
        sc.position = s.positionWorld;
    #else
        half3 geoNormal = UnityWorldToObjectDir(s.vertexNormalWorld);
        sc.position = mul(unity_WorldToObject, float4(s.positionWorld, 1.0f)).xyz;
    #endif

    // Unity uses a Left-handed axis, so it requires clumsy remapping.
    sc.xTangentToWorld = half3x3(A_AXIS_Z, A_AXIS_Y, geoNormal);
    sc.yTangentToWorld = half3x3(A_AXIS_X, A_AXIS_Z, geoNormal);
    sc.zTangentToWorld = half3x3(A_AXIS_X, A_AXIS_Y, geoNormal);

    half3 blending = abs(geoNormal);
    blending = normalize(max(blending, A_EPSILON));
    blending = pow(blending, sharpness);
    blending /= dot(blending, A_ONE);
    sc.blend = blending;

    sc.axisMasks = step(A_ZERO, geoNormal);
    sc.position *= positionScale;
#endif

    return sc;
}

void aApplySplat(
    inout ASurface s,
    ASplat sp)
{
    half3 normal = sp.normal;

    s.baseColor = sp.A_BASE_COLOR;
    s.opacity = sp.A_OPACITY;
    s.metallic = sp.A_METALLIC;
    s.specularity = sp.A_SPECULARITY;
    s.specularTint = sp.A_SPECULAR_TINT;
    s.roughness = sp.A_ROUGHNESS;

#ifdef A_AMBIENT_OCCLUSION_ON
    s.ambientOcclusion = sp.A_AMBIENT_OCCLUSION;
#endif

#ifdef A_EMISSIVE_COLOR_ON
    s.emissiveColor = sp.A_EMISSIVE_COLOR;
#endif

#ifndef A_TRIPLANAR_MAPPING_ON
    s.normalTangent = A_NT(s, normalize(normal));
#else
    #ifdef _TRIPLANARMODE_WORLD
        half3 normalWorld = normalize(normal);
    #else
        half3 normalWorld = UnityObjectToWorldNormal(normal);
    #endif    

    s.normalWorld = A_NW(s, normalWorld);
#endif
}

void aBlendSplat(
    inout ASurface s,
    ASplat sp)
{
    half3 normal = sp.normal;
    half weight = s.mask;

    s.baseColor = lerp(s.baseColor, sp.A_BASE_COLOR, weight);
    s.opacity = lerp(s.opacity, sp.A_OPACITY, weight);
    s.metallic = lerp(s.metallic, sp.A_METALLIC, weight);
    s.specularity = lerp(s.specularity, sp.A_SPECULARITY, weight);
    s.specularTint = lerp(s.specularTint, sp.A_SPECULAR_TINT, weight);
    s.roughness = lerp(s.roughness, sp.A_ROUGHNESS, weight);    

#ifdef A_AMBIENT_OCCLUSION_ON
    s.ambientOcclusion = lerp(s.ambientOcclusion, sp.A_AMBIENT_OCCLUSION, weight);
#endif

#ifdef A_EMISSIVE_COLOR_ON
    s.emissiveColor = lerp(s.emissiveColor, sp.A_EMISSIVE_COLOR, weight);
#endif
    
#ifndef A_TRIPLANAR_MAPPING_ON
    s.normalTangent = A_NT(s, normalize(lerp(s.normalTangent, normal, weight)));
#else
    #ifdef _TRIPLANARMODE_WORLD
        half3 normalWorld = normalize(normal);
    #else
        half3 normalWorld = UnityObjectToWorldNormal(normal);
    #endif    

    s.normalWorld = A_NW(s, normalize(lerp(s.normalWorld, normalWorld, weight)));
#endif
}

void aBlendSplatWithOpacity(
    inout ASurface s,
    ASplat sp)
{
    s.mask *= sp.A_OPACITY;
    sp.A_OPACITY = 1.0h;

    aBlendSplat(s, sp);
}

void aMergeSplats(
    inout ASplat sp0,
    ASplat sp1)
{
    sp0.material0 += sp1.material0;
    sp0.material1 += sp1.material1;
    sp0.normal += sp1.normal;
    sp0.material2 += sp1.material2;
}

void aSplatMaterial(
    inout ASplat sp,
    ASplatContext sc,
    half4 tint,
    half vertexTint,
    half metallic,
    half specularity,
    half specularTint,
    half roughness)
{
    sp.material0 *= tint;

#ifndef A_VERTEX_COLOR_IS_DATA
    sp.A_BASE_COLOR *= aLerpWhiteTo(sc.vertexColor.rgb, vertexTint);
#endif

    sp.A_METALLIC *= metallic;
    sp.A_SPECULARITY *= specularity;
    sp.A_ROUGHNESS *= roughness;
    sp.A_SPECULAR_TINT = specularTint;
}

void aTriPlanarAxis(
    inout ASplat sp,
    half mask,
    half3x3 tbn,
    float2 uv,
    half occlusion,
    half bumpScale,
    sampler2D base,
    sampler2D material,
    sampler2D normal)
{
    ASplat sp0 = aNewSplat();

    sp0.material0 = tex2D(base, uv);
    sp0.normal = mul(UnpackScaleNormal(tex2D(normal, uv), bumpScale), tbn);

#ifndef A_ROUGHNESS_SOURCE_BASE_COLOR_ALPHA
    sp0.material1 = tex2D(material, uv);
    sp0.A_AMBIENT_OCCLUSION = aOcclusionStrength(sp0.A_AMBIENT_OCCLUSION, occlusion);
#else
    sp0.A_METALLIC = 1.0h;
    sp0.A_AMBIENT_OCCLUSION = 1.0h;
    sp0.A_SPECULARITY = 1.0h;
    sp0.A_ROUGHNESS = sp0.A_OPACITY;
    sp0.A_OPACITY = 1.0h;
#endif

    sp.material0 += mask * sp0.material0;
    sp.material1 += mask * sp0.material1;
    sp.normal += mask * sp0.normal;
}

void aTriPlanarX(
    inout ASplat sp,
    ASplatContext sc,
    A_SAMPLER_PARAM(base),
    sampler2D material,
    sampler2D normal,
    half occlusion,
    half bumpScale)
{
    aTriPlanarAxis(sp, sc.blend.x, sc.xTangentToWorld, A_TEX_TRANSFORM_SCROLL(base, sc.position.zy), occlusion, bumpScale, base, material, normal);
}

void aTriPlanarY(
    inout ASplat sp,
    ASplatContext sc,
    A_SAMPLER_PARAM(base),
    sampler2D material,
    sampler2D normal,
    half occlusion,
    half bumpScale)
{
    aTriPlanarAxis(sp, sc.blend.y, sc.yTangentToWorld, A_TEX_TRANSFORM_SCROLL(base, sc.position.xz), occlusion, bumpScale, base, material, normal);
}

void aTriPlanarZ(
    inout ASplat sp,
    ASplatContext sc,
    A_SAMPLER_PARAM(base),
    sampler2D material,
    sampler2D normal,
    half occlusion,
    half bumpScale)
{
    aTriPlanarAxis(sp, sc.blend.z, sc.zTangentToWorld, A_TEX_TRANSFORM_SCROLL(base, sc.position.xy), occlusion, bumpScale, base, material, normal);
}

void aTriPlanarPositiveY(
    inout ASplat sp,
    ASplatContext sc,
    A_SAMPLER_PARAM(base),
    sampler2D material,
    sampler2D normal,
    half occlusion,
    half bumpScale)
{
    aTriPlanarAxis(sp, sc.axisMasks.y * sc.blend.y, sc.yTangentToWorld, A_TEX_TRANSFORM_SCROLL(base, sc.position.xz), occlusion, bumpScale, base, material, normal);
}

void aTriPlanarNegativeY(
    inout ASplat sp,
    ASplatContext sc,
    A_SAMPLER_PARAM(base),
    sampler2D material,
    sampler2D normal,
    half occlusion,
    half bumpScale)
{
    aTriPlanarAxis(sp, (1.0h - sc.axisMasks.y) * sc.blend.y, sc.yTangentToWorld, A_TEX_TRANSFORM_SCROLL(base, sc.position.xz), occlusion, bumpScale, base, material, normal);
}

ASplat aNewSplat(
    ASplatContext sc,
    A_SAMPLER_PARAM(base),
    sampler2D material,
    sampler2D normal,
    half4 tint,
    half vertexTint,
    half metallic,
    half specularity,
    half specularTint,
    half roughness,
    half occlusion,
    half bumpScale)
{
    ASplat sp = aNewSplat();

#ifdef A_TRIPLANAR_MAPPING_ON
    aTriPlanarX(sp, sc, A_SAMPLER_2D_INPUT(base), material, normal, occlusion, bumpScale);
    aTriPlanarY(sp, sc, A_SAMPLER_2D_INPUT(base), material, normal, occlusion, bumpScale);
    aTriPlanarZ(sp, sc, A_SAMPLER_2D_INPUT(base), material, normal, occlusion, bumpScale);
#else
    sp.baseUv = A_TEX_TRANSFORM_UV_SCROLL(sc, base);
    sp.material0 = tex2D(base, sp.baseUv);
    sp.normal = UnpackScaleNormal(tex2D(normal, sp.baseUv), bumpScale);

    #ifndef A_ROUGHNESS_SOURCE_BASE_COLOR_ALPHA
        sp.material1 = tex2D(material, sp.baseUv);
        sp.A_AMBIENT_OCCLUSION = aOcclusionStrength(sp.A_AMBIENT_OCCLUSION, occlusion);
    #else
        sp.A_METALLIC = 1.0h;
        sp.A_AMBIENT_OCCLUSION = 1.0h;
        sp.A_SPECULARITY = 1.0h;
        sp.A_ROUGHNESS = sp.A_OPACITY;
        sp.A_OPACITY = 1.0h;
    #endif
#endif

    aSplatMaterial(sp, sc, tint, vertexTint, metallic, specularity, specularTint, roughness);
    return sp;
}

void aApplyTerrainSplats(
    inout ASurface s,
    half3 weights,
    ASplat sp0,
    ASplat sp1,
    ASplat sp2)
{
    ASplat sp = aNewSplat();
    sp.material0 = weights.r * sp0.material0 + weights.g * sp1.material0 + weights.b * sp2.material0;
    sp.material1 = weights.r * sp0.material1 + weights.g * sp1.material1 + weights.b * sp2.material1;
    sp.material2 = weights.r * sp0.material2 + weights.g * sp1.material2 + weights.b * sp2.material2;
    sp.normal = weights.r * sp0.normal + weights.g * sp1.normal + weights.b * sp2.normal;
    aApplySplat(s, sp);
}

void aApplyTerrainSplats(
    inout ASurface s,
    half4 weights,
    ASplat sp0,
    ASplat sp1,
    ASplat sp2,
    ASplat sp3)
{
    ASplat sp = aNewSplat();
    sp.material0 = weights.r * sp0.material0 + weights.g * sp1.material0 + weights.b * sp2.material0 + weights.a * sp3.material0;
    sp.material1 = weights.r * sp0.material1 + weights.g * sp1.material1 + weights.b * sp2.material1 + weights.a * sp3.material1;
    sp.material2 = weights.r * sp0.material2 + weights.g * sp1.material2 + weights.b * sp2.material2 + weights.a * sp3.material2;
    sp.normal = weights.r * sp0.normal + weights.g * sp1.normal + weights.b * sp2.normal + weights.a * sp3.normal;
    aApplySplat(s, sp);
}

half aOcclusionStrength(
    half ao,
    half weight)
{
    return aLerpOneTo(aGammaToLinear(ao), weight);
}

void aBaseUvInit(
    inout ASurface s)
{
    s.baseUv = A_TEX_TRANSFORM_UV_SCROLL(s, _MainTex);
    s.baseTiling = _MainTex_ST.xy;

    // Initialize VirtualCoord here so subsequent calls can be cheaper updates.
#ifdef _VIRTUALTEXTURING_ON
    s.baseVirtualCoord = VTComputeVirtualCoord(s.baseUv);
#endif
}

void aUpdateBaseUv(
    inout ASurface s)
{
#ifdef _VIRTUALTEXTURING_ON
    s.baseVirtualCoord = VTUpdateVirtualCoord(s.baseVirtualCoord, s.baseUv);
#endif
}

float2 aPickUv(
    ASurface s,
    float nameUv)
{
#ifdef A_TEX_UV_OFF
    return s.uv01.xy;
#else
    return nameUv < 0.5f ? s.uv01.xy : s.uv01.zw;
#endif
}

float2 aPickUv(
    ASplatContext sc,
    float nameUv)
{
#ifdef A_TEX_UV_OFF
    return sc.uv01.xy;
#else
    return nameUv < 0.5f ? sc.uv01.xy : sc.uv01.zw;
#endif
}

void aTwoSided(
    inout ASurface s)
{
#ifdef A_TWO_SIDED_SHADER
    s.normalTangent.xy = A_NT(s, s.facingSign > 0.0h || _TransInvertBackNormal < 0.5f ? s.normalTangent.xy : -s.normalTangent.xy);
#endif
}

void aCutout(
    ASurface s)
{
#ifdef _ALPHATEST_ON
    clip(s.opacity - _Cutoff);
#endif
}

half4 aSampleBase(
    ASurface s) 
{
    half4 result = 0.0h;

#ifdef _VIRTUALTEXTURING_ON
    result = VTSampleBase(s.baseVirtualCoord);
#else
    result = tex2D(_MainTex, s.baseUv);
#endif
    
    return result;
}

half4 aSampleMaterial(
    ASurface s) 
{
    half4 result = 0.0h;

#ifndef A_EXPANDED_MATERIAL_MAPS
    #ifndef _VIRTUALTEXTURING_ON
        result = tex2D(_SpecTex, s.baseUv);
    #else
        result = VTSampleSpecular(s.baseVirtualCoord);
    #endif

    result.A_AO_CHANNEL = aGammaToLinear(result.A_AO_CHANNEL);
#else
    half3 channels;

    // Assuming sRGB texture sampling, undo it for all but AO.
    channels.x = tex2D(_MetallicMap, s.baseUv).g;
    channels.y = tex2D(_SpecularityMap, s.baseUv).g;
    channels.z = tex2D(_RoughnessMap, s.baseUv).g;
    channels = LinearToGammaSpace(channels);

    result.A_METALLIC_CHANNEL = channels.x;
    result.A_AO_CHANNEL = tex2D(_AoMap, s.baseUv).g;
    result.A_SPECULARITY_CHANNEL = channels.y;
    result.A_ROUGHNESS_CHANNEL = channels.z;
#endif

    return result;
}

half3 aSampleBumpScale(
    ASurface s,
    half scale)
{
    half4 result = 0.0h;

#ifdef _VIRTUALTEXTURING_ON
    result = VTSampleNormal(s.baseVirtualCoord);
#else
    result = tex2D(_BumpMap, s.baseUv);
#endif

    return UnpackScaleNormal(result, scale);
}

half3 aSampleBump(
    ASurface s) 
{
    return aSampleBumpScale(s, _BumpScale);
}

half3 aSampleBumpBias(
    ASurface s,
    float bias) 
{
    half4 result = 0.0h;

#ifdef _VIRTUALTEXTURING_ON
    result = VTSampleNormal(VTComputeVirtualCoord(s.baseUv, bias));
#else
    result = tex2Dbias(_BumpMap, float4(s.baseUv, 0.0h, bias));
#endif

    return UnpackScaleNormal(result, _BumpScale);  
}

half aSampleHeight(
    ASurface s)
{
    half result = 0.0h;

#ifdef _VIRTUALTEXTURING_ON
    result = VTSampleNormal(s.baseVirtualCoord).b;
#else
    result = tex2D(_ParallaxMap, s.baseUv).y;
#endif

    return result;
}

half3 aVertexColorTint(
    ASurface s,
    half strength)
{
#ifdef A_VERTEX_COLOR_IS_DATA
    return A_WHITE;
#else
    return aLerpWhiteTo(s.vertexColor.rgb, strength);
#endif
}

half3 aBaseVertexColorTint(
    ASurface s)
{
    return aVertexColorTint(s, _BaseColorVertexTint);
}

half4 aBaseTint(
    ASurface s)
{
    half4 result = _Color;

#ifndef A_VERTEX_COLOR_IS_DATA
    result.rgb *= aBaseVertexColorTint(s);
#endif

    return result;
}

half4 aBase(
    ASurface s)
{
    return aBaseTint(s) * aSampleBase(s);
}

void aParallaxOffset(
    inout ASurface s,
    float2 offset)
{
#ifdef A_PARALLAX_MAPPED_PASS
    offset *= s.mask;
    
    // To apply the parallax offset to secondary textures without causing swimming,
    // we must normalize it by removing the implicitly multiplied base map tiling. 
    s.uv01 += (offset / s.baseTiling).xyxy;
    s.baseUv += A_BV(s, offset);
#endif
}

void aOffsetBumpMapping(
    inout ASurface s)
{
    // NOTE: Prevents NaN compiler errors in DX9 mode for shadow pass.
#if defined(A_TANGENT_TO_WORLD_ON) && defined(A_VIEW_DIR_TANGENT_ON)
    half h = aSampleHeight(s) * _Parallax - _Parallax * 0.5h;
    half3 v = s.viewDirTangent;

    v.z += 0.42h;
    aParallaxOffset(s, h * (v.xy / v.z));
#endif
}

void aParallaxOcclusionMapping(
    inout ASurface s,
    float minSamples,
    float maxSamples)
{
    // NOTE: Prevents NaN compiler errors in DX9 mode for shadow pass.
#if defined(A_TANGENT_TO_WORLD_ON) && defined(A_VIEW_DIR_TANGENT_ON)
    // Parallax Occlusion Mapping
    // Subject to GameDev.net Open License
    // cf http://www.gamedev.net/page/resources/_/technical/graphics-programming-and-theory/a-closer-look-at-parallax-occlusion-mapping-r3262
    float2 offset = float2(0.0f, 0.0f);

    // Calculate the parallax offset vector max length.
    // This is equivalent to the tangent of the angle between the
    // viewer position and the fragment location.
    float parallaxLimit = -length(s.viewDirTangent.xy) / s.viewDirTangent.z;

    // Scale the parallax limit according to heightmap scale.
    parallaxLimit *= _Parallax;

    // Calculate the parallax offset vector direction and maximum offset.
    float2 offsetDirTangent = normalize(s.viewDirTangent.xy);
    float2 maxOffset = offsetDirTangent * parallaxLimit;
    
    // Calculate how many samples should be taken along the view ray
    // to find the surface intersection.  This is based on the angle
    // between the surface normal and the view vector.
    int numSamples = (int)lerp(maxSamples, minSamples, s.NdotV);
    int currentSample = 0;
    
    // Specify the view ray step size.  Each sample will shift the current
    // view ray by this amount.
    float stepSize = 1.0f / (float)numSamples;

    // Initialize the starting view ray height and the texture offsets.
    float currentRayHeight = 1.0f;	
    float2 lastOffset = float2(0.0f, 0.0f);
    
    float lastSampledHeight = 1.0f;
    float currentSampledHeight = 1.0f;

    #ifdef _VIRTUALTEXTURING_ON
        VirtualCoord vcoord = s.baseVirtualCoord;
    #else
        // Calculate the texture coordinate partial derivatives in screen
        // space for the tex2Dgrad texture sampling instruction.
        float2 dx = ddx(s.baseUv);
        float2 dy = ddy(s.baseUv);
    #endif

    while (currentSample < numSamples) {
        #ifdef _VIRTUALTEXTURING_ON
            vcoord = VTUpdateVirtualCoord(vcoord, s.baseUv + offset);
            currentSampledHeight = VTSampleNormal(vcoord).b;
        #else
            // Sample the heightmap at the current texcoord offset.
            currentSampledHeight = tex2Dgrad(_ParallaxMap, s.baseUv + offset, dx, dy).y;
        #endif

        // Test if the view ray has intersected the surface.
        UNITY_BRANCH
        if (currentSampledHeight > currentRayHeight) {
            // Find the relative height delta before and after the intersection.
            // This provides a measure of how close the intersection is to 
            // the final sample location.
            float delta1 = currentSampledHeight - currentRayHeight;
            float delta2 = (currentRayHeight + stepSize) - lastSampledHeight;
            float ratio = delta1 / (delta1 + delta2);

            // Interpolate between the final two segments to 
            // find the true intersection point offset.
            offset = lerp(offset, lastOffset, ratio);
            
            // Force the exit of the while loop
            currentSample = numSamples + 1;	
        }
        else {
            // The intersection was not found.  Now set up the loop for the next
            // iteration by incrementing the sample count,
            currentSample++;

            // take the next view ray height step,
            currentRayHeight -= stepSize;
            
            // save the current texture coordinate offset and increment
            // to the next sample location, 
            lastOffset = offset;
            offset += stepSize * maxOffset;

            // and finally save the current heightmap height.
            lastSampledHeight = currentSampledHeight;
        }
    }

    aParallaxOffset(s, offset);
#endif
}

#endif // ALLOY_SHADERS_FRAMEWORK_FEATURE_IMPL_CGINC
