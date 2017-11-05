// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Distort.cginc
/// @brief Distort shader inputs and entry points.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_DISTORT_CGINC
#define ALLOY_DISTORT_CGINC

#include "UnityCG.cginc"
#include "Assets/Alloy/Shaders/Utility.cginc"

struct AlloyDistortV2F {
	float4 VertexPs : POSITION;
    float3 NormalPs : TEXCOORD0;
	float4 GrabUv : TEXCOORD1;
	float2 BaseUv : TEXCOORD2;
};

float4 _MainTex_ST;

AlloyDistortV2F AlloyDistortVertex(
	appdata_base v)
{
	AlloyDistortV2F o;
	float4 vertexPs = mul(UNITY_MATRIX_MVP, v.vertex);
	
	o.VertexPs = vertexPs;
    o.NormalPs = mul((float3x3)UNITY_MATRIX_MVP, v.normal);
    
#if UNITY_UV_STARTS_AT_TOP
	float scale = -1.0f;
#else
	float scale = 1.0f;
#endif

	o.GrabUv.xy = (float2(vertexPs.x, vertexPs.y * scale) + vertexPs.w) * 0.5f;
	o.GrabUv.zw = vertexPs.zw;
	o.BaseUv = TRANSFORM_TEX(v.texcoord, _MainTex);
	return o;
}

float _DistortWeight;
float _DistortIntensity;
float _DistortGeoWeight;

float4 _Color;
sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _GrabTexture;
float4 _GrabTexture_TexelSize;

half4 AlloyDistortFragment(
	AlloyDistortV2F IN) : COLOR
{
	float4 grabUv = IN.GrabUv;
	float2 baseUv = IN.BaseUv;
	
	// Combine normals.
    half3 normalPs = normalize(IN.NormalPs);
	half3 detailNormalTs = UnpackNormal(tex2D(_BumpMap, baseUv));
	half3 combinedNormals = AlloyCombineNormals(normalPs, detailNormalTs);
	combinedNormals = lerp(detailNormalTs, combinedNormals, _DistortGeoWeight);
	
	// Calculate perturbed coordinates.
	float2 offset = combinedNormals.xy * _DistortWeight * _DistortIntensity * _GrabTexture_TexelSize.xy;
	grabUv.xy = offset * grabUv.z + grabUv.xy;
	
	// Sample and combine textures.
	half4 refr = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(grabUv));
	half4 col = _Color * tex2D(_MainTex, baseUv);	 
	return half4(col.rgb * refr.rgb, 1.0h);
}

#endif // ALLOY_DISTORT_CGINC
