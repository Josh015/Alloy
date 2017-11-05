// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Forward.cginc
/// @brief Forward passes uber-header.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_FORWARD_CGINC
#define ALLOY_SHADERS_FRAMEWORK_FORWARD_CGINC

// Headers both for this file, and for all Definition and Feature modules.
#include "Assets/Alloy/Shaders/Framework/FeatureImpl.cginc"
#include "Assets/Alloy/Shaders/Framework/LightingImpl.cginc"
#include "Assets/Alloy/Shaders/Framework/TypeImpl.cginc"
#include "Assets/Alloy/Shaders/Framework/Unity.cginc"
#include "Assets/Alloy/Shaders/Framework/Utility.cginc"

#include "AutoLight.cginc"
#include "HLSLSupport.cginc"
#include "UnityCG.cginc"
#include "UnityGlobalIllumination.cginc"
#include "UnityImageBasedLighting.cginc"
#include "UnityInstancing.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityShaderUtilities.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShadowLibrary.cginc"
#include "UnityStandardUtils.cginc"

// Support for two-sided effects in a single pass.
#ifndef A_TWO_SIDED_SHADER
    #define A_FACING_SIGN_PARAM
    #define A_FACING_SIGN 1.0h
#else
    #define A_FACING_SIGN_PARAM ,half facingSign : VFACE
    #define A_FACING_SIGN facingSign
#endif

// Shadows.
#if defined(SHADOWS_SCREEN) && !defined(UNITY_NO_SCREENSPACE_SHADOWS)
    #define A_SCREENSPACE_SHADOWS_ON
#endif

// Lightmaps.
#if !defined(A_UV2_ON) && defined(DYNAMICLIGHTMAP_ON) && defined(A_INDIRECT_ON)
    #define A_UV2_ON
#endif

#if defined(LIGHTMAP_ON) && defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
    #define A_LIGHTMAP_SHADOW_MIXING_ON
#endif

// Lighting vertex data.
#if defined(A_INDIRECT_ON) && defined(A_DIRECT_ON)
    #define A_FORWARD_TEXCOORD0 half4 giData : TEXCOORD0;
    #define A_FORWARD_TEXCOORD1 UNITY_SHADOW_COORDS(1)
#elif defined(A_INDIRECT_ON)
    #define A_FORWARD_TEXCOORD0 half4 giData : TEXCOORD0;

    #ifdef A_SHADOW_MASKS_BUFFER_ON
        #define A_FORWARD_TEXCOORD1 UNITY_SHADOW_COORDS(1)
    #endif
#elif defined(A_DIRECT_ON)
    #define A_FORWARD_TEXCOORD0 UNITY_SHADOW_COORDS(0)
    
    // Reduce v2f transfer cost for pure directional lights.
    #if !defined(DIRECTIONAL) && !defined(A_LIGHTMAP_SHADOW_MIXING_ON)
        #define A_FORWARD_TEXCOORD1 unityShadowCoord4 lightCoord : TEXCOORD1;

        #ifndef USING_DIRECTIONAL_LIGHT
            #define A_FORWARD_TEXCOORD2 float4 lightVectorRange : TEXCOORD2;
        #endif
    #endif
#endif

// Handle dependencies between vertex data.
#if !defined(A_TANGENT_ON) && defined(A_TANGENT_TO_WORLD_ON)
    #define A_TANGENT_ON
#endif

#if !defined(A_NORMAL_WORLD_ON) && (defined(A_TANGENT_TO_WORLD_ON) || defined(A_REFLECTION_VECTOR_WORLD_ON))
    #define A_NORMAL_WORLD_ON
#endif

#if !defined(A_VIEW_DIR_WORLD_ON) && (defined(A_VIEW_DIR_TANGENT_ON) || defined(A_REFLECTION_VECTOR_WORLD_ON))
    #define A_VIEW_DIR_WORLD_ON
#endif

#if !defined(A_POSITION_WORLD_ON) && defined(A_VIEW_DIR_WORLD_ON)
    #define A_POSITION_WORLD_ON
#endif

#if !defined(A_SCREEN_UV_ON) && defined(LOD_FADE_CROSSFADE)
    #define A_SCREEN_UV_ON
#endif

// Enable specific packed texcoord channels.
#if !defined(A_POSITION_TEXCOORD_ON) && (defined(A_POSITION_WORLD_ON) || defined(A_VIEW_DEPTH_ON))
    #define A_POSITION_TEXCOORD_ON
#endif

#if !defined(A_FOG_TEXCOORD_ON) && (defined(A_FOG_ON) || defined(A_SCREEN_UV_ON))
    #define A_FOG_TEXCOORD_ON
#endif

#if !defined(A_TRANSFER_INSTANCE_ID_ON) && defined(A_WORLD_TO_OBJECT_ON) && defined(A_INSTANCING_PASS)
    #define A_TRANSFER_INSTANCE_ID_ON
#endif

// Split vertex data conditions to reduce combinations.
// UV0-1, TBN, N.
#if defined(A_TANGENT_TO_WORLD_ON)    
    #define A_INNER_VERTEX_DATA2(A, B, C, D) \
        float4 texcoords : TEXCOORD##A; \
        half3 tangentWorld : TEXCOORD##B; \
        half3 bitangentWorld : TEXCOORD##C; \
        half3 normalWorld : TEXCOORD##D;
#elif defined(A_NORMAL_WORLD_ON)
    #define A_INNER_VERTEX_DATA2(A, B, C, D) \
        float4 texcoords : TEXCOORD##A; \
        half3 normalWorld : TEXCOORD##B;
#else
    #define A_INNER_VERTEX_DATA2(A, B, C, D) \
        float4 texcoords : TEXCOORD##A;
#endif

// Vertex Color, Position, View Depth, Fog, and Screen UV.
#if defined(A_POSITION_TEXCOORD_ON) && defined(A_FOG_TEXCOORD_ON)
    #define A_INNER_VERTEX_DATA1(A, B, C, D, E, F, G) \
        half4 color : TEXCOORD##A; \
        float4 positionWorldAndViewDepth : TEXCOORD##B; \
        UNITY_FOG_COORDS_PACKED(C, half4) \
        A_INNER_VERTEX_DATA2(D, E, F, G)
#elif defined(A_POSITION_TEXCOORD_ON)
    #define A_INNER_VERTEX_DATA1(A, B, C, D, E, F, G) \
        half4 color : TEXCOORD##A; \
        float4 positionWorldAndViewDepth : TEXCOORD##B; \
        A_INNER_VERTEX_DATA2(C, D, E, F)
#elif defined(A_FOG_TEXCOORD_ON)
    #define A_INNER_VERTEX_DATA1(A, B, C, D, E, F, G) \
        half4 color : TEXCOORD##A; \
        UNITY_FOG_COORDS_PACKED(C, half4) \
        A_INNER_VERTEX_DATA2(D, E, F, G)
#else
    #define A_INNER_VERTEX_DATA1(A, B, C, D, E, F, G) \
        half4 color : TEXCOORD##A; \
        A_INNER_VERTEX_DATA2(B, C, D, E)
#endif

// Instancing.
#if defined(A_TRANSFER_INSTANCE_ID_ON) && defined(A_STEREO_INSTANCING_PASS)
    #define A_INSTANCING_VERTEX_DATA(A, B, C, D, E, F, G) A_INNER_VERTEX_DATA1(A, B, C, D, E, F, G) UNITY_VERTEX_INPUT_INSTANCE_ID UNITY_VERTEX_OUTPUT_STEREO
#elif defined(A_TRANSFER_INSTANCE_ID_ON)
    #define A_INSTANCING_VERTEX_DATA(A, B, C, D, E, F, G) A_INNER_VERTEX_DATA1(A, B, C, D, E, F, G) UNITY_VERTEX_INPUT_INSTANCE_ID
#elif defined(A_STEREO_INSTANCING_PASS)
    #define A_INSTANCING_VERTEX_DATA(A, B, C, D, E, F, G) A_INNER_VERTEX_DATA1(A, B, C, D, E, F, G) UNITY_VERTEX_OUTPUT_STEREO
#else
    #define A_INSTANCING_VERTEX_DATA(A, B, C, D, E, F, G) A_INNER_VERTEX_DATA1(A, B, C, D, E, F, G)
#endif

// Surface shader off.
#if defined(A_SURFACE_SHADER_OFF)
    #define A_VERTEX_DATA(A, B, C, D, E, F, G) 
#else
    #define A_VERTEX_DATA(A, B, C, D, E, F, G) A_INSTANCING_VERTEX_DATA(A, B, C, D, E, F, G)
#endif

/// Configurable vertex input data from the application.
struct AVertexInput 
{
    float4 vertex : POSITION;
    float4 uv0 : TEXCOORD0;
    float4 uv1 : TEXCOORD1;
    half3 normal : NORMAL;
#ifdef A_UV2_ON
    float4 uv2 : TEXCOORD2;
#endif
#ifdef A_UV3_ON
    float4 uv3 : TEXCOORD3;
#endif
#ifdef A_TANGENT_ON
    half4 tangent : TANGENT;
#endif
    half4 color : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

/// Extensible fragment input data.
struct AFragmentInput {
#if defined(A_FORWARD_TEXCOORD0) && defined(A_FORWARD_TEXCOORD1) && defined(A_FORWARD_TEXCOORD2)
    A_FORWARD_TEXCOORD0
    A_FORWARD_TEXCOORD1
    A_FORWARD_TEXCOORD2
    A_VERTEX_DATA(3, 4, 5, 6, 7, 8, 9)
#elif defined(A_FORWARD_TEXCOORD0) && defined(A_FORWARD_TEXCOORD1)
    A_FORWARD_TEXCOORD0
    A_FORWARD_TEXCOORD1
    A_VERTEX_DATA(2, 3, 4, 5, 6, 7, 8)
#elif defined(A_FORWARD_TEXCOORD0)
    A_FORWARD_TEXCOORD0
    A_VERTEX_DATA(1, 2, 3, 4, 5, 6, 7)
#else
    A_VERTEX_DATA(0, 1, 2, 3, 4, 5, 6)
#endif
};

// TODO: Find a way to move this dependency!
#include "Assets/Alloy/Shaders/Framework/Tessellation.cginc"

/// Transfers the per-vertex lightmapping or SH data to the fragment shader.
/// @param[in,out]  i   Vertex to fragment transfer data.
/// @param[in]      v   Vertex input data.
void aVertexGi(
    inout AFragmentInput i,
    AVertexInput v)
{
#ifdef A_INDIRECT_ON
    #ifdef LIGHTMAP_ON
        i.giData.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        i.giData.zw = 0.0h;
    #elif UNITY_SHOULD_SAMPLE_SH
        // Add approximated illumination from non-important point lights
        half3 normalWorld = i.normalWorld.xyz;

        #ifdef VERTEXLIGHT_ON
            i.giData.rgb = aShade4PointLights(i.positionWorldAndViewDepth.xyz, normalWorld);
        #endif

        i.giData.rgb = ShadeSHPerVertex(normalWorld, i.giData.rgb);
    #endif

    #ifdef DYNAMICLIGHTMAP_ON
        i.giData.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif
#endif
}

/// Populates a UnityGI descriptor in the fragment shader.
/// @param  i       Vertex to fragment transfer data.
/// @param  s       Material surface data.
/// @param  shadow  Forward Base directional light shadow.
/// @return         Initialized UnityGI descriptor.
UnityGI aFragmentGi(
    AFragmentInput i,
    ASurface s,
    half shadow)
{
    UnityGI gi;
    UNITY_INITIALIZE_OUTPUT(UnityGI, gi);

#ifdef A_INDIRECT_ON
    UnityGIInput d;

    UNITY_INITIALIZE_OUTPUT(UnityGIInput, d);
    d.worldPos = s.positionWorld;
    d.worldViewDir = s.viewDirWorld; // ???
    d.atten = shadow;

    #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
        d.ambient = 0;
        d.lightmapUV = i.giData;
    #else
        d.ambient = i.giData.rgb;
        d.lightmapUV = 0;
    #endif

    d.probeHDR[0] = unity_SpecCube0_HDR;
    d.probeHDR[1] = unity_SpecCube1_HDR;

    #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
        d.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
    #endif

    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
        d.boxMax[0] = unity_SpecCube0_BoxMax;
        d.probePosition[0] = unity_SpecCube0_ProbePosition;
        d.boxMax[1] = unity_SpecCube1_BoxMax;
        d.boxMin[1] = unity_SpecCube1_BoxMin;
        d.probePosition[1] = unity_SpecCube1_ProbePosition;
    #endif

    // So we can extract shadow with baked occlusion.
    #ifdef HANDLE_SHADOWS_BLENDING_IN_GI
        d.light.color = A_WHITE;
    #endif

    // Pass 1.0 for occlusion so we can apply it later in indirect().  
    gi = UnityGI_Base(d, 1.0h, s.ambientNormalWorld);

    #ifdef A_REFLECTION_PROBES_ON
        Unity_GlossyEnvironmentData g;

        g.reflUVW = s.reflectionVectorWorld;
        g.roughness = s.roughness;
        gi.indirect.specular = UnityGI_IndirectSpecular(d, 1.0h, s.normalWorld, g);
    #endif
#endif

    return gi;
}

/// Transforms the vertex data before transferring it to the pixel shader.
/// @param[in,out]  v       Vertex input data.
/// @param[out]     o       Vertex to fragment transfer data.
/// @param[out]     opos    Clip space position.
void aForwardVertexShader(
    inout AVertexInput v,
    out AFragmentInput o, 
    out float4 opos)
{
#ifdef A_SURFACE_SHADER_OFF
    opos = 0.0h;
#else
    UNITY_INITIALIZE_OUTPUT(AFragmentInput, o);

    #ifdef A_INSTANCING_PASS
        UNITY_SETUP_INSTANCE_ID(v);

        #ifdef A_TRANSFER_INSTANCE_ID_ON
            UNITY_TRANSFER_INSTANCE_ID(v, o);
        #endif

        #ifdef A_STEREO_INSTANCING_PASS
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
        #endif
    #endif

    // Copy vertex data, and let shader type modify it.
    AVertex vs = aNewVertex();

    vs.positionObject = v.vertex;
    vs.uv0 = v.uv0;
    vs.uv1 = v.uv1;
    vs.normalObject = v.normal;

    #ifdef A_UV2_ON
        vs.uv2 = v.uv2;
    #endif
    #ifdef A_UV3_ON
        vs.uv3 = v.uv3;
    #endif
    #ifdef A_TANGENT_ON
        vs.tangentObject = v.tangent;
    #endif

    vs.color = v.color;

    aVertexShader(vs);

    // Copy data back into original, in case outer shader needs it.
    v.vertex = vs.positionObject;
    v.uv0 = vs.uv0;
    v.uv1 = vs.uv1;
    v.normal = vs.normalObject;

    #ifdef A_UV2_ON
        v.uv2 = vs.uv2;
    #endif
    #ifdef A_UV3_ON
        v.uv3 = vs.uv3;
    #endif
    #ifdef A_TANGENT_ON
        v.tangent = vs.tangentObject;
    #endif

    v.color = vs.color;

    // Fill V2F.
    o.color = v.color; // Gamma-space vertex color, unless modified.
    o.texcoords.xy = v.uv0.xy;
    o.texcoords.zw = v.uv1.xy;
    opos = UnityObjectToClipPos(v.vertex.xyz);
    
    #ifdef A_POSITION_TEXCOORD_ON
        #ifdef A_POSITION_WORLD_ON
            o.positionWorldAndViewDepth.xyz = mul(unity_ObjectToWorld, v.vertex).xyz;
        #endif

        #ifdef A_VIEW_DEPTH_ON
            COMPUTE_EYEDEPTH(o.positionWorldAndViewDepth.w);
        #endif
    #endif
        
    #ifdef A_NORMAL_WORLD_ON
        float3 normalWorld = UnityObjectToWorldNormal(v.normal);
    #endif

    #ifndef A_TANGENT_TO_WORLD_ON
        #ifdef A_NORMAL_WORLD_ON
            o.normalWorld = normalWorld;
        #endif
    #else
        float3 tangentWorld = UnityObjectToWorldDir(v.tangent.xyz);
        float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld, v.tangent.w);

        o.tangentWorld = tangentToWorld[0];
        o.bitangentWorld = tangentToWorld[1];
        o.normalWorld = tangentToWorld[2];
    #endif

    #if defined(A_SCREEN_UV_ON) || (defined(A_DIRECT_ON) && defined(A_SCREENSPACE_SHADOWS_ON))
        float4 screenPos = ComputeScreenPos(opos);
    #endif

    // Fog and Screen UV.
    #ifdef A_FOG_TEXCOORD_ON
        #ifdef A_SCREEN_UV_ON
            o.fogCoord.yzw = screenPos.xyw;
        #else
            o.fogCoord.yzw = A_AXIS_Z;
        #endif

        #ifdef A_FOG_ON
            UNITY_TRANSFER_FOG(o, opos);
        #endif
    #endif

    // Lighting data.
    aVertexGi(o, v);

    #ifdef A_DIRECT_ON
        // NOTE: Custom macro to skip calculations and remove dependency on o.pos!
        #ifdef A_SCREENSPACE_SHADOWS_ON
            o._ShadowCoord = screenPos;
        #else
            UNITY_TRANSFER_SHADOW(o, v.uv1);
        #endif

        #if !defined(DIRECTIONAL) && !defined(A_LIGHTMAP_SHADOW_MIXING_ON)
            o.lightCoord = mul(unity_WorldToLight, unityShadowCoord4(o.positionWorldAndViewDepth.xyz, 1.0f));

            #ifndef USING_DIRECTIONAL_LIGHT
                o.lightVectorRange = UnityWorldSpaceLightDir(o.positionWorldAndViewDepth.xyz).xyzz;
                aLightRange(o.lightVectorRange, o.lightCoord);
            #endif
        #endif
    #endif
#endif
}

/// Create a surface populated with material data.
/// @param  i           Vertex to fragment transfer data.
/// @param  facingSign  Sign of front/back facing direction.
/// @return             Initialized surface data object.
ASurface aForwardSurface(
    AFragmentInput i,
    half facingSign)
{
    ASurface s = aNewSurface();

#ifndef A_SURFACE_SHADER_OFF
    #ifdef A_TRANSFER_INSTANCE_ID_ON
        UNITY_SETUP_INSTANCE_ID(i);
    #endif

    s.uv01 = i.texcoords;
    s.vertexColor = i.color;
    s.facingSign = facingSign;

    #ifdef A_POSITION_TEXCOORD_ON
        #ifdef A_POSITION_WORLD_ON
            s.positionWorld = i.positionWorldAndViewDepth.xyz;
        #endif
        
        #ifdef A_VIEW_DEPTH_ON
            s.viewDepth = i.positionWorldAndViewDepth.w;
        #endif
    #endif

    #ifdef A_NORMAL_WORLD_ON
        #ifdef A_TWO_SIDED_SHADER
            i.normalWorld.xyz *= facingSign;
        #endif

        // Give these sane defaults in case the surface shader doesn't set them.
        s.vertexNormalWorld = normalize(i.normalWorld);
        s.normalWorld = s.vertexNormalWorld;
        s.ambientNormalWorld = s.vertexNormalWorld;
    #endif

    #ifdef A_VIEW_DIR_WORLD_ON
        // Cheaper to calculate in PS than to unpack from vertex, while also
        // preventing distortion in POM and area light specular highlights.
        s.viewDirWorld = normalize(UnityWorldSpaceViewDir(s.positionWorld));
    #endif

    #ifdef A_TANGENT_TO_WORLD_ON
        half3 t = i.tangentWorld;
        half3 b = i.bitangentWorld;
        half3 n = i.normalWorld;
        
        #if UNITY_TANGENT_ORTHONORMALIZE
            n = normalize(n);
    
            // ortho-normalize Tangent
            t = normalize (t - n * dot(t, n));

            // recalculate Binormal
            half3 newB = cross(n, t);
            b = newB * sign (dot (newB, b));
        #endif

        s.tangentToWorld = half3x3(t, b, n);

        #if defined(A_VIEW_DIR_WORLD_ON) && defined(A_VIEW_DIR_TANGENT_ON)
            s.viewDirTangent = normalize(mul(s.tangentToWorld, s.viewDirWorld));
        #endif
    #endif
        
    #ifdef A_FOG_TEXCOORD_ON
        #ifdef A_FOG_ON
            s.fogCoord = i.fogCoord;
        #endif

        #ifdef A_SCREEN_UV_ON
            s.screenPosition.xyw = i.fogCoord.yzw;
            s.screenPosition.z = 0.0h;
            s.screenUv.xy = s.screenPosition.xy / s.screenPosition.w;

            #ifdef LOD_FADE_CROSSFADE
                half2 projUV = s.screenUv.xy * _ScreenParams.xy * 0.25h;

                projUV.y = frac(projUV.y) * 0.0625h /* 1/16 */ + unity_LODFade.y; // quantized lod fade by 16 levels
                clip(tex2D(_DitherMaskLOD2D, projUV).a - 0.5f);
            #endif
        #endif
    #endif

    // Runs the shader and lighting type's surface code.
    aBaseUvInit(s);
    aUpdateViewData(s);
    aSurfaceShader(s);
    aPreLighting(s);
#endif

    return s;
}

/// Final processing of the forward color before output.
/// @param  s       Material surface data.
/// @param  color   Lighting + Emission + Fog + etc.
/// @return         Final HDR output color with alpha opacity.
half4 aForwardColor(
    ASurface s,
    half3 color)
{
    half4 output;

#if defined(A_ALPHA_BLENDING_PASS) && defined(A_ALPHA_BLENDING_ON)
    output.a = s.opacity;
#else
    UNITY_OPAQUE_ALPHA(output.a);
#endif

    output.rgb = color;
    aColorShader(output, s);
    return aHdrClamp(output);
}

/// Calculates forward lighting from surface and vertex data.
/// @param  i           Vertex to fragment transfer data.
/// @param  facingSign  Sign of front/back facing direction.
/// @return             Forward direct and indirect lighting.
half4 aForwardLitColorShader(
    AFragmentInput i,
    half facingSign)
{
    half3 illum = 0.0h;
    ASurface s = aForwardSurface(i, facingSign);

#ifdef A_LIGHTING_ON
    half shadow = UNITY_SHADOW_ATTENUATION(i, s.positionWorld);

    #ifdef A_INDIRECT_ON
        UnityGI gi = aFragmentGi(i, s, shadow);

        illum = aUnityIndirectLighting(gi, s);

        // Extract shadow with combined baked occlusion.
        #ifdef HANDLE_SHADOWS_BLENDING_IN_GI
            shadow = gi.light.color.g;
        #endif
    #endif

    // Do lightmap shadow mixing guard here, since we need direct vertex data.
    #if defined(A_DIRECT_ON) && !defined(A_LIGHTMAP_SHADOW_MIXING_ON)
        // Reduce v2f transfer cost for pure directional lights.
        #if defined(DIRECTIONAL)
            illum += aUnityDirectLighting(s, shadow, _WorldSpaceLightPos0, A_ZERO4);
        #elif defined(DIRECTIONAL_COOKIE)
            illum += aUnityDirectLighting(s, shadow, _WorldSpaceLightPos0, i.lightCoord);
        #else
            illum += aUnityDirectLighting(s, shadow, i.lightVectorRange, i.lightCoord);
        #endif
    #endif
#endif

#if defined(A_BASE_PASS) && defined(A_EMISSIVE_COLOR_ON)
    illum += s.emissiveColor;
#endif

    return aForwardColor(s, illum);
}

/// Creates a G-Buffer from the provided surface data.
/// @param  i           Vertex to fragment transfer data.
/// @param  facingSign  Sign of front/back facing direction.
/// @return             G-buffer with surface data and ambient illumination.
AGbuffer aForwardLitGbufferShader(
    AFragmentInput i,
    half facingSign)
{
    half3 illum = 0.0h;
    AGbuffer gb = aNewGbuffer();
    ASurface s = aForwardSurface(i, facingSign);

#ifdef A_INDIRECT_ON
    illum += aUnityIndirectLighting(aFragmentGi(i, s, 1.0h), s);

    // Baked direct lighting occlusion if any.
    #ifdef A_SHADOW_MASKS_BUFFER_ON
        gb.shadowMasks = UnityGetRawBakedOcclusions(i.giData.xy, s.positionWorld);
    #endif
#endif

#ifdef A_EMISSIVE_COLOR_ON
    illum += s.emissiveColor;
#endif

#if defined(A_INDIRECT_ON) || defined(A_EMISSIVE_COLOR_ON)
    illum = aHdrClamp(illum);
#endif
    
#ifndef UNITY_HDR_ON
    illum = exp2(-illum);
#endif

    gb.diffuseOcclusion = half4(s.albedo, s.specularOcclusion);
    gb.specularSmoothness = half4(s.f0, 1.0h - s.roughness);
    gb.normalType = half4(s.normalWorld * 0.5h + 0.5h, s.materialType);
    gb.emissionSubsurface = half4(illum, s.subsurface);
    aGbufferShader(gb, s);
    return gb;
}

#endif // ALLOY_SHADERS_FRAMEWORK_FORWARD_CGINC
