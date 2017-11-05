// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Rsrm.cginc
/// @brief Radially Symmetric Reflection Map ambient lighting.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_RSRM_CGINC
#define ALLOY_RSRM_CGINC

#include "Assets/Alloy/Shaders/Core.cginc"

#if defined(_ENVIRONMENTMAPMODE_RSRM) || defined(_ENVIRONMENTMAPMODE_RSRMCUBE)
	sampler2D _Rsrm;

	#if defined(_ENVIRONMENTMAPMODE_RSRMCUBE)
		float _CubeExposureBoost;
		samplerCUBE _Cube;
	#endif
#endif

/// Radially Symmetric Reflection Map ambient lighting.
/// @param[in] 		ao 				Ambient occlusion.
/// @param[in] 		occludedAlbedo	Occluded albedo LDR color.
/// @param[in] 		specularColor	Specular LDR color.
/// @param[in] 		normalWs		World space normal.
/// @param[in] 		reflectionWs	World space reflection vector.
/// @param[in] 		ndv				Normal and view vector dot product.
/// @param[in,out] 	o				Surface output.
void AlloyRsrm( 
	half ao, 
	half3 occludedAlbedo, 
	half3 specularColor, 
	half3 normalWs, 
	half3 reflectionWs, 
	half ndv, 
	inout AlloySurfaceOutput o) 
{
#if defined(_ENVIRONMENTMAPMODE_RSRM) || defined(_ENVIRONMENTMAPMODE_RSRMCUBE)
  	half3 worldNn = normalize(normalWs);
  	half3 worldRn = normalize(reflectionWs);
  	half ndu = dot(worldNn, ALLOY_WORLD_UP_DIRECTION) * 0.5h + 0.5h;
    half rdu = dot(worldRn, ALLOY_WORLD_UP_DIRECTION) * 0.5h + 0.5h;
    half gloss = o.Specular; 
    
    // Use RSRM normalized spec power one as diffuse.
    half3 diffuse = tex2D(_Rsrm, float2(ndu, 0.0f)).rgb;
    
    // Sample RSRM specular, then restore to original range (assumes linear colors).
    half4 rsrm = tex2D(_Rsrm, float2(rdu, gloss));
    half3 specular = rsrm.rgb * rsrm.a;
	
	#if defined(_ENVIRONMENTMAPMODE_RSRMCUBE)
		// Use the non-normalized reflection for best sampling results.
		half3 cube = AlloyGammaToLinearFast(_CubeExposureBoost) * texCUBE(_Cube, reflectionWs).rgb;
		
		// HACK: Something to try to make the cube and RSRM blend more naturally.
		half interpolation = saturate(max(ALLOY_EPSILON, gloss - 0.25h) / 0.75h);
	    specular = lerp(specular, cube, interpolation);
	#endif 
		
	half so = o.SpecularOcclusion;
	half3 specularColorAo = specularColor * ao;
	half3 fdv = specular * AlloyLazarovAmbientBrdf(specularColor, o.Specular, ndv);
		
	#if defined(ALLOY_NO_LIGHTMAP_BRDF) || (defined(LIGHTMAP_OFF) && defined(DIRLIGHTMAP_OFF))
		// Ambient lighting contributions
		half3 diffuseAmbient =  diffuse * ShadeSH9(float4(worldNn, 1.0f));
		half3 specularAmbient = fdv * ShadeSH9(float4(worldRn, 1.0f));

		// Needs 2.0 to correct the light probes to the range Unity expects.
		o.Emission += 2.0h * (
				     occludedAlbedo * diffuseAmbient +
				     lerp(specularColorAo * diffuseAmbient, specularAmbient, so));
	#elif !defined(ALLOY_NO_LIGHTMAP_BRDF)
		// Ambient BRDF data for use in lightmapping callbacks.
		o.AmbientBrdf = occludedAlbedo * diffuse + 
						lerp(specularColorAo * diffuse, fdv, so);
	#endif
#endif
}
	
#endif // ALLOY_RSRM_CGINC
