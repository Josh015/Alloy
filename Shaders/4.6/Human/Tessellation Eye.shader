// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Tessellation/Human/Eye" {
Properties {    
    // Eye Textures
    _EyeballTextures ("'Eye Textures' {Section:{Color:0}}", Float) = 0
    [LM_Albedo] [LM_Transparency] 
    _Color ("'Tint' {}", Color) = (1,1,1,1)	
    [LM_MasterTilingOffset] [LM_Albedo] 
    _MainTex ("'Base Color(RGB) Iris(A)' {Visualize:{RGB, A}}", 2D) = "white" {}
    _ParallaxMap ("'Heightmap(G)' {Visualize:{RGB}, Parent:_MainTex}", 2D) = "black" {}
    [LM_NormalMap]
    _BumpMap ("'Normals' {Visualize:{NRM}, Parent:_MainTex}", 2D) = "bump" {}
    _BaseColorVertexTint ("'Vertex Color Tint' {Min:0, Max:1}", Float) = 0
    
    // Cornea Properties 
    _CorneaProperties ("'Cornea' {Section:{Color:1}}", Float) = 0
    _CorneaColor ("'Tint' {}", Color) = (0.5,0.5,0.5,0)
    _CorneaNormalMap ("'Normals' {Visualize:{NRM}, Parent:_MainTex}", 2D) = "bump" {}
    _CorneaSpecularity ("'Specularity' {Min:0, Max:1}", Float) = 0.36
    _CorneaRoughness ("'Roughness' {Min:0, Max:1}", Float) = 0.1
    _CorneaNormalMapScale ("'Normal Strength' {}", Float) = 1
     
    // Iris Properties 
    _IrisProperties("'Iris' {Section:{Color:2}}", Float) = 0
    _IrisColor ("'Tint' {}", Color) = (1,1,1)
    _Parallax ("'Depth' {Min:0, Max:0.08}", Float) = 0.02
    _IrisPupilSize ("'Pupil Dilation' {Min:0, Max:1}", Float) = 0
    _IrisShadowing ("'Shadowing' {Min:0.01}", Float) = 1.1
    _IrisScatterIntensity ("'Scatter Intensity' {Min:0}", Float) = 2
    _IrisScatterPower ("'Scatter Power' {Min:0.01}", Float) = 2.5
    
    // Sclera Properties 
    _ScleraProperties ("'Sclera' {Section:{Color:3}}", Float) = 0
    _ScleraColor ("'Tint' {}", Color) = (1,1,1)
    _ScleraSpecularity ("'Specularity' {Min:0, Max:1}", Float) = 0.36
    _ScleraRoughness ("'Roughness' {Min:0, Max:1}", Float) = 0.1
    _ScleraNormalMapScale ("'Normal Strength' {}", Float) = 1
    
    // Tessellation
    _TessellationProperties ("'Tessellation' {Section:{Color:5}}", Float) = 0
    [KeywordEnum(Displacement, Phong)] 
    _TessellationMode ("'Mode' {Dropdown:{Displacement:{_Phong}, Phong:{_DispTex, _Displacement}}}", Float) = 0
    _DispTex ("'Heightmap(G)' {Visualize:{RGB}}", 2D) = "black" {}
    _DispTexVelocity ("Scroll", Vector) = (0,0,0,0)
    _Displacement ("'Displacement' {Min:0, Max:30}", Float) = 0.3	
    _Phong ("'Phong Strength' {Min:0, Max:1}", Float) = 0.5
    _EdgeLength ("'Edge Length' {Min:2, Max:50}", Float) = 15
    
    // Detail
    [Toggle(_DETAIL_MULX2)] 
    _DetailT ("'Detail' {Feature:{Color:7}}", Float) = 0
    _DetailNormalMap ("'Normals' {Visualize:{NRM}}", 2D) = "bump" {}
    _DetailWeight ("'Weight' {Min:0, Max:1}", Float) = 1
    _DetailNormalMapScale ("'Normal Strength' {}", Float) = 1

    // Decal
    [Toggle(_DECAL_ON)] 
    _Decal ("'Decal' {Feature:{Color:9}}", Float) = 0	
    _DecalColor ("'Tint' {}", Color) = (1,1,1,1)
    _DecalTex ("'Base Color(RGB) Opacity(A)' {Visualize:{RGB, A}}", 2D) = "black" {} 
    _DecalTexUV ("UV Set", Float) = 0
    _DecalWeight ("'Weight' {Min:0, Max:1}", Float) = 1
    _DecalSpecularity ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _DecalAlphaVertexTint ("'Vertex Alpha Tint' {Min:0, Max:1}", Float) = 0

    // Emission 
    [Toggle(_EMISSION)] 
    _Emission ("'Emission' {Feature:{Color:10}}", Float) = 0
    [LM_Emission] 
    [HDR]
    _EmissionColor ("'Tint' {}", Color) = (1,1,1)
    [LM_Emission] 
    _EmissionMap ("'Mask(RGB)' {Visualize:{RGB}, Parent:_MainTex}", 2D) = "white" {}
    _IncandescenceMap ("'Effect(RGB)' {Visualize:{RGB}}", 2D) = "white" {} 
    _IncandescenceMapVelocity ("Scroll", Vector) = (0,0,0,0) 
    _IncandescenceMapUV ("UV Set", Float) = 0
    [Gamma]
    _EmissionWeight ("'Weight' {Min:0, Max:1}", Float) = 1

    // Rim Emission 
    [Toggle(_RIM_ON)] 
    _Rim ("'Rim Emission' {Feature:{Color:11}}", Float) = 0
    [HDR]
    _RimColor ("'Tint' {}", Color) = (1,1,1)
    _RimTex ("'Effect(RGB)' {Visualize:{RGB}}", 2D) = "white" {}
    _RimTexVelocity ("Scroll", Vector) = (0,0,0,0) 
    _RimTexUV ("UV Set", Float) = 0
    [Gamma]
    _RimWeight ("'Weight' {Min:0, Max:1}", Float) = 1
    [Gamma]
    _RimBias ("'Fill' {Min:0, Max:1}", Float) = 0
    _RimPower ("'Falloff' {Min:0.01}", Float) = 4

    // Dissolve 
    [Toggle(_DISSOLVE_ON)] 
    _Dissolve ("'Dissolve' {Feature:{Color:12}}", Float) = 0
    [HDR]
    _DissolveGlowColor ("'Glow Tint' {}", Color) = (1,1,1,1)
    _DissolveTex ("'Glow Color(RGB) Opacity(A)' {Visualize:{RGB, A}}", 2D) = "white" {} 
    _DissolveTexUV ("UV Set", Float) = 0
    _DissolveCutoff ("'Cutoff' {Min:0, Max:1}", Float) = 0
    [Gamma]
    _DissolveGlowWeight ("'Glow Weight' {Min:0, Max:1}", Float) = 1
    _DissolveEdgeWidth ("'Glow Width' {Min:0, Max:1}", Float) = 0.01

    // Forward Rendering Options
    _ForwardRenderingOptions ("'Forward Rendering Options' {Section:{Color:19}}", Float) = 0
    [ToggleOff] 
    _SpecularHighlights ("'Specular Highlights' {Toggle:{On:{}, Off:{}}}", Float) = 1.0
    [ToggleOff] 
    _GlossyReflections ("'Glossy Reflections' {Toggle:{On:{}, Off:{}}}", Float) = 1.0

    // Advanced Options
    _AdvancedOptions ("'Advanced Options' {Section:{Color:20}}", Float) = 0
    _Lightmapping ("'GI' {LightmapEmissionProperty:{}}", Float) = 1
    _RenderQueue ("'Render Queue' {RenderQueue:{}}", Float) = 0
    _EnableInstancing ("'Enable Instancing' {EnableInstancing:{}}", Float) = 0
}

CGINCLUDE
    #define A_TESSELLATION_SHADER
ENDCG

SubShader {
    Tags { 
        "Queue" = "Geometry" 
        "RenderType" = "Opaque"
        //"DisableBatching" = "LODFading"
    }
    LOD 400

    Pass {
        Name "FORWARD" 
        Tags { "LightMode" = "ForwardBase" }

        CGPROGRAM
        //#pragma target 4.6
        #pragma exclude_renderers gles
        
        #pragma shader_feature _TESSELLATIONMODE_DISPLACEMENT _TESSELLATIONMODE_PHONG
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _EMISSION
        #pragma shader_feature _RIM_ON
        #pragma shader_feature _DISSOLVE_ON
        #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
        
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_fwdbase
        #pragma multi_compile_fog
        #pragma multi_compile_instancing
        //#pragma multi_compile __ VTRANSPARENCY_ON
            
        #pragma hull aMainHullShader
        #pragma vertex aMainTessellationVertexShader
        #pragma domain aMainDomainShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_FORWARDBASE
        
        #include "Assets/Alloy/Shaders/Definition/Eye.cginc"
        #include "Assets/Alloy/Shaders/Forward/Base.cginc"

        ENDCG
    }
    
    Pass {
        Name "FORWARD_DELTA"
        Tags { "LightMode" = "ForwardAdd" }
        
        Blend One One
        ZWrite Off

        CGPROGRAM
        //#pragma target 4.6
        #pragma exclude_renderers gles
        
        #pragma shader_feature _TESSELLATIONMODE_DISPLACEMENT _TESSELLATIONMODE_PHONG
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _DISSOLVE_ON
        #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
        
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_fwdadd_fullshadows
        #pragma multi_compile_fog
        //#pragma multi_compile __ VTRANSPARENCY_ON
        
        #pragma hull aMainHullShader
        #pragma vertex aMainTessellationVertexShader
        #pragma domain aMainDomainShader
        #pragma fragment aMainFragmentShader

        #define UNITY_PASS_FORWARDADD

        #include "Assets/Alloy/Shaders/Definition/Eye.cginc"
        #include "Assets/Alloy/Shaders/Forward/Add.cginc"

        ENDCG
    }
    
    Pass {
        Name "SHADOWCASTER"
        Tags { "LightMode" = "ShadowCaster" }
        
        CGPROGRAM
        //#pragma target 4.6
        #pragma exclude_renderers gles
        
        #pragma shader_feature _TESSELLATIONMODE_DISPLACEMENT _TESSELLATIONMODE_PHONG
        #pragma shader_feature _DISSOLVE_ON
        
        #pragma multi_compile_shadowcaster
        #pragma multi_compile_instancing

        #pragma hull aMainHullShader
        #pragma vertex aMainTessellationVertexShader
        #pragma domain aMainDomainShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_SHADOWCASTER
        
        #include "Assets/Alloy/Shaders/Definition/Eye.cginc"
        #include "Assets/Alloy/Shaders/Forward/Shadow.cginc"

        ENDCG
    }
    
    Pass {
        Name "DEFERRED"
        Tags { "LightMode" = "Deferred" }

        CGPROGRAM
        //#pragma target 4.6
        #pragma exclude_renderers gles
        
        #pragma shader_feature _TESSELLATIONMODE_DISPLACEMENT _TESSELLATIONMODE_PHONG
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _EMISSION
        #pragma shader_feature _RIM_ON
        #pragma shader_feature _DISSOLVE_ON
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
        
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_prepassfinal
        #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
        #pragma multi_compile_instancing
        
        #pragma hull aMainHullShader
        #pragma vertex aMainTessellationVertexShader
        #pragma domain aMainDomainShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_DEFERRED
        
        #include "Assets/Alloy/Shaders/Definition/Eye.cginc"
        #include "Assets/Alloy/Shaders/Forward/Gbuffer.cginc"

        ENDCG
    }
    
    Pass {
        Name "Meta"
        Tags { "LightMode" = "Meta" }

        Cull Off

        CGPROGRAM
        //#pragma target 4.6
        #pragma exclude_renderers nomrt gles
        
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _EMISSION
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_META
        
        #include "Assets/Alloy/Shaders/Definition/Eye.cginc"
        #include "Assets/Alloy/Shaders/Forward/Meta.cginc"

        ENDCG
    }
}

FallBack "Alloy/Human/Eye"
CustomEditor "AlloyFieldBasedEditor"
}
