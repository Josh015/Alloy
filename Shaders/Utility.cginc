// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Utility.cginc
/// @brief Utility constants and functions.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_UTILITY_CGINC
#define ALLOY_UTILITY_CGINC

/// A value close to zero.
/// This is used for preventing NaNs in cases where you can divide by zero.
#define ALLOY_EPSILON 1e-6f

/// 
#define ALLOY_PI 3.14159265359f

/// Used to convert degrees to radians.
#define ALLOY_DEGREES_TO_RADIANS (ALLOY_PI / 180.0f)

/// Coefficients used to get a linear color's luminance.
#define ALLOY_LUMINANCE_COEFFICIENTS half3(0.2126h, 0.7152h, 0.0722h)

/// World-space normalized up vector.
#define ALLOY_WORLD_UP_DIRECTION half3(0.0h, 1.0h, 0.0h)

/// Converts a value from gamma space to linear-space using an approximation. 
/// Used for cases when you have a color scaling factor, so that it can have a 
/// perceptually linear gain in intensity. 
/// @param	c	Gamma-space scalar.
/// @return		Linear-space scalar.
half AlloyGammaToLinearFast(
	half c) 
{
	// Cubic approximation to the official sRGB curve.
  	// http://chilliant.blogspot.de/2012/08/srgb-approximations-for-hlsl.html
  	return c * (c * (c * 0.305306011h + 0.682171111h) + 0.012522878h);
}

/// Converts a color from gamma space to linear-space using an approximation. 
/// You should not need to use this, since Unity automatically converts colors 
/// from gamma space to linear space. 
/// @param	c	Gamma-space color.
/// @return		Linear-space color.
half3 AlloyGammaToLinearFast(
	half3 c) 
{
	// Cubic approximation to the official sRGB curve.
	// http://chilliant.blogspot.de/2012/08/srgb-approximations-for-hlsl.html
	return c * (c * (c * 0.305306011h + 0.682171111h) + 0.012522878h);
}

/// Calculates a linear color's luminance.
/// @param	c	Linear HDR color.
/// @return		Linear HDR luminance.
half AlloyLuminance(
	half3 c) 
{
	return dot(c, ALLOY_LUMINANCE_COEFFICIENTS);
}

/// Calculates a linear color's chromaticity.
/// @param	c	Linear HDR color.
/// @return		Color's chromaticity.
half3 AlloyChromaticity(
	half3 c) 
{
	return c / (AlloyLuminance(c) + ALLOY_EPSILON);
}

/// Used to calculate a rim light effect.
/// @param	Kr 		Rim HDR Color
/// @param	bias	Bias rim towards constant emission.
/// @param	power 	Rim falloff.
/// @param	ndv		Normal and view vector dot product.
/// @return 		Rim lighting.
half3 AlloyRimLight(
	half3 Kr, 
	half bias, 
	half power, 
	half ndv) 
{
	return Kr * (bias + (1.0h - bias) * pow(1.0h - ndv, power));
}

/// Combines two tangent-space normals while preserving details from both.
/// The two can be switched and produce the same result.
/// @param 	n1 	Normalized tangent space normal.
/// @param 	n2 	Normalized tangent space normal.
/// @return 	Combined normalized tangent space normal.
half3 AlloyCombineNormals(
	half3 n1, 
	half3 n2) 
{
	// Whiteout-style normal blending.
	// http://blog.selfshadow.com/publications/blending-in-detail/
	return normalize(half3(n1.xy + n2.xy, n1.z * n2.z));
}

#endif // ALLOY_UTILITY_CGINC
