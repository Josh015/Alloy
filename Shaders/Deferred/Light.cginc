// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Light.cginc
/// @brief Deferred light pass vertex & fragment shaders.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFERRED_LIGHT_CGINC
#define ALLOY_SHADERS_DEFERRED_LIGHT_CGINC

#define A_DIRECT_LIGHTING_PASS

#include "Assets/Alloy/Shaders/Framework/Deferred.cginc"

unity_v2f_deferred aMainVertexShader(
    float4 vertex : POSITION, 
    float3 normal : NORMAL)
{
    return vert_deferred(vertex, normal);
}

#ifdef UNITY_HDR_ON
half4
#else
fixed4
#endif
aMainFragmentShader(
    unity_v2f_deferred i) : SV_Target
{
    ASurface s = aDeferredSurface(i);
    ADirect d = aNewDirect();
    float fadeDist = UnityComputeShadowFadeDistance(s.positionWorld, s.viewDepth);
    float4 lightCoord = 0.0f;
    float3 lightVector = 0.0f;
    half3 lightAxis = 0.0h;
    half range = 1.0h;
    half4 c = 0.0h;

    d.color = _LightColor.rgb;
    	
#ifndef DIRECTIONAL
    lightCoord = mul(unity_WorldToLight, float4(s.positionWorld, 1.0f));
#endif

#if defined(USING_DIRECTIONAL_LIGHT)
    lightVector = -_LightDir.xyz;
    d.shadow = UnityDeferredComputeShadow(s.positionWorld, fadeDist, s.screenUv);
        
    #if !defined(ALLOY_SUPPORT_REDLIGHTS) && defined(DIRECTIONAL_COOKIE)
        aLightCookie(d, tex2Dbias(_LightTexture0, float4(lightCoord.xy, 0, -8)));
    #endif
#elif defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
    lightVector = _LightPos.xyz - s.positionWorld;
    lightAxis = normalize(unity_WorldToLight[1].xyz);
    range = rsqrt(_LightPos.w); // _LightPos.w = 1/r*r

    #if defined(SPOT)
        // negative bias because http://aras-p.info/blog/2010/01/07/screenspace-vs-mip-mapping/
        half4 cookie = tex2Dbias(_LightTexture0, float4(lightCoord.xy / lightCoord.w, 0, -8));
        
        cookie.a *= (lightCoord.w < 0.0f);
        aLightCookie(d, cookie);
        d.shadow = UnityDeferredComputeShadow(s.positionWorld, fadeDist, s.screenUv);
    #elif defined(POINT) || defined(POINT_COOKIE)
        d.shadow = UnityDeferredComputeShadow(-lightVector, fadeDist, s.screenUv);
                
        #if defined (POINT_COOKIE)
            aLightCookie(d, texCUBEbias(_LightTexture0, float4(lightCoord.xyz, -8)));
        #endif //POINT_COOKIE
    #endif //POINT || POINT_COOKIE

    A_UNITY_ATTENUATION(d, _LightTextureB0, lightVector, _LightPos.w)
#endif

#if !defined(ALLOY_SUPPORT_REDLIGHTS) || !defined(DIRECTIONAL_COOKIE)
    aAreaLight(d, s, _LightColor, lightAxis, lightVector, range);
#else
    d.direction = lightVector;
    d.color *= redLightFunctionLegacy(_LightTexture0, s.positionWorld, s.normalWorld, s.viewDirWorld, d.direction);
    aDirectionalLight(d, s);
#endif

    c.rgb = aHdrClamp(aDirectLighting(d, s));

#ifdef UNITY_HDR_ON
    return c;
#else
    return exp2(-c);
#endif
}

#endif // ALLOY_SHADERS_DEFERRED_LIGHT_CGINC
