// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Tessellation.cginc
/// @brief Callbacks and data structures for tessellation.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_TESSELLATION_CGINC
#define ALLOY_SHADERS_FRAMEWORK_TESSELLATION_CGINC

#include "Assets/Alloy/Shaders/Config.cginc"

#include "HLSLSupport.cginc"
//#include "Lighting.cginc"
//#include "Tessellation.cginc"
#include "UnityCG.cginc"

#if defined(A_TESSELLATION_SHADER) && defined(A_TESSELLATION_PASS) && defined(UNITY_CAN_COMPILE_TESSELLATION)
    struct UnityTessellationFactors {
        float edge[3] : SV_TessFactor;
        float inside : SV_InsideTessFactor;
    };

    #include "UnityShaderVariables.cginc"

    float UnityCalcEdgeTessFactor(float3 wpos0, float3 wpos1, float edgeLen)
    {
        // distance to edge center
        float dist = distance(0.5 * (wpos0 + wpos1), _WorldSpaceCameraPos);
        // length of the edge
        float len = distance(wpos0, wpos1);
        // edgeLen is approximate desired size in pixels
        float f = max(len * _ScreenParams.y / (edgeLen * dist), 1.0);
        return f;
    }

    float UnityDistanceFromPlane(float3 pos, float4 plane)
    {
        float d = dot(float4(pos, 1.0f), plane);
        return d;
    }

    // Returns true if triangle with given 3 world positions is outside of camera's view frustum.
    // cullEps is distance outside of frustum that is still considered to be inside (i.e. max displacement)
    bool UnityWorldViewFrustumCull(float3 wpos0, float3 wpos1, float3 wpos2, float cullEps)
    {
        float4 planeTest;

        // left
        planeTest.x = ((UnityDistanceFromPlane(wpos0, unity_CameraWorldClipPlanes[0]) > -cullEps) ? 1.0f : 0.0f) +
            ((UnityDistanceFromPlane(wpos1, unity_CameraWorldClipPlanes[0]) > -cullEps) ? 1.0f : 0.0f) +
            ((UnityDistanceFromPlane(wpos2, unity_CameraWorldClipPlanes[0]) > -cullEps) ? 1.0f : 0.0f);
        // right
        planeTest.y = ((UnityDistanceFromPlane(wpos0, unity_CameraWorldClipPlanes[1]) > -cullEps) ? 1.0f : 0.0f) +
            ((UnityDistanceFromPlane(wpos1, unity_CameraWorldClipPlanes[1]) > -cullEps) ? 1.0f : 0.0f) +
            ((UnityDistanceFromPlane(wpos2, unity_CameraWorldClipPlanes[1]) > -cullEps) ? 1.0f : 0.0f);
        // top
        planeTest.z = ((UnityDistanceFromPlane(wpos0, unity_CameraWorldClipPlanes[2]) > -cullEps) ? 1.0f : 0.0f) +
            ((UnityDistanceFromPlane(wpos1, unity_CameraWorldClipPlanes[2]) > -cullEps) ? 1.0f : 0.0f) +
            ((UnityDistanceFromPlane(wpos2, unity_CameraWorldClipPlanes[2]) > -cullEps) ? 1.0f : 0.0f);
        // bottom
        planeTest.w = ((UnityDistanceFromPlane(wpos0, unity_CameraWorldClipPlanes[3]) > -cullEps) ? 1.0f : 0.0f) +
            ((UnityDistanceFromPlane(wpos1, unity_CameraWorldClipPlanes[3]) > -cullEps) ? 1.0f : 0.0f) +
            ((UnityDistanceFromPlane(wpos2, unity_CameraWorldClipPlanes[3]) > -cullEps) ? 1.0f : 0.0f);

        // has to pass all 4 plane tests to be visible
        return !all(planeTest);
    }

    // Same as UnityEdgeLengthBasedTess, but also does patch frustum culling:
    // patches outside of camera's view are culled before GPU tessellation. Saves some wasted work.
    float4 UnityEdgeLengthBasedTessCull(float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement)
    {
        float3 pos0 = mul(unity_ObjectToWorld, v0).xyz;
        float3 pos1 = mul(unity_ObjectToWorld, v1).xyz;
        float3 pos2 = mul(unity_ObjectToWorld, v2).xyz;
        float4 tess;

        if (UnityWorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement))
        {
            tess = 0.0f;
        }
        else
        {
            tess.x = UnityCalcEdgeTessFactor(pos1, pos2, edgeLength);
            tess.y = UnityCalcEdgeTessFactor(pos2, pos0, edgeLength);
            tess.z = UnityCalcEdgeTessFactor(pos0, pos1, edgeLength);
            tess.w = (tess.x + tess.y + tess.z) / 3.0f;
        }
        return tess;
    }




    struct ATessellationInput {
        float4 vertex : INTERNALTESSPOS;
        half3 normal : NORMAL;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
    #ifdef A_UV2_ON
        float4 uv2 : TEXCOORD2;
    #endif
    #ifdef A_TANGENT_ON
        half4 tangent : TANGENT;
    #endif
        half4 color : COLOR;
    };
    
    float _EdgeLength;
    
    #if A_USE_TESSELLATION_MIN_EDGE_LENGTH
        float _MinEdgeLength;
    #endif

    #ifdef _TESSELLATIONMODE_DISPLACEMENT
        A_SAMPLER_2D(_DispTex);
        float _Displacement;
    #endif
    #ifdef _TESSELLATIONMODE_PHONG
        float _Phong;
    #endif

    // NOTE: Forward-declared here so we can share Domain shader.
    void aMainVertexShader(AVertexInput v, 
    #ifndef A_VERTEX_TO_FRAGMENT_OFF
        out AFragmentInput o,
    #endif
        out float4 opos : SV_POSITION);
    
    // tessellation hull constant shader
    UnityTessellationFactors aHullConstantTessellation(
        InputPatch<ATessellationInput, 3> v) 
    {
        float4 tf = 0.0f;
        float maxDisplacement = 0.0f;
        UnityTessellationFactors o;
    
    #ifdef _TESSELLATIONMODE_DISPLACEMENT
        maxDisplacement = 1.5f * _Displacement;
    #endif
    
        float edgeLength = _EdgeLength;
        
    #if A_USE_TESSELLATION_MIN_EDGE_LENGTH
        edgeLength = max(_MinEdgeLength, edgeLength);
    #endif
      
        tf = UnityEdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, maxDisplacement);

        o.edge[0] = tf.x; 
        o.edge[1] = tf.y; 
        o.edge[2] = tf.z; 
        o.inside = tf.w;
        return o;
    }

    ATessellationInput aMainTessellationVertexShader(
        AVertexInput v) 
    {
        ATessellationInput o;

        UNITY_INITIALIZE_OUTPUT(ATessellationInput, o);
        o.vertex = v.vertex;
        o.normal = v.normal;
        o.uv0 = v.uv0;
        o.uv1 = v.uv1;
      
    #ifdef A_UV2_ON
        o.uv2 = v.uv2;
    #endif
    #ifdef A_TANGENT_ON
        o.tangent = v.tangent;
    #endif
        o.color = v.color;

        return o;
    }

    // tessellation hull shader
    [UNITY_domain("tri")]
    [UNITY_partitioning("fractional_odd")]
    [UNITY_outputtopology("triangle_cw")]
    [UNITY_patchconstantfunc("aHullConstantTessellation")]
    [UNITY_outputcontrolpoints(3)]
    ATessellationInput aMainHullShader(
        InputPatch<ATessellationInput, 3> v, 
        uint id : SV_OutputControlPointID) 
    {
        return v[id];
    }

    [UNITY_domain("tri")]
    void aMainDomainShader(
        UnityTessellationFactors tessFactors,
        const OutputPatch<ATessellationInput, 3> vi,
        float3 bary : SV_DomainLocation,
    #ifndef A_VERTEX_TO_FRAGMENT_OFF
        out AFragmentInput o,
    #endif
        out float4 opos : SV_POSITION)
    {
        AVertexInput v;
        UNITY_INITIALIZE_OUTPUT(AVertexInput, v);

        v.vertex = vi[0].vertex * bary.x + vi[1].vertex * bary.y + vi[2].vertex * bary.z;
        v.normal = vi[0].normal * bary.x + vi[1].normal * bary.y + vi[2].normal * bary.z;
        v.uv0 = vi[0].uv0 * bary.x + vi[1].uv0 * bary.y + vi[2].uv0 * bary.z;
        v.uv1 = vi[0].uv1 * bary.x + vi[1].uv1 * bary.y + vi[2].uv1 * bary.z;	 

    #ifdef A_UV2_ON
        v.uv2 = vi[0].uv2 * bary.x + vi[1].uv2 * bary.y + vi[2].uv2 * bary.z;	  
    #endif
    #ifdef A_TANGENT_ON
        v.tangent = vi[0].tangent * bary.x + vi[1].tangent * bary.y + vi[2].tangent * bary.z;
    #endif
        v.color = vi[0].color * bary.x + vi[1].color * bary.y + vi[2].color * bary.z;

    #ifdef _TESSELLATIONMODE_PHONG
        float3 pp[3];
        
        for (int i = 0; i < 3; ++i)
            pp[i] = v.vertex.xyz - vi[i].normal * (dot(v.vertex.xyz, vi[i].normal) - dot(vi[i].vertex.xyz, vi[i].normal));
        
        float3 displacedPosition = pp[0] * bary.x + pp[1] * bary.y + pp[2] * bary.z;
        v.vertex.xyz = lerp(v.vertex.xyz, displacedPosition, _Phong);
    #endif
    
    // NOTE: This has to come second, since the Phong mode references the 
    // unmodified vertices in order to work!
    #ifdef _TESSELLATIONMODE_DISPLACEMENT
        float d = _Displacement;
        float oscillation = _Time.y;
        float2 tessUv = TRANSFORM_TEX(v.uv0.xy, _DispTex) + (_DispTexVelocity * oscillation);
        
        #ifdef _VIRTUALTEXTURING_ON
            d *= VTVertexSampleDisplacement(tessUv);
        #else
            d *= tex2Dlod(_DispTex, float4(tessUv, 0.0f, 0.0f)).g;
        #endif
        
        v.vertex.xyz += v.normal * d;
    #endif

        aMainVertexShader(
            v, 
    #ifndef A_VERTEX_TO_FRAGMENT_OFF
            o, 
    #endif
            opos);
    }
#endif

#endif // ALLOY_SHADERS_FRAMEWORK_TESSELLATION_CGINC
