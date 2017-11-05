// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Hidden/Alloy/Blur Normals" {
Properties {
    _MainTex ("Render Input", 2D) = "white" {}
}
SubShader {
    ZTest Always Cull Off ZWrite Off Fog { Mode Off }

    CGINCLUDE
    #pragma target 3.0
    #pragma exclude_renderers gles

    #include "Assets/Alloy/Shaders/Framework/Utility.cginc"
    
    #include "HLSLSupport.cginc"
    #include "UnityCG.cginc"
    #include "UnityDeferredLibrary.cginc"

    // Screen-space diffusion
    // cf http://www.iryoku.com/screen-space-subsurface-scattering
    // cf http://uaasoftware.com/xi/PDSS/diffuseShader.fx

    // blurWidth = 0.15
    // blurDepthDifferenceMultiplier = 100
    // distanceToProjectionWindow = 1 / tan(radians(FoV) / 2);
    // blurStepScale = blurWidth * distanceToProjectionWindow
    // blurDepthDifferenceScale = blurDepthDifferenceMultiplier * distanceToProjectionWindow

    /// Number of downsampling texture taps.
    #define A_NUM_DOWNSAMPLE_TAPS 4

    /// Downsampling texture coordinate offset directions.
    static const float2 A_DOWNSAMPLE_OFFSETS[A_NUM_DOWNSAMPLE_TAPS] = {
        float2(0.0f, 0.0f),
        float2(1.0f, 0.0f),
        float2(0.0f, 1.0f),
        float2(1.0f, 1.0f)
    };

    /// Number of blur texture taps.
    #define A_NUM_BLUR_TAPS 7

    /// Gaussian Distribution blur texture coordinate offsets.
    static const float A_BLUR_OFFSETS[A_NUM_BLUR_TAPS] = {
        0.0f, -3.0f, -2.0f, -1.0f, 1.0f, 2.0f, 3.0f
    };

    /// Gaussian Distribution blur sample weights.
    static const half A_BLUR_WEIGHTS[A_NUM_BLUR_TAPS] = {
        0.199471h, 0.0647588h, 0.120985h, 0.176033h, 0.176033h, 0.120985h, 0.0647588h
    };

    /// Number of upsampling texture taps.
    #define A_NUM_UPSAMPLE_TAPS 4

    /// Upsampling texture coordinate offset directions.
    static const float2 A_UPSAMPLE_OFFSETS[A_NUM_UPSAMPLE_TAPS] = {
        float2(0.0f, 1.0f),
        float2(1.0f, 0.0f),
        float2(-1.0f, 0.0f),
        float2(0.0f, -1.0f)
    };

    /// (X: blurStepScale, Y: blurDepthDifferenceScale).
    float2 _DeferredBlurredNormalsParams;
    
    // G-Buffer LAB (transmission in alpha).
    sampler2D _DeferredTransmissionBuffer;

    /// Pass source texture.
    sampler2D _MainTex;

    /// Pass source texture (X: Tiling X, Y: Tiling Y, Z: Offset X, W: Offset Y).
    float4 _MainTex_ST;

    /// Pass source texture (X: 1 / width, Y: 1 / height, Z: width, W: height).
    float4 _MainTex_TexelSize;

    /// Normal buffer.
    sampler2D _CameraGBufferTexture2;

    /// Interpolates offet normals to center normals at edge discontinuities.
    /// @param  normalDepth     Offset sample (XYZ: Normals, W: Depth).
    /// @param  normalDepthM    Center sample (XYZ: Normals, W: Depth).
    /// @return                 Edge-corrected normal.
    half3 aEdgeCorrectNormal(
        half4 normalDepth,
        half4 normalDepthM)
    {
        // Cheaper than a 5-way blend, which requires inverts and an accumulator.
        half alpha = saturate(_DeferredBlurredNormalsParams.y * abs(normalDepth.w - normalDepthM.w));
        return lerp(normalDepth.xyz, normalDepthM.xyz, alpha);
    }
    
    /// Downsamples the G-Buffer normals and depth to 1/2 resolution.
    /// @param  IN  Vertex input.
    /// @return     Downsampled image (XYZ: Normals, W: Nearest Depth).
    half4 aDownsample(
        v2f_img IN) 
    {
        half depth = 1.0h;
        half3 normal = 0.0h;

        UNITY_UNROLL
        for (int i = 1; i < A_NUM_DOWNSAMPLE_TAPS; i++) {
            float2 coord = UnityStereoScreenSpaceUVAdjust(A_DOWNSAMPLE_OFFSETS[i] * _MainTex_TexelSize.xy + IN.uv, _MainTex_ST);
            float4 sampleUv = float4(coord, 0.0f, 0.0f);

            // Pre-combine sample weight with normal scale-bias unpack.
            // 0.25 * (normal * 2 - 1) = normal * 0.5 - 0.25
            normal += tex2Dlod(_MainTex, sampleUv).xyz * 0.5h - 0.25h;

            // Use projection depth directly to avoid linearizing cost per sample.
            depth = min(depth, SAMPLE_DEPTH_TEXTURE_LOD(_CameraDepthTexture, sampleUv));
        }

        // Export unpacked normals and linear depth for subsequent passes.
        return half4(normal, LinearEyeDepth(depth));
    }

    /// Blur the source image along the specified axis.
    /// @param  IN      Vertex input.
    /// @param  axis    Axis on which to blur.
    /// @return         (XYZ: Blurred Normals, W: Sharp Depth).
    half4 aBlurAxis(
        v2f_img IN, 
        float2 axis) 
    {
        // Gaussian Blur.
        half4 normalDepthM = tex2Dlod(_MainTex, float4(UnityStereoScreenSpaceUVAdjust(IN.uv, _MainTex_ST), 0.0f, 0.0f));
        float scale = _DeferredBlurredNormalsParams.x / normalDepthM.w;
        float2 finalStep = scale * axis * _MainTex_TexelSize.xy;
        half3 output = A_BLUR_WEIGHTS[0] * normalDepthM.xyz;

        UNITY_UNROLL
        for (int i = 1; i < A_NUM_BLUR_TAPS; i++) {
            float2 coord = UnityStereoScreenSpaceUVAdjust(A_BLUR_OFFSETS[i] * finalStep + IN.uv, _MainTex_ST);
            half4 normalDepth = tex2Dlod(_MainTex, float4(coord, 0.0f, 0.0f));

            // Lerp back to middle sample when blur sample crosses an edge.
            output += A_BLUR_WEIGHTS[i] * aEdgeCorrectNormal(normalDepth, normalDepthM);
        }

        // Transfer original depth for subsequent passes.
        return half4(output, normalDepthM.w);
    }
    
    /// Upsamples the blurred normals.
    /// @param  IN  Vertex input.
    /// @return     Upsampled, packed blurred normals.
    half4 aUpsample(
        v2f_img IN) 
    {
        // Cross Bilateral Upsample filter.
        half4 normalDepthM;
        half4 output = 0.0h;
        float4 sampleUv = float4(UnityStereoScreenSpaceUVAdjust(IN.uv, _MainTex_ST), 0.0f, 0.0f);

        normalDepthM.xyz = tex2Dlod(_CameraGBufferTexture2, sampleUv).xyz * 2.0f - 1.0f;
        normalDepthM.w = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_LOD(_CameraDepthTexture, sampleUv));

        UNITY_UNROLL
        for (int i = 0; i < A_NUM_UPSAMPLE_TAPS; i++) {
            float2 coord = UnityStereoScreenSpaceUVAdjust(A_UPSAMPLE_OFFSETS[i] * _MainTex_TexelSize.xy + IN.uv, _MainTex_ST);
            half4 normalDepth = tex2Dlod(_MainTex, float4(coord, 0.0f, 0.0f));

            output.xyz += 0.25h * aEdgeCorrectNormal(normalDepth, normalDepthM);
        }

        // Pack normals and transmission for RGBA8 storage.
        output.xyz = normalize(output.xyz) * 0.5h + 0.5h;
        output.w = tex2Dlod(_DeferredTransmissionBuffer, sampleUv).a;
        return output;
    }
    ENDCG
        
    Pass {
        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        #pragma vertex vert_img
        #pragma fragment frag

        half4 frag(v2f_img IN) : SV_Target {
            return aDownsample(IN);
        }
        ENDCG
    }
        
    Pass {
        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        #pragma vertex vert_img
        #pragma fragment frag
            
        half4 frag(v2f_img IN) : SV_Target {
            return aBlurAxis(IN, float2(1.0f, 0.0f));
        }
        ENDCG
    }
        
    Pass {
        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        #pragma vertex vert_img
        #pragma fragment frag

        half4 frag(v2f_img IN) : SV_Target {
            return aBlurAxis(IN, float2(0.0f, 1.0f));
        }
        ENDCG
    }
        
    Pass {
        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        #pragma vertex vert_img
        #pragma fragment frag

        half4 frag(v2f_img IN) : SV_Target {
            return aUpsample(IN);
        }
        ENDCG
    }
}
}