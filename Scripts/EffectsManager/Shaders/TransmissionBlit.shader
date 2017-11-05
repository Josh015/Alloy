// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Hidden/Alloy/Transmission Blit" {
Properties {
    _MainTex ("Render Input", 2D) = "white" {}
}
SubShader {
    ZTest Always 
    Cull Off 
    ZWrite Off 
    Fog { Mode Off }

    Pass {
        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        #pragma vertex vert_img
        #pragma fragment frag

        #include "UnityCG.cginc"
            
        sampler2D _MainTex;
        float4 _MainTex_ST;
            
        float4 frag(v2f_img IN) : SV_Target {
            return tex2Dlod(_MainTex, float4(UnityStereoScreenSpaceUVAdjust(IN.uv, _MainTex_ST), 0.0f, 0.0f));
        }
        ENDCG
    }
}
}