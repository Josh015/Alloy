// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Shadow.cginc
/// @brief Forward shadow pass vertex & fragment shaders.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FORWARD_SHADOW_CGINC
#define ALLOY_SHADERS_FORWARD_SHADOW_CGINC

// Do dithering for alpha blended shadows on SM3+/desktop;
// on lesser systems do simple alpha-tested shadows
#if defined(A_ALPHA_BLENDING_ON) && defined(UNITY_USE_DITHER_MASK_FOR_ALPHABLENDED_SHADOWS)
	#define UNITY_STANDARD_USE_DITHER_MASK 1
#endif

// Need to output UVs in shadow caster, since we need to sample texture and do clip/dithering based on it
#if !defined(INSTANCING_ON) && !defined(A_OPACITY_MASK_ON) && !defined(_ALPHATEST_ON) && !defined(A_ALPHA_BLENDING_ON)
    #define A_SURFACE_SHADER_OFF
#endif

// Has a non-empty shadow caster output struct (it's an error to have empty structs on some platforms...)
#if defined(V2F_SHADOW_CASTER_NOPOS_IS_EMPTY) && defined(A_SURFACE_SHADER_OFF)
    #define A_VERTEX_TO_FRAGMENT_OFF
#endif

#define A_TESSELLATION_PASS
#define A_INSTANCING_PASS

#ifdef UNITY_STEREO_INSTANCING_ENABLED
    #define A_STEREO_INSTANCING_PASS
#endif

#define A_FORWARD_TEXCOORD0 V2F_SHADOW_CASTER_NOPOS

#include "Assets/Alloy/Shaders/Framework/Forward.cginc"

#ifdef UNITY_STANDARD_USE_DITHER_MASK
    sampler3D _DitherMaskLOD;
#endif

// We have to do these dances of outputting SV_POSITION separately from the vertex shader,
// and inputting VPOS in the pixel shader, since they both map to "POSITION" semantic on
// some platforms, and then things don't go well.

void aMainVertexShader(
    AVertexInput v,
#ifndef A_VERTEX_TO_FRAGMENT_OFF
    out AFragmentInput o,
#endif
    out float4 opos : SV_POSITION)
{
#ifndef A_SURFACE_SHADER_OFF
    aForwardVertexShader(v, o, opos);
#endif
    TRANSFER_SHADOW_CASTER_NOPOS(o, opos) // Implicitly expects 'v' parameter.
}

half4 aMainFragmentShader(
#ifndef A_VERTEX_TO_FRAGMENT_OFF
    AFragmentInput i
#endif
#ifdef UNITY_STANDARD_USE_DITHER_MASK
    , UNITY_VPOS_TYPE vpos : VPOS
#endif
#ifndef A_VERTEX_TO_FRAGMENT_OFF
    A_FACING_SIGN_PARAM
#endif
    ) : SV_Target
{
#ifndef A_SURFACE_SHADER_OFF
    ASurface s = aForwardSurface(i, A_FACING_SIGN);
    
    #ifdef UNITY_STANDARD_USE_DITHER_MASK
        // Use dither mask for alpha blended shadows, based on pixel position xy
        // and alpha level. Our dither texture is 4x4x16.
        half alphaRef = tex3D(_DitherMaskLOD, float3(vpos.xy * 0.25f, s.opacity * 0.9375f)).a;
        clip(alphaRef - 0.01h);
    #endif
#endif

    SHADOW_CASTER_FRAGMENT(i)
}		
            
#endif // ALLOY_SHADERS_FORWARD_SHADOW_CGINC
