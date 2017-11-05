/////////////////////////////////////////////////////////////////////////////////
/// @file Base.cginc
/// @brief Forward base lighting pass vertex & fragment shaders.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FORWARD_BASE_CGINC
#define ALLOY_SHADERS_FORWARD_BASE_CGINC

#define A_BASE_PASS
#define A_TESSELLATION_PASS
#define A_INSTANCING_PASS
#define A_NORMAL_MAPPED_PASS
#define A_PARALLAX_MAPPED_PASS
#define A_DIRECT_LIGHTING_PASS
#define A_INDIRECT_LIGHTING_PASS
#define A_VOLUMETRIC_PASS
#define A_ALPHA_BLENDING_PASS
#define A_CROSSFADE_PASS

#include "Assets/Alloy/Shaders/Framework/Forward.cginc"

void aMainVertexShader(
    AVertexInput v,
    out AFragmentInput o)
{
    aForwardVertexShader(v, o);
}

half4 aMainFragmentShader(
    AFragmentInput i
    A_FACING_SIGN_PARAM) : SV_Target
{
    return aForwardLitColorShader(i, A_FACING_SIGN);
}
            
#endif // ALLOY_SHADERS_FORWARD_BASE_CGINC
