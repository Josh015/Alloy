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
#if !defined(A_OPACITY_MASK_ON) && !defined(_ALPHATEST_ON) && !defined(A_ALPHA_BLENDING_ON)
    #define A_SURFACE_SHADER_OFF
#endif

#define A_TESSELLATION_PASS
#define A_INSTANCING_PASS

#ifndef UNITY_STANDARD_USE_DITHER_MASK
    #define A_CROSSFADE_PASS
#endif

#define A_FORWARD_TEXCOORD0 V2F_SHADOW_CASTER_NOPOS

#include "Assets/Alloy/Shaders/Framework/Forward.cginc"

#ifdef UNITY_STANDARD_USE_DITHER_MASK
    sampler3D _DitherMaskLOD;
#endif

void aMainVertexShader(
    AVertexInput v,
    out AFragmentInput o)
{
    aForwardVertexShader(v, o);
    TRANSFER_SHADOW_CASTER_NOPOS(o, o.pos) // Implicitly expects 'v' parameter.
}

half4 aMainFragmentShader(
    AFragmentInput i
    A_FACING_SIGN_PARAM) : SV_Target
{    
    ASurface s = aForwardSurface(i, A_FACING_SIGN);

#ifdef UNITY_STANDARD_USE_DITHER_MASK
    // Use dither mask for alpha blended shadows, based on pixel position xy
    // and alpha level. Our dither texture is 4x4x16.
    #ifdef LOD_FADE_CROSSFADE
        alpha *= unity_LODFade.y;
    #endif

    half alphaRef = tex3D(_DitherMaskLOD, float3(i.pos.xy * 0.25f, s.opacity * 0.9375f)).a;
    clip(alphaRef - 0.01h);
#endif

    SHADOW_CASTER_FRAGMENT(i)
}		
            
#endif // ALLOY_SHADERS_FORWARD_SHADOW_CGINC
