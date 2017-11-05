// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Hidden/Alloy/Deferred Shading UBER" {
Properties {
    _LightTexture0 ("", any) = "" {}
    _LightTextureB0 ("", 2D) = "" {}
    _ShadowMapTexture ("", any) = "" {}
    _SrcBlend ("", Float) = 1
    _DstBlend ("", Float) = 1
}

// =================================== BEGIN UBER SUPPORT ===================================
CGINCLUDE
    // UBER - Standard Shader Ultra integration
    // https://www.assetstore.unity3d.com/en/#!/content/39959

	// when using both features check UBER_StandardConfig.cginc to configure Gbuffer channels
	// by default translucency is passed in diffuse (A) gbuffer and self-shadows are passed in normal (A) channel
	//
	// NOTE that you're not supposed to use Standard shader with occlusion data together with UBER translucency in deferred, because Standard Shader writes occlusion velue in GBUFFER0 alpha as the translucency does !
	//
	#define UBER_TRANSLUCENCY_DEFERRED
	#define UBER_POM_SELF_SHADOWS_DEFERRED
	//
	// comment this out when you'd like to have translucency in deferred not influenced by diffuse/base object color
	#define UBER_TRANSLUCENCY_DEFERRED_MULT_DIFFUSE
	//
	// define when you like to control translucency power per light (its color alpha channel)
	// note, that this can interfere with solutions that uses light color.a for different purpose (like Alloy)
	//#define UBER_TRANSLUCENCY_PER_LIGHT_ALPHA	
	//
	// you can gently turn it up (like 0.3, 0.5) if you find front facing geometry overbrighten (esp. for point lights),
	// but suppresion can negate albedo for high translucency values (they can become badly black)
	#define TRANSLUCENCY_SUPPRESS_DIFFUSECOLOR 0.0	

	// change to 1 to get GGX specularity model in deferred
	#define UNITY_BRDF_GGX 1
ENDCG
// ==================================== END UBER SUPPORT ====================================

SubShader {
    // Pass 1: Lighting pass
    //  LDR case - Lighting encoded into a subtractive ARGB8 buffer
    //  HDR case - Lighting additively blended into floating point buffer
    Pass {
        ZWrite Off
        Blend [_SrcBlend] [_DstBlend]

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers nomrt
        
        #pragma multi_compile_lightpass
        #pragma multi_compile ___ UNITY_HDR_ON

        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader

        #include "Assets/Alloy/Shaders/Deferred/Light.cginc"
        #include "Assets/Alloy/Shaders/Framework/Lighting.cginc"

        // =================================== BEGIN UBER SUPPORT ===================================

        // UBER - POM self-shadowing (for one realtime light)
        #if defined(UBER_POM_SELF_SHADOWS_DEFERRED)
	        float4 _WorldSpaceLightPosCustom;
        #endif

        // UBER - Translucency, POM self-shadowing, wetness values encoded
        #if defined(UBER_POM_SELF_SHADOWS_DEFERRED) || defined(UBER_TRANSLUCENCY_DEFERRED)
	        sampler2D _UBERPropsBuffer;
        #endif

        // UBER - Translucency
        #if defined(UBER_TRANSLUCENCY_DEFERRED)
	        sampler2D _UBERTranslucencySetup;
	        struct TranslucencyParams {
		        half3 _TranslucencyColor;
		        half _TranslucencyStrength;
		        half _TranslucencyConstant;
		        half _TranslucencyNormalOffset;
		        half _TranslucencyExponent;
		        half _TranslucencyPointLightDirectionality;
		        half _TranslucencySuppressRealtimeShadows;
		        half _TranslucencyNDotL;
	        };

            inline half Translucency(half3 normalWorld, ADirect d, half3 eyeVec, TranslucencyParams translucencyParams) {
                #ifdef USING_DIRECTIONAL_LIGHT
                    half tLitDot = saturate(dot((d.direction + normalWorld * translucencyParams._TranslucencyNormalOffset), eyeVec));
                #else
                    float3 lightDirectional = normalize(_LightPos.xyz - _WorldSpaceCameraPos.xyz);
                    half3 light_dir = normalize(lerp(d.direction, lightDirectional, translucencyParams._TranslucencyPointLightDirectionality));
                    half tLitDot = saturate(dot((light_dir + normalWorld * translucencyParams._TranslucencyNormalOffset), eyeVec));
                #endif
        
                tLitDot = exp2(-translucencyParams._TranslucencyExponent * (1 - tLitDot)) * translucencyParams._TranslucencyStrength;
		        float NDotL = abs(dot(d.direction, normalWorld));
		        tLitDot *= lerp(1, NDotL, translucencyParams._TranslucencyNDotL);

		        half translucencyAtten = (tLitDot + translucencyParams._TranslucencyConstant*(NDotL + 0.1));
                //#if defined(UBER_TRANSLUCENCY_PER_LIGHT_ALPHA)
	               // translucencyAtten *= _LightColor.a;
                //#endif

                return translucencyAtten;
            }
        #endif

        void aPreLighting(
            inout ASurface s)
        {
            aStandardPreLighting(s);
        }

        half3 aDirectLighting(
            ADirect d,
            ASurface s)
        {
            half3 color = 0.0h;

        #if defined(UBER_POM_SELF_SHADOWS_DEFERRED) || defined(UBER_TRANSLUCENCY_DEFERRED)
            // buffer decoded from _CameraGBufferTexture3.a in command buffer
            half Wetness = 0;
            half SS = 1;
            half translucencySetupIndex = 0;
            half translucency_thickness = 0;
            float encoded = tex2D(_UBERPropsBuffer, s.screenUv).r;
            if (encoded < 0) {
                encoded = -encoded;

                // wetness (not used currently so below line should get compiled out)
                encoded /= 8.0; // 3 bits
                Wetness = frac(encoded) * (8.0 / 7.0); // to 0..1 range
                encoded = floor(encoded);

                // self shadowing
                encoded /= 4.0; // 2 bits
                SS = 1 - frac(encoded) * (4.0 / 3.0); // to 0..1 range
                encoded = floor(encoded);

                // translucency color index
                encoded /= 4.0; // 2 bits
                translucencySetupIndex = frac(encoded); // directly decoded as U coord in lookup texture
                encoded = floor(encoded);

                // translucency thickness
                encoded /= 15.0; // 4 bits (divide by 15 instead of 16 to bring it immediately to 0..1 range)
                translucency_thickness = encoded;
            } // else - no prop used for this pixel (no translucency, self-shadowing and surface is considered to be dry)
              //translucencySetupIndex = 0;
              //translucency_thickness = 1;
        #endif

              // UBER - POM self-shadowing (for one realtime light)
        #if defined(UBER_POM_SELF_SHADOWS_DEFERRED)
              // conditional to attenuate only the selected realtime light
        #if defined (DIRECTIONAL) || defined (DIRECTIONAL_COOKIE)
            d.shadow = (abs(dot((_LightDir.xyz + _WorldSpaceLightPosCustom.xyz), float3(1, 1, 1))) < 0.01) ? min(d.shadow, SS) : d.shadow;
        #else
            d.shadow = (abs(dot((_LightDir.xyz - _WorldSpaceLightPosCustom.xyz), float3(1, 1, 1))) < 0.01) ? min(d.shadow, SS) : d.shadow;
        #endif
        #endif

        #if defined(UBER_TRANSLUCENCY_DEFERRED)	
            half setupIndex = translucencySetupIndex; // [0..1] to [0..1) range

            half4 val;
            val = tex2D(_UBERTranslucencySetup, float2(setupIndex, 0));
            TranslucencyParams translucencyParams;
            translucencyParams._TranslucencyColor = val.rgb;
            translucencyParams._TranslucencyStrength = val.a;
            val = tex2D(_UBERTranslucencySetup, float2(setupIndex, 0.4));
            translucencyParams._TranslucencyPointLightDirectionality = val.r;
            translucencyParams._TranslucencyConstant = val.g;
            translucencyParams._TranslucencyNormalOffset = val.b;
            translucencyParams._TranslucencyExponent = val.a;
            val = tex2D(_UBERTranslucencySetup, float2(setupIndex, 0.8));
            translucencyParams._TranslucencySuppressRealtimeShadows = val.r;
            translucencyParams._TranslucencyNDotL = val.g;

            half3 TL = Translucency(s.normalWorld, d, -s.viewDirWorld, translucencyParams)*translucencyParams._TranslucencyColor;
        #if defined(UBER_TRANSLUCENCY_DEFERRED_MULT_DIFFUSE)
            TL *= s.albedo;
        #endif
            TL *= translucency_thickness;
            s.albedo *= saturate(1 - max(max(TL.r, TL.g), TL.b) * TRANSLUCENCY_SUPPRESS_DIFFUSECOLOR);
            // suppress shadows
            d.shadow = lerp(d.shadow, 1, saturate(dot(TL, 1) * translucencyParams._TranslucencySuppressRealtimeShadows));

            color.rgb += d.shadow * TL * d.color.rgb;
        #endif

            return color.rgb + aStandardDirectLighting(d, s);
        }

        half3 aIndirectLighting(
            AIndirect i,
            ASurface s)
        {
            return aStandardIndirectLighting(i, s);
        }
        // ==================================== END UBER SUPPORT ====================================

        ENDCG
    }

    // Pass 2: Final decode pass.
    // Used only with HDR off, to decode the logarithmic buffer into the main RT
    Pass {
        ZTest Always
        Cull Off
        ZWrite Off
        Stencil {
            ref [_StencilNonBackground]
            readmask [_StencilNonBackground]
            // Normally just comp would be sufficient, but there's a bug and only front face stencil state is set (case 583207)
            compback equal
            compfront equal
        }

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers nomrt

        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader

        #include "Assets/Alloy/Shaders/Deferred/Decode.cginc"

        ENDCG 
    }
}
Fallback Off
}
