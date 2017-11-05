// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file EyeParallax.cginc
/// @brief Surface heightmap-based texcoord modification.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_LEGACY_SHADERS_FEATURE_EYE_PARALLAX_CGINC
#define ALLOY_LEGACY_SHADERS_FEATURE_EYE_PARALLAX_CGINC

#ifdef A_EYE_PARALLAX_REFRACTION
    #if defined(UNITY_PASS_SHADOWCASTER) || defined(UNITY_PASS_META)
        #undef A_EYE_PARALLAX_REFRACTION
    #elif !defined(A_VIEW_DIR_TANGENT_ON)
        #define A_VIEW_DIR_TANGENT_ON
    #endif
#endif

#include "Assets/Alloy/Shaders/Framework/Feature.cginc"
    
#ifdef A_EYE_PARALLAX_REFRACTION
    /// Number of samples used for direct view of POM effect.
    /// Expects values in the range [1,n].
    float _MinSamples;
    
    /// Number of samples used for grazing view of POM effect.
    /// Expects values in the range [1,n].
    float _MaxSamples;

    #ifdef A_EYE_PARALLAX_REFRACTION
        /// Iris parallax depth scale.
        /// Expects values in the range [0,1].
        half _EyeParallax;

        /// Iris pupil dilation.
        /// Expects values in the range [0,1].
        half _EyePupilSize;
    #endif
#endif

/// Applies texture coordinate offsets to surface data.
/// @param[in,out]  s       Material surface data.
/// @param[in]      offset  Texture coordinate offset.
void aEyeApplyParallaxOffset(
    inout ASurface s,
    float2 offset)
{
    offset *= s.mask;
    
    // To apply the parallax offset to secondary textures without causing swimming,
    // we must normalize it by removing the implicitly multiplied base map tiling. 
    s.uv01 += (offset / s.baseTiling).xyxy;
    s.baseUv += A_BV(s, offset);
}

/// Calculates Offset Bump Mapping texture offsets.
/// @param[in,out]  s           Material surface data.
/// @param[in]      parallaxMap Height map.
/// @param[in]      parallax    Height scale of the heightmap [0,0.08].
void aEyeOffsetBumpMapping(
    inout ASurface s,
    sampler2D parallaxMap, 
    half parallax)
{
    // NOTE: Prevents NaN compiler errors in DX9 mode for shadow pass.
#if !defined(UNITY_PASS_SHADOWCASTER) && !defined(UNITY_PASS_META)
    #ifdef _VIRTUALTEXTURING_ON
        half h = VTSampleBase(s.baseVirtualCoord).a;
    #else
        half h = tex2D(parallaxMap, s.baseUv).w;
    #endif

    h = h * parallax - parallax / 2.0h;
    
    half3 v = s.viewDirTangent;
    v.z += 0.42h;
        
    aEyeApplyParallaxOffset(s, h * (v.xy / v.z));
#endif
}

/// Calculates Parallax Occlusion Mapping texture offsets.
/// @param[in,out]  s           Material surface data.
/// @param[in]      parallaxMap Height map.
/// @param[in]      parallax    Height scale of the heightmap [0,0.08].
/// @param[in]      minSamples  Minimum number of samples for POM effect [1,n].
/// @param[in]      maxSamples  Maximum number of samples for POM effect [1,n].
void aEyeParallaxOcclusionMapping(
    inout ASurface s,
    sampler2D parallaxMap,
    float parallax,
    float minSamples,
    float maxSamples)
{
    // NOTE: Prevents NaN compiler errors in DX9 mode for shadow pass.
#if !defined(UNITY_PASS_SHADOWCASTER) && !defined(UNITY_PASS_META)
    // Parallax Occlusion Mapping
    // cf http://www.gamedev.net/page/resources/_/technical/graphics-programming-and-theory/a-closer-look-at-parallax-occlusion-mapping-r3262
    float2 offset = float2(0.0f, 0.0f);

    // Calculate the parallax offset vector max length.
    // This is equivalent to the tangent of the angle between the
    // viewer position and the fragment location.
    float parallaxLimit = -length(s.viewDirTangent.xy) / s.viewDirTangent.z;

    // Scale the parallax limit according to heightmap scale.
    parallaxLimit *= parallax;						

    // Calculate the parallax offset vector direction and maximum offset.
    float2 offsetDirTangent = normalize(s.viewDirTangent.xy);
    float2 maxOffset = offsetDirTangent * parallaxLimit;
    
    // Calculate how many samples should be taken along the view ray
    // to find the surface intersection.  This is based on the angle
    // between the surface normal and the view vector.
    int numSamples = (int)lerp(maxSamples, minSamples, s.NdotV);
    int currentSample = 0;
    
    // Specify the view ray step size.  Each sample will shift the current
    // view ray by this amount.
    float stepSize = 1.0f / (float)numSamples;

    // Initialize the starting view ray height and the texture offsets.
    float currentRayHeight = 1.0f;	
    float2 lastOffset = float2(0.0f, 0.0f);
    
    float lastSampledHeight = 1.0f;
    float currentSampledHeight = 1.0f;

    #ifdef _VIRTUALTEXTURING_ON
        VirtualCoord vcoord = s.baseVirtualCoord;
    #else
        // Calculate the texture coordinate partial derivatives in screen
        // space for the tex2Dgrad texture sampling instruction.
        float2 dx = ddx(s.baseUv);
        float2 dy = ddy(s.baseUv);
    #endif

    while (currentSample < numSamples) {
        #ifdef _VIRTUALTEXTURING_ON
            vcoord = VTUpdateVirtualCoord(vcoord, s.baseUv + offset);
            currentSampledHeight = VTSampleBase(vcoord).a;
        #else
            // Sample the heightmap at the current texcoord offset.
            currentSampledHeight = tex2Dgrad(parallaxMap, s.baseUv + offset, dx, dy).w;
        #endif

        // Test if the view ray has intersected the surface.
        UNITY_BRANCH
        if (currentSampledHeight > currentRayHeight) {
            // Find the relative height delta before and after the intersection.
            // This provides a measure of how close the intersection is to 
            // the final sample location.
            float delta1 = currentSampledHeight - currentRayHeight;
            float delta2 = (currentRayHeight + stepSize) - lastSampledHeight;
            float ratio = delta1 / (delta1 + delta2);

            // Interpolate between the final two segments to 
            // find the true intersection point offset.
            offset = lerp(offset, lastOffset, ratio);
            
            // Force the exit of the while loop
            currentSample = numSamples + 1;	
        }
        else {
            // The intersection was not found.  Now set up the loop for the next
            // iteration by incrementing the sample count,
            currentSample++;

            // take the next view ray height step,
            currentRayHeight -= stepSize;
            
            // save the current texture coordinate offset and increment
            // to the next sample location, 
            lastOffset = offset;
            offset += stepSize * maxOffset;

            // and finally save the current heightmap height.
            lastSampledHeight = currentSampledHeight;
        }
    }

    aEyeApplyParallaxOffset(s, offset);
#endif
}

void aEyeParallax(
    inout ASurface s) 
{
#ifdef A_EYE_PARALLAX_REFRACTION
    // Cornea "Refraction".
    aEyeParallaxOcclusionMapping(s, _MainTex, _EyeParallax * _Color.a, 10.0f, 25.0f);
    //aEyeOffsetBumpMapping(s, _MainTex, _EyeParallax * _Color.a);

    // Pupil Dilation
    // HACK: Use the heightmap as the gradient, since it matches the other maps.
    // http://www.polycount.com/forum/showpost.php?p=1511423&postcount=13
    half mask = 1.0h - aSampleBase(s).a;
    float2 centeredUv = frac(s.baseUv) + float2(-0.5f, -0.5f);

    s.baseUv -= A_BV(s, centeredUv * mask * _EyePupilSize);
#endif 
}

#endif // ALLOY_LEGACY_SHADERS_FEATURE_EYE_PARALLAX_CGINC
