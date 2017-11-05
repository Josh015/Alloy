// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Hidden/AlloyPassthroughBlit" {
    Properties {
        _MainTex ("Render Input", 2D) = "white" {}
    }
    SubShader {
        ZTest Always Cull Off ZWrite Off Fog { Mode Off }
        Pass {
            CGPROGRAM
                #pragma vertex vert_img
                #pragma fragment frag
                #include "UnityCG.cginc"
            
                sampler2D _MainTex;
                float _EditorIsLinear;
            
                float4 frag(v2f_img IN) : SV_Target {
                    half4 col = tex2D (_MainTex, IN.uv);

					if (_EditorIsLinear > 0.5f) {
						//Source: http://chilliant.blogspot.nl/2012/08/srgb-approximations-for-hlsl.html
						col = max(1.055f * pow(col, 0.416666667f) - 0.055f, 0);
					}

                    return col;
                }
            ENDCG
        }
    }
}