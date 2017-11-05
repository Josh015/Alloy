// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Add.cginc
/// @brief Forward add lighting pass vertex & fragment shaders.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FORWARD_ADD_CGINC
#define ALLOY_SHADERS_FORWARD_ADD_CGINC

#define A_TESSELLATION_PASS
#define A_NORMAL_MAPPED_PASS
#define A_PARALLAX_MAPPED_PASS
#define A_DIRECT_LIGHTING_PASS
#define A_VOLUMETRIC_PASS
#define A_ALPHA_BLENDING_PASS

#include "Assets/Alloy/Shaders/Framework/Forward.cginc"

void aMainVertexShader(
    AVertexInput v,
    out AFragmentInput o,
    out float4 opos : SV_POSITION)
{
    aForwardVertexShader(v, o, opos);
}

half4 aMainFragmentShader(
    AFragmentInput i
    A_FACING_SIGN_PARAM) : SV_Target
{
    return aForwardLitColorShader(i, A_FACING_SIGN);
}			
            
#endif // ALLOY_SHADERS_FORWARD_ADD_CGINC
