// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Hidden/Alloy Visualize" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Mode("Mode", Float) = 0
		_Trans("Trans", Vector) = (0, 0, 0, 0)
	}
	SubShader {
		Pass {
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				#pragma target 3.0
			
				struct v2f {
					float4 pos : SV_POSITION;
					float2 uv_MainTex : TEXCOORD0;
				};
			
				float4 _MainTex_ST;
				float _Mode;
			
				v2f vert(appdata_base v) {
					v2f o;

					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

					o.pos.w += 1e-5;

					o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
					return o;
				}
			
				sampler2D _MainTex;
				float4 _Trans;
			
				float4 frag(v2f IN) : COLOR {
					float4 c = tex2D (_MainTex, IN.uv_MainTex * _Trans.zw + _Trans.xy).rgba;
					float eps = 0.001f;

					if (_Mode <= eps){
						c.rgb = 0.0f;
					}
					else if (_Mode <= 1 + eps) {
						c.rgb = c.rgb; // Assumes automatic sRGB
					}
					else if (_Mode <= 2 + eps){
						c.rgb = pow(c.rrr, 2.2f);
					}
					else if (_Mode <= 3 + eps){
						c.rgb = pow(c.ggg, 2.2f);
					}
					else if (_Mode <= 4 + eps){
						c.rgb = pow(c.bbb, 2.2f);
					}
					else if (_Mode <= 5 + eps){
						c.rgb = pow(c.aaa, 2.2f);
					}
					else if (_Mode <= 6 + eps){
						c.rgb = pow(UnpackNormal(c) * 0.5f + 0.5f, 2.2f);
					}

					return c;
				}
			ENDCG
		}
	}
}