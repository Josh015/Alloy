// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file ReflectionAdd.cginc
/// @brief Deferred reflection buffer add pass vertex & fragment shaders.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFERRED_REFLECTION_ADD_CGINC
#define ALLOY_SHADERS_DEFERRED_REFLECTION_ADD_CGINC

#include "UnityCG.cginc"

sampler2D _CameraReflectionsTexture;

struct AFragmentInput {
    float2 uv : TEXCOORD0;
    float4 pos : SV_POSITION;
};

AFragmentInput aMainVertexShader(
    float3 vertex : POSITION)
{
    AFragmentInput o;
    o.pos = UnityObjectToClipPos(vertex);
    o.uv = ComputeScreenPos(o.pos).xy;
    return o;
}

half4 aMainFragmentShader(
    AFragmentInput i) : SV_Target
{
    half4 c = tex2D(_CameraReflectionsTexture, i.uv);
#ifdef UNITY_HDR_ON
    return float4(c.rgb, 0.0f);
#else
    return float4(exp2(-c.rgb), 0.0f);
#endif
}

#endif // ALLOY_SHADERS_DEFERRED_REFLECTION_ADD_CGINC
