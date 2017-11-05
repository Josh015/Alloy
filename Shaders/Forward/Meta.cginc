// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Meta.cginc
/// @brief Forward meta pass vertex & fragment shaders.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FORWARD_META_CGINC
#define ALLOY_SHADERS_FORWARD_META_CGINC

#ifndef A_UV2_ON
    #define A_UV2_ON
#endif

#define A_BASE_PASS

#include "Assets/Alloy/Shaders/Framework/Forward.cginc"

#include "UnityMetaPass.cginc"

void aMainVertexShader(
    AVertexInput v,
    out AFragmentInput o,
    out float4 opos : SV_POSITION)
{
    aForwardVertexShader(v, o, opos);
    opos = UnityMetaVertexPosition(v.vertex, v.uv1.xy, v.uv2.xy, unity_LightmapST, unity_DynamicLightmapST);
}

float4 aMainFragmentShader(
    AFragmentInput i) : SV_Target
{
    UnityMetaInput o;
    ASurface s = aForwardSurface(i, 1.0h);

    UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

#if defined(EDITOR_VISUALIZATION)
    o.Albedo = s.albedo;
#else
    o.Albedo = s.albedo + (s.f0 * (s.beckmannRoughness * 0.5h));
#endif

    o.SpecularColor = s.f0;

#ifndef A_EMISSIVE_COLOR_ON
    o.Emission = A_BLACK;
#else
    o.Emission = aHdrClamp(s.emissiveColor);
#endif

    return UnityMetaFragment(o);
}
            
#endif // ALLOY_SHADERS_FORWARD_META_CGINC
