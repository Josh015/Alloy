// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Distort.cginc
/// @brief Forward distort pass vertex & fragment shaders.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FORWARD_DISTORT_CGINC
#define ALLOY_SHADERS_FORWARD_DISTORT_CGINC

#define A_TEXEL_SIZE(a) a##_TexelSize

#ifndef A_DISTORT_TEXTURE
    #define A_DISTORT_TEXTURE _GrabTexture
#endif

#define A_DISTORT_TEXTURE_TEXEL_SIZE A_TEXEL_SIZE(A_DISTORT_TEXTURE)

#define A_BASE_PASS
#define A_TESSELLATION_PASS
#define A_INSTANCING_PASS
#define A_STEREO_INSTANCING_PASS
#define A_NORMAL_MAPPED_PASS
#define A_PARALLAX_MAPPED_PASS
#define A_VOLUMETRIC_PASS

#define A_FORWARD_TEXCOORD0 float3 normalProjection : TEXCOORD0;
#define A_FORWARD_TEXCOORD1 float4 grabUv : TEXCOORD1;

#include "Assets/Alloy/Shaders/Framework/Forward.cginc"

/// Grab texture containing copy of the back buffer.
sampler2D A_DISTORT_TEXTURE;

/// Grab texture dimension info.
/// (x: 1 / width, y: 1 / height, z: width, w: height).
float4 A_DISTORT_TEXTURE_TEXEL_SIZE;

/// Weight of the distortion effect.
/// Expects values in the range [0,1].
float _DistortWeight;

/// Strength of the distortion effect.
/// Expects values in the range [0,128].
float _DistortIntensity;

/// Mesh normals influence on distortion.
/// Expects values in the range [0,1].
float _DistortGeoWeight;

void aMainVertexShader(
    AVertexInput v,
    out AFragmentInput o,
    out float4 opos : SV_POSITION)
{
    aForwardVertexShader(v, o, opos);
    o.normalProjection = mul((float3x3)UNITY_MATRIX_MVP, v.normal);

    // Until ComputeGrabScreenPos() is fixed, just directly pasted code here.
#if UNITY_UV_STARTS_AT_TOP
    float scale = -1.0;
#else
    float scale = 1.0;
#endif
    o.grabUv.xy = (float2(opos.x, opos.y * scale) + opos.ww) * 0.5;
    o.grabUv.zw = opos.zw;
}

half4 aMainFragmentShader(
    AFragmentInput i
    A_FACING_SIGN_PARAM) : SV_Target
{
    // Transfer instancing and stereo IDs.
    ASurface s = aForwardSurface(i, A_FACING_SIGN);

    // Adjust grab texture UVs and weight.
    i.grabUv.z = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.grabUv.z);

#if UNITY_SINGLE_PASS_STEREO
    i.grabUv.xy = TransformStereoScreenSpaceTex(i.grabUv.xy, i.grabUv.w);
#endif

    // Mesh normals distortion.
    // cf http://wiki.unity3d.com/index.php?title=Refraction
    float3 bump = s.normalTangent + i.normalProjection * abs(i.normalProjection);
    float2 offset = A_DISTORT_TEXTURE_TEXEL_SIZE.xy * lerp(s.normalTangent, bump, _DistortGeoWeight).xy;

    i.grabUv.xy += offset * (i.grabUv.z * _DistortWeight * _DistortIntensity);
    
    // Sample and combine textures.
    half3 refr = tex2Dproj(A_DISTORT_TEXTURE, UNITY_PROJ_COORD(i.grabUv)).rgb;
    return aForwardColor(s, s.baseColor * refr);
}

#endif // ALLOY_SHADERS_FORWARD_DISTORT_CGINC
