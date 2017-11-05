// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Skin.cginc
/// @brief Skin ubershader inputs and entry points.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SKIN_CGINC
#define ALLOY_SKIN_CGINC

/// Used to pass material data to Unity's lighting pipeline via reserved fields. 
/// The surface shader should never modify this directly.
struct AlloySurfaceOutput {	
	half Alpha;
	half Specular;
	half SpecularOcclusion;
	half3 Albedo;
	half3 Normal;
	half3 NormalBlur;
	half3 Emission;
	half SpecularIntensity; 
	half SssMask;
	half Curvature;
	half Translucency;
};

#define ALLOY_NO_LIGHTMAP_BRDF
#include "Assets/Alloy/Shaders/Core.cginc"
#include "Assets/Alloy/Shaders/Dissolve.cginc"
#include "Assets/Alloy/Shaders/Detail.cginc"
#include "Assets/Alloy/Shaders/Effects.cginc"
#include "Assets/Alloy/Shaders/Ambient.cginc"

struct Input
{
    float4 texcoords;  
	float3 worldPos;
    float3 viewDir;
    float3 worldNormal;
    float3 worldRefl;
    INTERNAL_DATA
};

float4 _Color;
float4 _MainTex_ST;
sampler2D _MainTex;
float _Specularity;
float _Roughness;
float _SssBias;
float _SssScale;
sampler2D _SkinMaterialMap;
sampler2D _BumpMap;
float _SssBumpIntensity;
float _OcclusionSaturation;
float _TransPower;
float _TransDistortion;
float _TransScale;
float4 _TransColor;
sampler2D  _BRDFTex;
float _SkinMaskWeight;

void AlloyFinalColor(
	Input IN, 
	AlloySurfaceOutput o, 
	inout fixed4 color)
{
	color.rgb = min(color.rgb, ALLOY_MAX_HDR_INTENSITY);
}

void AlloyVert(
	inout appdata_full v, 
	out Input o) 
{
	UNITY_INITIALIZE_OUTPUT(Input, o);
	o.texcoords.xy = v.texcoord;
}

void AlloySurf(
	Input IN, 
	inout AlloySurfaceOutput o)
{
	float2 texcoords0 = IN.texcoords.xy;
	float2 baseUv = TRANSFORM_TEX(texcoords0, _MainTex);
	half3 emission = half3(0.0h, 0.0h, 0.0h); 
	half4 base = tex2D(_MainTex, baseUv);
	half4 material = tex2D(_SkinMaterialMap, baseUv);
	half clipval = 1.0h; 
	float2 offset = float2(0.0f, 0.0f);

  	AlloyDissolve(baseUv, offset, emission, clipval);

	// Blurred normal
	// http://www.farfarer.com/blog/2013/02/11/pre-integrated-skin-shader-unity-3d/
	half3 normalTs = UnpackNormal(tex2D(_BumpMap, baseUv));
	half3 normalBlurTs = UnpackNormal(tex2Dbias(_BumpMap, float4(baseUv, 0.0h, 3.0f)));

    material.w = 1.0h - (material.w * _Roughness); // Roughness to Gloss
    
    // Note: Detail normals not affecting blur normal. Probably okay,
    // since they need to blur out detail anyway.
	AlloyDetails(baseUv, offset, base, material, normalTs);
	
	// Apply here to ensure that blurred normal has detail normal at higher end.
	normalBlurTs = normalize(lerp(normalBlurTs, normalTs, _SssBumpIntensity));
	
	base *= _Color;
    material.y = AlloyGammaToLinearFast(material.y); // DeGamma combined AO

 	// Normal-dependent data
	half ndv = max(0.0h, dot(normalize(IN.viewDir), normalTs)); 
	half3 normalWs = WorldNormalVector(IN, normalBlurTs); 
	half3 reflectionWs = WorldReflectionVector(IN, normalTs);
	AlloyEffects(baseUv, offset, ndv, emission);

	// Note: We are sort of cheating here and using a transmission map
	// instead of a curvature map/calculation. 
	// http://www.farfarer.com/blog/2013/02/11/pre-integrated-skin-shader-unity-3d/
	o.Curvature = saturate((material.z + _SssBias) * _SssScale);
	o.Translucency = material.z;
	 
	half3 baseColor = base.rgb;
	half spec = _Specularity * ALLOY_SPECULAR_INTENSITY_MAX;
	half invSpec = 1.0h - spec;
	
	// Diffuse "fresnel" approximated here for little visual difference.
	// Monochrome scale makes dielectric + metallic blends look nicer.
	o.Albedo = baseColor * invSpec;
	o.SpecularIntensity = spec;
	
	half mask = material.x * _SkinMaskWeight;
	o.SssMask = mask;
	
	// NOTE: Must ALWAYS output alpha for Candela support!
	o.Alpha = base.a;
	
	// Specular Occlusion
	o.SpecularOcclusion = AlloyGotandaSpecularOcclusion(material.y, ndv);
	
	// Pass-through values
	o.Specular = material.w;
	o.Normal = normalTs; 
	o.NormalBlur = normalBlurTs;
	o.Emission = emission;
	
	// Calculate saturated AO
	// http://www.iryoku.com/stare-into-the-future
	half ao = material.y;
	half saturation = mask * _OcclusionSaturation;
	half3 occludedAlbedo = ao * pow(o.Albedo, (1.0h + saturation) - saturation * ao);
	AlloyAmbientBrdf(ao, occludedAlbedo, spec.rrr, IN.worldPos, normalWs, reflectionWs, ndv, o);
}

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
	half gloss2 = min(1.0h, s.Specular * 2.0h);
	half ndlAtten = ndl * atten;
	half sssMask = s.SssMask;
	
	// Compound Specular
	// http://www.iryoku.com/stare-into-the-future
	// TODO: Vectorize the calculations ?
	half2 d2;
	half2 v2;
	half f = AlloySchlickFresnel(s.SpecularIntensity, ldh);
	d2.x = AlloyNormalizedBlinnPhongDistribution(gloss, ndh);
	d2.y = AlloyNormalizedBlinnPhongDistribution(gloss2, ndh);
	v2.x = AlloyLazarovVisibility(gloss, ldh);
	v2.y = AlloyLazarovVisibility(gloss2, ldh);
	half2 dv2 = d2 * v2;
	half dv = lerp(dv2.x, dv2.y, 0.15h * sssMask);

	// Pre-Integrated SSS
	// http://www.farfarer.com/blog/2013/02/11/pre-integrated-skin-shader-unity-3d/
	float ndlBlur = dot(s.NormalBlur, lightDir) * 0.5h + 0.5h;
	float curvature = s.Curvature * AlloyLuminance(_LightColor0.rgb);
	float3 sss = tex2D(_BRDFTex, float2(ndlBlur, curvature)).rgb;
	
	sss *= atten;
	#if !defined (SHADOWS_SCREEN) && !defined (SHADOWS_DEPTH) && !defined (SHADOWS_CUBE)
		// If shadows are off, we need to reduce the brightness
		// of the scattering on polys facing away from the light
		// as it won't get killed off by shadow value.
		// Same for the specular highlights.
		
		sss *= saturate(ndlBlur * 4.0h - 1.0h); // [-1,3], then clamp
	#endif
	
	// Transmission 
	// http://www.farfarer.com/blog/2012/09/11/translucent-shader-unity3d/
	half3 transLightDir = lightDir + s.Normal * _TransDistortion;
	half transDot = pow(max(0.0h, dot(viewDir, -transLightDir)), _TransPower) * _TransScale;
	half3 transLight = (transDot * s.Translucency) * _TransColor.rgb;

	// Lighting
	c.rgb = _LightColor0.rgb * 2.0h * (
			s.Albedo * lerp(ndlAtten.rrr, sss + transLight, sssMask) 
			+ (f * (dv * s.SpecularOcclusion * ndlAtten)));
	c.a = s.Alpha; 
	return c;
}

#endif // ALLOY_SKIN_CGINC
