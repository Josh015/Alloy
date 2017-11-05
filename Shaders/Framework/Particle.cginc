// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Particle.cginc
/// @brief Particles uber-header.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_PARTICLE_CGINC
#define ALLOY_SHADERS_FRAMEWORK_PARTICLE_CGINC

#include "Assets/Alloy/Shaders/Config.cginc"
#include "Assets/Alloy/Shaders/Framework/Utility.cginc"

#include "HLSLSupport.cginc"
#include "UnityCG.cginc"
#include "UnityInstancing.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityStandardUtils.cginc"
#include "UnityShaderVariables.cginc"

struct AVertexInput {
    float4 vertex : POSITION;
    float4 color : COLOR;
    float4 texcoords : TEXCOORD0;
#ifdef A_PARTICLE_TEXTURE_BLEND_ON
    float texcoordBlend : TEXCOORD1;
#endif
#if defined(_RIM_FADE_ON) || defined(A_PARTICLE_LIGHTING_ON)
    half3 normal : NORMAL;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct AFragmentInput {
    float4 vertex : SV_POSITION;
    float4 color : COLOR;
    float4 texcoords : TEXCOORD0;
#ifdef _PARTICLE_EFFECTS_ON
    float2 uv_ParticleEffectMask1 : TEXCOORD1;
    float2 uv_ParticleEffectMask2 : TEXCOORD2;
#endif
    UNITY_FOG_COORDS(3)
#if defined(SOFTPARTICLES_ON) || defined(_DISTANCE_FADE_ON) || defined(VTRANSPARENCY_ON)
    float4 projPos : TEXCOORD4;
#endif
#if defined(_RIM_FADE_ON) || defined(A_PARTICLE_LIGHTING_ON)
    half3 normalWorld : TEXCOORD5;
    half4 viewDirWorld : TEXCOORD6;
#endif
#if defined(A_PARTICLE_LIGHTING_ON) || defined(VAPOR_TRANSLUCENT_FOG_ON)
    float4 positionWorld : TEXCOORD7;
#endif
#if defined(A_PARTICLE_LIGHTING_ON)
    half3 ambient : TEXCOORD8;
#endif
#ifdef A_PARTICLE_TEXTURE_BLEND_ON
    float blend : TEXCOORD9;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

half4 _TintColor;
A_SAMPLER_2D(_MainTex);	
half _TintWeight;
float _InvFade;

#ifdef _PARTICLE_EFFECTS_ON
    A_SAMPLER_2D(_ParticleEffectMask1);
    A_SAMPLER_2D(_ParticleEffectMask2);
#endif

#ifdef _RIM_FADE_ON
    half _RimFadeWeight; // Expects linear-space values
    half _RimFadePower;
#endif

float _DistanceFadeNearFadeCutoff;
float _DistanceFadeRange;

AFragmentInput aMainVertexShader(
    AVertexInput v)
{
    AFragmentInput o;
    UNITY_INITIALIZE_OUTPUT(AFragmentInput, o);               
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    
    o.vertex = UnityObjectToClipPos(v.vertex.xyz);

#if defined(SOFTPARTICLES_ON) || defined(_DISTANCE_FADE_ON) || defined(VTRANSPARENCY_ON)
    o.projPos = ComputeScreenPos (o.vertex);
    COMPUTE_EYEDEPTH(o.projPos.z);
#endif

    o.color = v.color;
    
#ifndef A_VERTEX_COLOR_DEGAMMA_OFF
    o.color.rgb = aGammaToLinear(o.color.rgb);
#endif
    
    o.texcoords.xy = A_TEX_TRANSFORM_SCROLL_SPIN(_MainTex, v.texcoords.xy);
    
#ifdef _PARTICLE_EFFECTS_ON
    o.uv_ParticleEffectMask1 = A_TEX_TRANSFORM_SCROLL_SPIN(_ParticleEffectMask1, v.texcoords.xy);
    o.uv_ParticleEffectMask2 = A_TEX_TRANSFORM_SCROLL_SPIN(_ParticleEffectMask2, v.texcoords.xy);
#endif

#if defined(_RIM_FADE_ON) || defined(A_PARTICLE_LIGHTING_ON) || defined(VAPOR_TRANSLUCENT_FOG_ON)
    float4 positionWorld = mul(unity_ObjectToWorld, v.vertex);
#endif

#if defined(_RIM_FADE_ON) || defined(A_PARTICLE_LIGHTING_ON)
    o.normalWorld = UnityObjectToWorldNormal(v.normal);
    o.viewDirWorld.xyz = UnityWorldSpaceViewDir(positionWorld.xyz);
#endif

#if defined(A_PARTICLE_LIGHTING_ON) || defined(VAPOR_TRANSLUCENT_FOG_ON)
    o.positionWorld = positionWorld;
#endif
#ifdef A_PARTICLE_LIGHTING_ON	
    // 1 Directional, 4 Point lights, and Light probes.
    o.ambient = _LightColor0.rgb * aDotClamp(_WorldSpaceLightPos0.xyz, o.normalWorld);
    o.ambient += aShade4PointLights(o.positionWorld.xyz, o.normalWorld);
    o.ambient += ShadeSHPerVertex(o.normalWorld, o.ambient);
#endif

#ifdef A_PARTICLE_TEXTURE_BLEND_ON
    o.texcoords.zw = A_TEX_TRANSFORM_SCROLL_SPIN(_MainTex, v.texcoords.zw);
    o.blend = v.texcoordBlend;
#endif
    
    UNITY_TRANSFER_FOG(o,o.vertex);
    return o;
}

/// Controls how the particle is faded out based on scene intersection, rim, 
/// and camera distance.
half aFadeParticle(
    AFragmentInput i)
{
    half fade = 1.0h;

    UNITY_SETUP_INSTANCE_ID(i);

#ifdef SOFTPARTICLES_ON
    float sceneZ = DECODE_EYEDEPTH(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
    float partZ = i.projPos.z;

    fade = saturate(_InvFade * (sceneZ - partZ));
#endif

#ifdef _DISTANCE_FADE_ON
    // Alpha clip.
    // cf http://wiki.unity3d.com/index.php?title=AlphaClipsafe
    fade *= saturate((i.projPos.z - _DistanceFadeNearFadeCutoff) / _DistanceFadeRange);
#endif

#ifdef _RIM_FADE_ON
    half3 normal = normalize(i.normalWorld);
    half3 viewDir = normalize(i.viewDirWorld.xyz);
    half NdotV = abs(dot(normal, viewDir));
    half bias = 1.0h - _RimFadeWeight;

    fade = aRimLight(fade, bias, _RimFadePower, 1.0h - NdotV);
#endif
    
    return fade;
}

/// Applies transforming effects mask textures to the particle.
half4 aParticleEffects(
    AFragmentInput i)
{
    half4 color = tex2D(_MainTex, i.texcoords.xy);

#ifdef A_PARTICLE_TEXTURE_BLEND_ON
    half4 color2 = tex2D(_MainTex, i.texcoords.zw);
    color = lerp(color, color2, i.blend);
#endif

    color.rgb *= _TintWeight;

#ifdef _PARTICLE_EFFECTS_ON
    color *= tex2D(_ParticleEffectMask1, i.uv_ParticleEffectMask1);
    color *= tex2D(_ParticleEffectMask2, i.uv_ParticleEffectMask2);
#endif

#ifdef A_PARTICLE_LIGHTING_ON	
    color.rgb *= ShadeSHPerPixel(i.normalWorld, i.ambient, i.positionWorld);
#endif

    return color;
}

half4 aParticleOutputBase(
    AFragmentInput i,
    half4 color)
{
    UNITY_APPLY_FOG_COLOR(i.fogCoord, color, unity_FogColor);

#if defined(VAPOR_TRANSLUCENT_FOG_ON)
    color = VaporApplyFog(i.positionWorld, color);
#elif defined(VTRANSPARENCY_ON)
    color = VolumetricTransparencyBase(color, i.projPos);
#endif

    color.rgb = aHdrClamp(color.rgb);
    return color;
}

half4 aParticleOutputAdd(
    AFragmentInput i,
    half4 color)
{
    UNITY_APPLY_FOG_COLOR(i.fogCoord, color, A_BLACK4);

#if defined(VAPOR_TRANSLUCENT_FOG_ON)
    color = VaporApplyFogAdd(i.positionWorld, color);
#elif defined(VTRANSPARENCY_ON)
    color = VolumetricTransparencyAdd(color, i.projPos);
#endif

    color.rgb = aHdrClamp(color.rgb);
    return color;
}

half4 aParticleOutputMultiply(
    AFragmentInput i,
    half4 color)
{
    UNITY_APPLY_FOG_COLOR(i.fogCoord, color, A_WHITE4);

#if defined(VAPOR_TRANSLUCENT_FOG_ON)
    color = VaporApplyFogFade(i.positionWorld, color, A_WHITE);
#elif defined(VTRANSPARENCY_ON)
//    color = VolumetricTransparencyAdd(color, i.projPos);
#endif

    color.rgb = aHdrClamp(color.rgb);
    return color;
}

#endif // ALLOY_SHADERS_FRAMEWORK_PARTICLE_CGINC
