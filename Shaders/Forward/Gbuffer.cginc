// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Gbuffer.cginc
/// @brief Forward g-buffer fill pass vertex & fragment shaders.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FORWARD_GBUFFER_CGINC
#define ALLOY_SHADERS_FORWARD_GBUFFER_CGINC

#define A_BASE_PASS
#define A_TESSELLATION_PASS
#define A_INSTANCING_PASS
#define A_STEREO_INSTANCING_PASS
#define A_NORMAL_MAPPED_PASS
#define A_PARALLAX_MAPPED_PASS
#define A_INDIRECT_LIGHTING_PASS
#define A_GBUFFER_PASS

#include "Assets/Alloy/Shaders/Framework/Forward.cginc"

void aMainVertexShader(
    AVertexInput v,
    out AFragmentInput o,
    out float4 opos : SV_POSITION)
{
    aForwardVertexShader(v, o, opos);
}

AGbuffer aMainFragmentShader(
    AFragmentInput i
    A_FACING_SIGN_PARAM)
{
    return aForwardLitGbufferShader(i, A_FACING_SIGN);
}					
            
#endif // ALLOY_SHADERS_FORWARD_GBUFFER_CGINC
