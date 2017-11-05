// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Hidden/Alloy/Deferred Skin" {
Properties {
    _LightTexture0 ("", any) = "" {}
    _LightTextureB0 ("", 2D) = "" {}
    _ShadowMapTexture ("", any) = "" {}
    _SrcBlend ("", Float) = 1
    _DstBlend ("", Float) = 1
}
SubShader {
    // Pass 1: Lighting pass
    //  LDR case - Lighting encoded into a subtractive ARGB8 buffer
    //  HDR case - Lighting additively blended into floating point buffer
    Pass {
        ZWrite Off
        Blend [_SrcBlend] [_DstBlend]

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers nomrt
        
        #pragma multi_compile_lightpass
        #pragma multi_compile ___ UNITY_HDR_ON

        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader

        #define A_SUBSURFACE_ON
        #define A_SCATTERING_ON

        #include "Assets/Alloy/Shaders/Deferred/Light.cginc"
        #include "Assets/Alloy/Shaders/Lighting/Standard.cginc"

        ENDCG
    }

    // Pass 2: Final decode pass.
    // Used only with HDR off, to decode the logarithmic buffer into the main RT
    Pass {
        ZTest Always 
        Cull Off 
        ZWrite Off
        Stencil {
            ref [_StencilNonBackground]
            readmask [_StencilNonBackground]
            // Normally just comp would be sufficient, but there's a bug and only front face stencil state is set (case 583207)
            compback equal
            compfront equal
        }

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers nomrt

        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader

        #include "Assets/Alloy/Shaders/Deferred/Decode.cginc"

        ENDCG 
    }
}
Fallback Off
}
