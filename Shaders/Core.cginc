// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Core.cginc
/// @brief BRDF constants and functions.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_CORE_CGINC
#define ALLOY_CORE_CGINC

#include "Assets/Alloy/Shaders/Utility.cginc"

/// Used to clamp max HDR shader final color.
#define ALLOY_MAX_HDR_INTENSITY 20.0h

/// Maximum linear space specular intensity to remap the range of values [0,1].
#define ALLOY_SPECULAR_INTENSITY_MAX 0.08h

/// Used in spherical gaussian Blinn Phong to modify specular power.
#define ALLOY_LOG2_OF1_ON_LN2_PLUS2 2.528766h

/// Used in spherical gaussian Blinn Phong to adjust normalization factor.
#define ALLOY_LN2_DIV8 0.08664h

/// Calculates direct lighting fresnel.
/// @param 	Ks	Specular intensity. 
/// @param 	ldh	Light and half-angle vector dot product.
/// @return		Direct lighting fresnel.
half AlloySchlickFresnel(
	half Ks,  
	half ldh) 
{
	// Spherical gaussian approximation as proposed by:
	// http://seblagarde.wordpress.com/2011/08/17/hello-world/
	half sphg = exp2((-5.55473h * ldh - 6.98316h) * ldh);
		
	return Ks + (1.0h - Ks) * sphg;
}

/// Calculates direct lighting fresnel.
/// @param 	Ks	Specular color. 
/// @param 	ldh	Light and half-angle vector dot product.
/// @return		Direct lighting fresnel.
half3 AlloySchlickFresnel(
	half3 Ks,  
	half ldh) 
{
	// Spherical gaussian approximation as proposed by:
	// http://seblagarde.wordpress.com/2011/08/17/hello-world/
	half sphg = exp2((-5.55473h * ldh - 6.98316h) * ldh);
		
	return Ks + (half3(1.0h, 1.0h, 1.0h) - Ks) * sphg;
}

/// Calculates ambient fresnel with a visibility approximation.
/// @param 	Ks		Specular color. 
/// @param 	gloss	Surface glossiness.
/// @param 	ndv		Normal and view vector dot product.
/// @return			Ambient fresnel with visibility.
half3 AlloyLazarovAmbientBrdf(
	half3 Ks, 
	half gloss, 
	half ndv) 
{
	// Spherical gaussian approximation as proposed by:
	// http://seblagarde.wordpress.com/2011/08/17/hello-world/
	half sphg = exp2((-5.55473h * ndv - 6.98316h) * ndv);
	
	// Visibility approximation as proposed by:
	// http://blog.selfshadow.com/publications/s2013-shading-course/lazarov/s2013_pbs_black_ops_2_notes.pdf
	half v = (4.0h - 3.0h * gloss);
	
	return Ks + (half3(1.0h, 1.0h, 1.0h) - Ks) * (sphg / v);
}

/// Builds the Blinn Phong normalization factor from surface glossiness.
/// This is useful in the context of a Light PrePass renderer with a
/// low-precision light accumulation buffer, since it moves the HDR 
/// component to the combine pass.
/// @param 	gloss 	Surface glossiness.
/// @return			Blinn Phong distribution normalization factor.
half AlloyBlinnPhongNormalization(
	half gloss) 
{
	// Premultiply 1/4 from the Torrance-Sparrow microfacet BRDF equation,  
	// and cancel Pi from the punctual lighting equation:
	// http://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/

	// Uses a 4x specular power to make Blinn Phong's highlights' shape consistent 
	// with Phong IBL.
	// http://seblagarde.wordpress.com/2012/03/29/relationship-between-phong-and-blinn-lighting-model/
	half sp = exp2(gloss * 11.0h + 2.0h); // [4,8192]
	return (sp * 0.125h + 0.25h); // (sp + 2) / 8
}

/// Builds the Blinn Phong NDF.
/// This is useful in the context of a Light PrePass renderer with a
/// low-precision light accumulation buffer, since it moves the HDR 
/// component out of the lighting pass.
/// @param 	gloss 	Surface glossiness.
/// @param 	ndh 	Normal and half-angle vector dot product.
/// @return			Blinn Phong distribution without normalization.
half AlloyBlinnPhongDistribution(
	half gloss,
	half ndh) 
{
	// Uses a 4x specular power to make Blinn Phong's highlights consistent 
	// with Phong IBL.
	// http://seblagarde.wordpress.com/2012/03/29/relationship-between-phong-and-blinn-lighting-model/

	// Spherical gaussian approximation to Blinn Phong as proposed by:
	// http://seblagarde.wordpress.com/2011/08/17/hello-world/
	half sp = exp2(gloss * 11.0h + ALLOY_LOG2_OF1_ON_LN2_PLUS2); // [4,8192]
	return exp2(sp * ndh - sp);
}

/// Builds the Normalized Blinn Phong BRDF NDF.
/// @param 	gloss 	Surface glossiness.
/// @param 	ndh 	Normal and half-angle vector dot product.
/// @return			Normalized Blinn Phong distribution.
half AlloyNormalizedBlinnPhongDistribution(
	half gloss,
	half ndh) 
{
	// Premultiply 1/4 from the Torrance-Sparrow microfacet BRDF equation, 
	// and cancel Pi from the punctual lighting equation:
	// http://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/

	// Uses a 4x specular power to make Blinn Phong's highlights consistent 
	// with Phong IBL.
	// http://seblagarde.wordpress.com/2012/03/29/relationship-between-phong-and-blinn-lighting-model/
	
	// Spherical gaussian approximation to Blinn Phong as proposed by:
	// http://seblagarde.wordpress.com/2011/08/17/hello-world/
	half sp = exp2(gloss * 11.0h + ALLOY_LOG2_OF1_ON_LN2_PLUS2); // [4,8192]
	return (sp * ALLOY_LN2_DIV8 + 0.25h) * exp2(sp * ndh - sp); // (sp + 2) / 8
}

/// An approximation of the Schlick visibility function.
/// @param 	gloss 	Surface glossiness.
/// @param 	ldh		Light and half-angle vector dot product.
/// @return			BRDF visibility.
half AlloyLazarovVisibility(
	half gloss,
	half ldh) 
{
	// Approximation to Schlick visibility function as proposed by:
	// http://blog.selfshadow.com/publications/s2013-shading-course/lazarov/s2013_pbs_black_ops_2_notes.pdf
	half k = min(1.0h - ALLOY_EPSILON, gloss + 0.545h);	
	return 1.0h / ((k * ldh * ldh) + (1.0h - k));
}

/// Calculates specular occlusion.
/// @param 	ao 	Ambient occlusion.
/// @param 	ndv	Normal and view vector dot product.
/// @return 	Specular occlusion.
half AlloyGotandaSpecularOcclusion(
	half ao, 
	half ndv) 
{
	// Specular occlusion approximation as proposed by:
	// http://research.tri-ace.com/Data/cedec2011_RealtimePBR_Implementation_e.pptx
	half d = ndv + ao;
	return saturate((d * d) - 1.0h + ao);
}

#endif // ALLOY_CORE_CGINC
