// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Decode.cginc
/// @brief Deferred decode light buffer pass vertex & fragment shaders.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFERRED_DECODE_CGINC
#define ALLOY_SHADERS_DEFERRED_DECODE_CGINC

sampler2D _LightBuffer;

struct AFragmentInput {
    float4 vertex : SV_POSITION;
    float2 texcoord : TEXCOORD0;
};

AFragmentInput aMainVertexShader(
    float4 vertex : POSITION, 
    float2 texcoord : TEXCOORD0)
{
    AFragmentInput o;
    o.vertex = UnityObjectToClipPos(vertex);
    o.texcoord = texcoord.xy;
#ifdef UNITY_SINGLE_PASS_STEREO
    o.texcoord = TransformStereoScreenSpaceTex(o.texcoord, 1.0f);
#endif
    return o;
}

fixed4 aMainFragmentShader(
    AFragmentInput i) : SV_Target
{
    return -log2(tex2D(_LightBuffer, i.texcoord));
}

#endif // ALLOY_SHADERS_DEFERRED_DECODE_CGINC
