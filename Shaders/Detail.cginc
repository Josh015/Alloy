// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Detail.cginc
/// @brief Surface detail materials.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_DETAIL_CGINC
#define ALLOY_DETAIL_CGINC

#include "Assets/Alloy/Shaders/Utility.cginc"

#if defined(_DETAILMODE_TEAMCOLOR)
	sampler2D _TeamColorMaskMap;
	float4 _TeamColor0;
	float4 _TeamColor1;
	float4 _TeamColor2;
	float4 _TeamColor3;
#elif defined(_DETAILMODE_DECAL)
	sampler2D _DecalTex;
	sampler2D _DecalTexMaterialMap;
	sampler2D _DecalTexBumpMap;
	float4 _DecalTexOffset;
#elif defined(_DETAILMODE_DETAIL)
	sampler2D _Detail; 
	sampler2D _DetailMaterialMap;
	sampler2D _DetailBumpMap;
	float4 _DetailOffset;
#endif

void AlloyDetails(float2 baseUv, float2 offset, inout half4 base, inout half4 material, inout half3 normalTs) {
#if defined(_DETAILMODE_DECAL) || defined(_DETAILMODE_DETAIL) || defined(_DETAILMODE_TEAMCOLOR)
	float2 detailUv;
	half3 detailNormalTs;
	half4 detailMaterial;
	
	#if defined(_DETAILMODE_TEAMCOLOR)
		half3 teamColor = half3(1.0h, 1.0h, 1.0h);
		half4 mask = tex2D(_TeamColorMaskMap, baseUv + offset);
		teamColor = lerp(teamColor, _TeamColor0.rgb, mask.r);
		teamColor = lerp(teamColor, _TeamColor1.rgb, mask.g);
		teamColor = lerp(teamColor, _TeamColor2.rgb, mask.b);
		base.rgb *= lerp(teamColor, _TeamColor3.rgb, mask.a);
    #elif defined(_DETAILMODE_DECAL)
    	detailUv = baseUv * _DecalTexOffset.xy + _DecalTexOffset.zw + offset;
    	detailNormalTs = UnpackNormal(tex2D(_DecalTexBumpMap, detailUv));
		detailMaterial = tex2D(_DecalTexMaterialMap, detailUv);
			
    	half4 decal = tex2D(_DecalTex, detailUv);
    	base.rgb = lerp(base.rgb, decal.rgb, decal.a);
    #elif defined(_DETAILMODE_DETAIL)
    	detailUv = baseUv * _DetailOffset.xy + _DetailOffset.zw + offset;
    	detailNormalTs = UnpackNormal(tex2D(_DetailBumpMap, detailUv));
		detailMaterial = tex2D(_DetailMaterialMap, detailUv);
		base.rgb *= tex2D(_Detail, detailUv).rgb;
    #endif
    
    #if defined(_DETAILMODE_DECAL) || defined(_DETAILMODE_DETAIL)
	    // Normals
		normalTs = AlloyCombineNormals(normalTs, detailNormalTs);
		
		// Gloss adjustment
		half sp = exp2(material.w * 11.0h);
		sp = 1.0h / ((1.0h / sp) + detailMaterial.a);
		material.w = log2(sp) / 11.0h;
		
		// AO
	    material.y *= detailMaterial.y;
    #endif
#endif
} 

#endif // ALLOY_DETAIL_CGINC
