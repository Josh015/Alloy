// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file ReflectionProbe.cginc
/// @brief Deferred reflection probe pass vertex & fragment shaders.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFERRED_REFLECTION_PROBE_CGINC
#define ALLOY_SHADERS_DEFERRED_REFLECTION_PROBE_CGINC

#define A_INDIRECT_LIGHTING_PASS

#include "Assets/Alloy/Shaders/Framework/Deferred.cginc"

unity_v2f_deferred aMainVertexShader(
    float4 vertex : POSITION, 
    float3 normal : NORMAL)
{
    return vert_deferred(vertex, normal);
}

half4 aMainFragmentShader(
    unity_v2f_deferred i) : SV_Target
{
    UnityGIInput d;
    ASurface s = aDeferredSurface(i);
    float blendDistance = unity_SpecCube1_ProbePosition.w; // will be set to blend distance for this probe

	d.worldPos = s.positionWorld;
	d.worldViewDir = s.viewDirWorld; // ???
	d.probeHDR[0] = unity_SpecCube0_HDR;

#ifdef UNITY_SPECCUBE_BOX_PROJECTION
	d.probePosition[0]	= unity_SpecCube0_ProbePosition;
	d.boxMin[0].xyz		= unity_SpecCube0_BoxMin - float4(blendDistance,blendDistance,blendDistance,0);
	d.boxMin[0].w		= 1;  // 1 in .w allow to disable blending in UnityGI_IndirectSpecular call
	d.boxMax[0].xyz		= unity_SpecCube0_BoxMax + float4(blendDistance,blendDistance,blendDistance,0);
#endif

    Unity_GlossyEnvironmentData g;
    AIndirect ind = aNewIndirect();

    g.roughness = s.roughness;
    g.reflUVW = s.reflectionVectorWorld;
    ind.specular = UnityGI_IndirectSpecular(d, 1.0h, g);

    // Calculate falloff value, so reflections on the edges of the probe would gradually blend to previous reflection.
    // Also this ensures that pixels not located in the reflection probe AABB won't
    // accidentally pick up reflections from this probe.
    half3 distance = aDistanceFromAabb(s.positionWorld, unity_SpecCube0_BoxMin.xyz, unity_SpecCube0_BoxMax.xyz);
    half falloff = saturate(1.0 - length(distance) / blendDistance);

    return half4(aIndirectLighting(ind, s), falloff);
}

#endif // ALLOY_SHADERS_DEFERRED_REFLECTION_PROBE_CGINC
