// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Parallax.cginc
/// @brief Surface heightmap-based texcoord modification.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_PARALLAX_CGINC
#define ALLOY_PARALLAX_CGINC

#if defined(_BUMPMODE_PARALLAX) || defined(_BUMPMODE_POM)
	sampler2D _ParallaxMap;
	float _Parallax;
#endif
	
#if defined(_BUMPMODE_POM)
	float _MinSamples;
	float _MaxSamples;
#endif

float2 AlloyParallax(float3 eyeVectorTs, half3 eyeDirTs, float2 baseUv) {
	float2 offset = float2(0.0f, 0.0f);

#if defined(_BUMPMODE_PARALLAX) || defined(_BUMPMODE_POM)
	#if defined(_BUMPMODE_PARALLAX)
		// Taken from Unity ParallaxOffset(), removed redundant normalize().
		half height = tex2D(_ParallaxMap, baseUv).w;
		height = (height * _Parallax) - (_Parallax / 2.0h);
		eyeDirTs.z += 0.42h;
		offset = height * (eyeDirTs.xy / eyeDirTs.z);
	#elif defined(_BUMPMODE_POM)
		// Based on:
		// http://www.gamedev.net/page/resources/_/technical/graphics-programming-and-theory/a-closer-look-at-parallax-occlusion-mapping-r3262
		
		// Calculate the parallax offset vector max length.
		// This is equivalent to the tangent of the angle between the
		// viewer position and the fragment location.
		float fParallaxLimit = -length(eyeVectorTs.xy) / eyeVectorTs.z;

		// Scale the parallax limit according to heightmap scale.
		fParallaxLimit *= _Parallax;						

		// Calculate the parallax offset vector direction and maximum offset.
		float2 vOffsetDir = normalize(eyeVectorTs.xy);
		float2 vMaxOffset = vOffsetDir * fParallaxLimit;
		
		// Calculate how many samples should be taken along the view ray
		// to find the surface intersection.  This is based on the angle
		// between the surface normal and the view vector.
		int nNumSamples = (int)lerp(_MaxSamples, _MinSamples, dot(eyeDirTs, half3(0.0h, 0.0h, 1.0h)));
		
		// Specify the view ray step size.  Each sample will shift the current
		// view ray by this amount.
		float fStepSize = 1.0f / (float)nNumSamples;

		// Calculate the texture coordinate partial derivatives in screen
		// space for the tex2Dgrad texture sampling instruction.
		float2 dx = ddx(baseUv);
		float2 dy = ddy(baseUv);

		// Initialize the starting view ray height and the texture offsets.
		float fCurrRayHeight = 1.0f;	
		float2 vCurrOffset = float2(0.0f, 0.0f);
		float2 vLastOffset = float2(0.0f, 0.0f);
		
		float fLastSampledHeight = 1.0f;
		float fCurrSampledHeight = 1.0f;

		int nCurrSample = 0;

		while (nCurrSample < nNumSamples)
		{
			// Sample the heightmap at the current texcoord offset.  The heightmap 
			// is stored in the alpha channel of the height/normal map.
			//fCurrSampledHeight = tex2Dgrad( NH_Sampler, IN.texcoord + vCurrOffset, dx, dy ).a;
			fCurrSampledHeight = tex2D(_ParallaxMap, baseUv + vCurrOffset, dx, dy).w;

			// Test if the view ray has intersected the surface.
			if (fCurrSampledHeight > fCurrRayHeight)
			{
				// Find the relative height delta before and after the intersection.
				// This provides a measure of how close the intersection is to 
				// the final sample location.
				float delta1 = fCurrSampledHeight - fCurrRayHeight;
				float delta2 = (fCurrRayHeight + fStepSize) - fLastSampledHeight;
				float ratio = delta1 / (delta1 + delta2);

				// Interpolate between the final two segments to 
				// find the true intersection point offset.
				vCurrOffset = ratio * vLastOffset + (1.0f - ratio) * vCurrOffset;
				
				// Force the exit of the while loop
				nCurrSample = nNumSamples + 1;	
			}
			else
			{
				// The intersection was not found.  Now set up the loop for the next
				// iteration by incrementing the sample count,
				nCurrSample++;

				// take the next view ray height step,
				fCurrRayHeight -= fStepSize;
				
				// save the current texture coordinate offset and increment
				// to the next sample location, 
				vLastOffset = vCurrOffset;
				vCurrOffset += fStepSize * vMaxOffset;

				// and finally save the current heightmap height.
				fLastSampledHeight = fCurrSampledHeight;
			}
		}
		
		offset = vCurrOffset;
	#endif 
#endif 

	return offset;
} 

#endif // ALLOY_PARALLAX_CGINC
