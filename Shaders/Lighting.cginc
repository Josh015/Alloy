// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Lighting.cginc
/// @brief Unity lighting callbacks and related functions.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_LIGHTING_CGINC
#define ALLOY_LIGHTING_CGINC

#include "Assets/Alloy/Shaders/Core.cginc"

/// Used to pass material data to Unity's lighting pipeline via reserved fields. 
/// The surface shader should never modify this directly.
struct AlloySurfaceOutput {	
	/// Controls translucency or cutout regions.
	/// Expects values in the range [0,1].
	half Alpha;
	
	/// Glossiness value, where 1 is more smooth.
	/// Expects values in the range [0,1].
	half Specular;
	
	/// Specular occlusion for direct and ambient illumination.
	/// Expects values in the range [0,1].
	half SpecularOcclusion;
	
	/// Diffuse albedo.
	/// Expects linear-space LDR color values.
	half3 Albedo;
	
	/// Tangent space normal.
	/// Expects normalized vectors in the range [-1,1].
	half3 Normal;
	
	/// Light emission by the material.
	/// Expects linear-space HDR color values.
	half3 Emission;
	
	/// Specular Color.
	/// Expects linear-space LDR color values.
	half3 SpecularColor;
	
	/// Used to pass ambient BRDF illumination to the lightmap functions.
	/// Expects linear-space HDR color values.
	half3 AmbientBrdf;
};

#include "Assets/Alloy/Shaders/Ambient.cginc"


//-----------------------------------------------------------------------------
// Surface Shader functions
//-----------------------------------------------------------------------------

/// Populates the SurfaceOutput struct with energy-conserving material data.
/// @param[in] 		alpha		Translucency.
/// @param[in] 		baseColor	Base LDR color.
/// @param[in] 		material	Metallic, occlusion, specularity, roughness.
/// @param[in] 		normalTs	Normalized tangent space normal.
/// @param[in] 		emission	Emission HDR color.
/// @param[in] 		ndv			Normal and view vector dot product.
/// @param[in,out] 	o			Surface output.
void AlloySurface(
	half alpha,
	half3 baseColor, 
	half4 material, 
	half3 normalTs, 
	half3 emission, 
	half ndv, 
	inout AlloySurfaceOutput o) 
{
	half metal = material.x;
	half invMetal = 1.0h - metal;
	half spec = material.z * ALLOY_SPECULAR_INTENSITY_MAX;
	half invSpec = 1.0h - spec;
	
	// Diffuse "fresnel" approximated here for little visual difference.
	// Monochrome scale makes dielectric + metallic blends look nicer.
	o.Albedo		= baseColor * (invSpec * invMetal);
	o.SpecularColor	= lerp(spec.rrr, baseColor, metal);
	
#if defined(_TRANSMODE_TRANSLUCENT)
	// Interpolate from a translucent dielectric to an opaque conductor.
	o.Alpha = metal + invMetal * (spec + invSpec * alpha);
	
	// Premultiply alpha with albedo for translucent shaders.
	o.Albedo *= alpha;
#else
	// NOTE: This must ALWAYS output alpha to work with Candela!
	o.Alpha = alpha;
#endif
	
	// Specular Occlusion
	o.SpecularOcclusion = AlloyGotandaSpecularOcclusion(material.y, ndv);
	
	// Pass-through values
	o.Specular = material.w;
	o.Normal = normalTs; 
	o.Emission = emission;
}


//-----------------------------------------------------------------------------
// Unity lighting callback functions
//-----------------------------------------------------------------------------

half4 LightingAlloyBrdf(
	AlloySurfaceOutput s, 
	half3 lightDir, 
	half3 viewDir, 
	half atten) 
{
	half4 c;
	half3 Nn = s.Normal;
	half3 Hn = normalize(lightDir + viewDir);
	half ndl = max(0.0h, dot(Nn, lightDir));
	half ndh = max(0.0h, dot(Nn, Hn));
	half ldh = max(0.0h, dot(lightDir, Hn));
	half gloss = s.Specular;
	half3 f = AlloySchlickFresnel(s.SpecularColor, ldh);
	half d = AlloyNormalizedBlinnPhongDistribution(gloss, ndh);
	half v = AlloyLazarovVisibility(gloss, ldh);
		
	// Use the punctual lighting equation to correctly attenuate specular.
	// 2.0 for the range Unity expects.
	c.rgb =  _LightColor0.rgb * (2.0h * atten * ndl) * (
				s.Albedo +
                f * (d * v * s.SpecularOcclusion));
                
	// Required in order to support alpha-blending?
    c.a = s.Alpha;
	return c;
}

half4 LightingAlloyBrdf_PrePass(
	AlloySurfaceOutput s, 
	half4 light) 
{
	// Applies normalization factor here to ease precision needs of the light
	// accumulation buffer. Also ensures a better preview in the editor view
	// where a low-precision bufffer is unavoidable.
	half dv = AlloyBlinnPhongNormalization(s.Specular) * light.a; 
	half3 f = s.SpecularColor;
	half4 c;
	
	// Combine chromaticity of diffuse lighting with accumulated light color
	// luminance in specular to approximate specular light color.
	// http://www.realtimerendering.com/blog/deferred-lighting-approaches/
	c.rgb = (s.Albedo * light.rgb + 
      		f * (dv * s.SpecularOcclusion) * AlloyChromaticity(light.rgb));
	
	// Not really needed, but here just to be safe.
	c.a = s.Alpha;
	return c;
}

// HACK: Uses "inout" to accumulate the lighting in the SurfaceOutput.Emission
// field. Then zero out the return value to ensure nothing gets passed through
// the _PrePass callback in deferred mode. This way, we don't contaminate the
// recovered specular lighting color, or have weird specular results.
half4 LightingAlloyBrdf_SingleLightmap(
	inout AlloySurfaceOutput s, 
	fixed4 color) 
{
  	half3 lm = DecodeLightmap(color);
  	
	s.Emission += lm * s.AmbientBrdf;
	return 0.0h;
}

half4 LightingAlloyBrdf_DualLightmap(
	inout AlloySurfaceOutput s, 
	fixed4 totalColor, 
	fixed4 indirectOnlyColor, 
	half indirectFade) 
{
	half3 lm = lerp(DecodeLightmap(indirectOnlyColor), DecodeLightmap(totalColor), indirectFade);
  	
	s.Emission += lm * s.AmbientBrdf;
	return 0.0h;
}

half4 LightingAlloyBrdf_DirLightmap(
	inout AlloySurfaceOutput s, 
	fixed4 color, 
	fixed4 scale, 
	bool surfFuncWritesNormal) 
{
	UNITY_DIRBASIS;
	half3 scalePerBasisVector;
	half3 lm = DirLightmapDiffuse(unity_DirBasis, color, scale, s.Normal, surfFuncWritesNormal, scalePerBasisVector);
  	
	s.Emission += lm * s.AmbientBrdf;
	return 0.0h;
}

#endif // ALLOY_LIGHTING_CGINC
