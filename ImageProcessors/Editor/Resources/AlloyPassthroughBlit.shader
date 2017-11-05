// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
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
			
				float4 frag(v2f_img IN) : COLOR {
					half4 c = tex2D (_MainTex, IN.uv);

					return c;
				}
			ENDCG
		}
	}
}