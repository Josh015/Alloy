// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Transparent/Cutout/DoubleSided" {
Properties {
	_Cutoff 			("Alpha cutoff [0,1]", Float) 				= 0.5

	_Color 				("Main Color", Color) 						= (1,1,1,1)
	
	_TranslucencyColor 	("Translucency Color", Color) 				= (0.73,0.85,0.41,1) // (187,219,106,255)
	_TranslucencyViewDependency ("View dependency", Range(0,1)) 	= 0.7
	_ShadowStrength		("Shadow Strength", Range(0,1)) 			= 0.8
	
	_MainTex 			("Base(RGB) Trans(A)", 2D) 					= "white" {}
	_Specularity		("Specularity [0,1]", Float)				= 1
	_Roughness			("Roughness [0,1]", Float)					= 1
	_MaterialMap 		("AO(G) Spec(B) Rough(A)", 2D)				= "white" {}
	_BumpMap            ("Normalmap", 2D)                   		= "bump" {}
	_TranslucencyMap 	("Translucency(G)", 2D) 					= "white" {}

	// Reflection Properties	
	[KeywordEnum(Rsrm, RsrmCube, Skyshop)]
	_EnvironmentMapMode ("Environment Map Mode", Float) 			= 0
    _Rsrm               ("Radially-Symmetric Reflection Map", 2D)	= "black" {}
    _CubeExposureBoost	("Reflection Exposure Boost [0,n]", Float)	= 1
    _Cube 				("Reflection Cubemap", Cube) 				= "_Skybox" { TexGen CubeReflect }
	_SpecCubeIBL 		("Custom Specular Cube", Cube) 				= "black" {}
}
    
SubShader { 
	Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
	LOD 400
    
CGPROGRAM
	#ifdef SHADER_API_OPENGL	
		#pragma glsl
	#endif

    #pragma target 3.0
    #pragma surface AlloyStandardSurf AlloyStandardBrdf finalcolor:AlloyStandardFinalColor alphatest:_Cutoff fullforwardshadows noambient novertexlights
	#pragma multi_compile _BUMPMODE_BUMP _BUMPMODE_PARALLAX _BUMPMODE_POM
	#pragma multi_compile _ENVIRONMENTMAPMODE_RSRM _ENVIRONMENTMAPMODE_RSRMCUBE _ENVIRONMENTMAPMODE_SKYSHOP 

	// Skyshop directives
	#pragma multi_compile MARMO_BOX_PROJECTION_OFF MARMO_BOX_PROJECTION_ON
	#pragma multi_compile MARMO_GLOBAL_BLEND_OFF MARMO_GLOBAL_BLEND_ON
	#pragma multi_compile MARMO_SKY_BLEND_OFF MARMO_SKY_BLEND_ON
    
	//#define ALLOY_TRANSLUCENCY
	#define ALLOY_CUTOUT
    
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
		
		/// Specular Intensity and diffuse translucency.
		/// Expects linear-space LDR color values.
		half3 SpecularIntensityAndDiffuseTranslucency;
		
		/// Used to pass ambient BRDF illumination to the lightmap functions.
		/// Expects linear-space HDR color values.
		half3 AmbientBrdf;
	};

	#include "Assets/Alloy/Shaders/Core.cginc"
	#include "Assets/Alloy/Shaders/Ambient.cginc"
    
    float3 _TranslucencyColor;
	float _TranslucencyViewDependency;
	float _ShadowStrength;
    
	half4 LightingAlloyStandardBrdf(
		AlloySurfaceOutput s, 
		half3 lightDir, 
		half3 viewDir, 
		half atten) 
	{
		half4 c;
		half3 Nn = s.Normal;
		half3 Hn = normalize(lightDir + viewDir);
		half ndlm = dot(Nn, lightDir);
		half ndl = max(0.0h, ndlm);
		half ndh = max(0.0h, dot(Nn, Hn));
		half ldh = max(0.0h, dot(lightDir, Hn));
		half gloss = s.Specular;
		half3 material = s.SpecularIntensityAndDiffuseTranslucency;
		half3 f = AlloySchlickFresnel(material.rrr, ldh);
		half d = AlloyNormalizedBlinnPhongDistribution(gloss, ndh);
		half v = AlloyLazarovVisibility(gloss, ldh);
			
		// view dependent back contribution for translucency
		half backContrib = saturate(dot(viewDir, -lightDir));
		
		// normally translucency is more like -nl, but looks better when it's view dependent
		backContrib = lerp(saturate(-ndlm), backContrib, _TranslucencyViewDependency);
		
		half3 translucencyColor = backContrib * material.y * _TranslucencyColor;
		
		// wrap-around diffuse
		half3 wrap = max(0.0h, (ndlm + 0.4h) * 0.51h).rrr; // Energy conserving wrap.
		wrap = translucencyColor * 2.0h + wrap;
			
		// For directional lights, apply less shadow attenuation
		// based on shadow strength parameter.
		wrap *= lerp(2.0h, atten * 2.0h, _ShadowStrength);
			
		// Use the punctual lighting equation to correctly attenuate specular.
		// 2.0 for the range Unity expects.
		c.rgb =  _LightColor0.rgb * (
					s.Albedo * wrap +
					f * ((d / v) * s.SpecularOcclusion * 2.0h * atten * ndl));
	                
		// Required in order to support alpha-blending?
	    c.a = s.Alpha;
		return c;
	}

	// HACK: Uses "inout" to accumulate the lighting in the SurfaceOutput.Emission
	// field. Then zero out the return value to ensure nothing gets passed through
	// the _PrePass callback in deferred mode. This way, we don't contaminate the
	// recovered specular lighting color, or have weird specular results.
	half4 LightingAlloyStandardBrdf_SingleLightmap(
		inout AlloySurfaceOutput s, 
		fixed4 color) 
	{
	  	half3 lm = DecodeLightmap(color);
	  	
		s.Emission += lm * s.AmbientBrdf;
		return 0.0h;
	}

	half4 LightingAlloyStandardBrdf_DualLightmap(
		inout AlloySurfaceOutput s, 
		fixed4 totalColor, 
		fixed4 indirectOnlyColor, 
		half indirectFade) 
	{
		half3 lm = lerp(DecodeLightmap(indirectOnlyColor), DecodeLightmap(totalColor), indirectFade);
	  	
		s.Emission += lm * s.AmbientBrdf;
		return 0.0h;
	}

	half4 LightingAlloyStandardBrdf_DirLightmap(
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

	struct Input {
	    float2 uv_MainTex; 
		float3 worldPos;
	    float3 viewDir;
	    float3 worldNormal;
	    float3 worldRefl;
	    INTERNAL_DATA
	};

	float4 _Color;
	sampler2D _MainTex;
	float _Metallic;
	float _Specularity;
	float _Roughness;
	sampler2D _MaterialMap;
	sampler2D _BumpMap;
	sampler2D _TranslucencyMap;
		
		
	void AlloyStandardFinalColor(
		Input IN, 
		AlloySurfaceOutput o, 
		inout fixed4 color)
	{
		color.rgb = min(color.rgb, ALLOY_MAX_HDR_INTENSITY);
	}
		
	void AlloyStandardSurf(
		Input IN, 
		inout AlloySurfaceOutput o) 
	{ 
		float2 baseUv = IN.uv_MainTex;
		half3 emission = half3(0.0h, 0.0h, 0.0h);  
	  
		// Base
	    half3 normalTs = UnpackNormal(tex2D(_BumpMap, baseUv));
	    half4 base = tex2D(_MainTex, baseUv);
	    half4 material = tex2D(_MaterialMap, baseUv);
	    material.z *= _Specularity;
	    material.w *= _Roughness;
	    material.w = 1.0h - material.w; // Roughness to Gloss

		// Tint combined details/decals
		base *= _Color;
	    material.y = AlloyGammaToLinearFast(material.y);
		
	 	// Normal-dependent data
		half ndv = max(0.0h, dot(normalize(IN.viewDir), normalTs)); 
		half3 normalWs = WorldNormalVector(IN, normalTs);
		half3 reflectionWs = WorldReflectionVector(IN, normalTs);

		// Surface
		half alpha = base.a;
		half3 baseColor = base.rgb;
		half spec = material.z * ALLOY_SPECULAR_INTENSITY_MAX;
		half invSpec = 1.0h - spec;
		
		// Diffuse "fresnel" approximated here for little visual difference.
		o.Albedo = baseColor * invSpec;
		
		o.SpecularIntensityAndDiffuseTranslucency.r = spec;
		o.SpecularIntensityAndDiffuseTranslucency.g = tex2D(_TranslucencyMap, baseUv).g;
		
	#ifdef ALLOY_TRANSLUCENCY
		o.Alpha = spec + invSpec * alpha;
		
		// Premultiply alpha with albedo for translucent shaders.
		o.Albedo *= alpha;
	#else
		// Cutout alpha.
		o.Alpha = alpha;
	#endif
		
		// Specular Occlusion
		o.SpecularOcclusion = AlloyGotandaSpecularOcclusion(material.y, ndv);
		
		// Pass-through values
		o.Specular = material.w;
		o.Normal = normalTs; 
		o.Emission = emission;
		
		AlloyAmbientBrdf(material.y, material.yyy, o.SpecularIntensityAndDiffuseTranslucency.rrr, IN.worldPos, normalWs, reflectionWs, ndv, o);
	}
ENDCG
}
    
Fallback "Transparent/Cutout/Bumped Diffuse"
}