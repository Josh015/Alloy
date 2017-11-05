// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Ambient.cginc
/// @brief Ambient abstraction functions.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_AMBIENT_CGINC
#define ALLOY_AMBIENT_CGINC

#include "Assets/Alloy/Shaders/Rsrm.cginc"
#include "Assets/Alloy/Shaders/Skyshop.cginc"

/// Encompasses all of Alloy's ambient lighting options.
/// This should ALWAYS be the final call of Alloy surface callbacks.
/// @param[in] 		ao 				Ambient occlusion.
/// @param[in] 		occludedAlbedo	Occluded albedo LDR color.
/// @param[in] 		specularColor	Specular LDR color.
/// @param[in] 		positionWs		World space position.
/// @param[in] 		normalWs		World space normal.
/// @param[in] 		reflectionWs	World space reflection vector.
/// @param[in] 		ndv				Normal and view vector dot product.
/// @param[in,out] 	o				Surface output.
void AlloyAmbientBrdf(
	half ao, 
	half3 occludedAlbedo, 
	half3 specularColor, 
	float3 positionWs, 
	half3 normalWs, 
	half3 reflectionWs, 
	half ndv, 
	inout AlloySurfaceOutput o) 
{
	AlloyRsrm(ao, occludedAlbedo, specularColor, normalWs, reflectionWs, ndv, o);
	AlloySkyshop(ao, occludedAlbedo, specularColor, positionWs, normalWs, reflectionWs, ndv, o);
}

#endif // ALLOY_AMBIENT_CGINC
