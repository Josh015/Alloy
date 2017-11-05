// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Legacy/Nature/Terrain/4Splat TriPlanar" {
Properties {
    // Splat 0 Properties
    _Splat0Properties ("'Splat 0 Properties' {Section:{Color:0}}", Float) = 0
    _SplatSpecularity0 ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _SplatSpecularTint0 ("'Specular Tint' {Min:0, Max:1}", Float) = 0.0
    
    // Splat 1 Properties
    _Splat1Properties ("'Splat 1 Properties' {Section:{Color:0}}", Float) = 0
    _SplatSpecularity1 ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _SplatSpecularTint1 ("'Specular Tint' {Min:0, Max:1}", Float) = 0.0
    
    // Splat 2 Properties
    _Splat2Properties ("'Splat 2 Properties' {Section:{Color:0}}", Float) = 0
    _SplatSpecularity2 ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _SplatSpecularTint2 ("'Specular Tint' {Min:0, Max:1}", Float) = 0.0
    
    // Splat 3 Properties
    _Splat3Properties ("'Splat 3 Properties' {Section:{Color:0}}", Float) = 0
    _SplatSpecularity3 ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _SplatSpecularTint3 ("'Specular Tint' {Min:0, Max:1}", Float) = 0.0
    
    // Distant Terrain
    _DistantTerrainProperties ("'Distant Terrain' {Section:{Color:1}}", Float) = 0
    _FadeDist ("'Fade Distance' {Min:0}", Float) = 500.0
    _FadeRange ("'Fade Range' {Min:0.0001}", Float) = 100.0
    _DistantSpecularity ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _DistantSpecularTint ("'Specular Tint' {Min:0, Max:1}", Float) = 0
    _DistantRoughness ("'Roughness' {Min:0, Max:1}", Float) = 0.5
    
    // Triplanar
    _TriplanarProperties ("'Triplanar' {Section:{Color:4}}", Float) = 0
    _TriplanarBlendSharpness ("'Sharpness' {Min:1, Max:50}", Float) = 2

    // Detail
    [Toggle(_DETAIL_MULX2)] 
    _DetailT ("'Detail' {Feature:{Color:7}}", Float) = 0
    [Enum(Mul, 0, MulX2, 1)] 
    _DetailMode ("'Color Mode' {Dropdown:{Mul:{}, MulX2:{}}}", Float) = 0
    _DetailAlbedoMap ("'Color(RGB)' {Visualize:{RGB}}", 2D) = "white" {}
    _DetailNormalMap ("'Normals' {Visualize:{NRM}, Parent:_DetailAlbedoMap}", 2D) = "bump" {}
    _DetailWeight ("'Weight' {Min:0, Max:1}", Float) = 1
    _DetailNormalMapScale ("'Normal Strength' {}", Float) = 1

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
    
    // set by terrain engine
    _Control ("Control (RGBA)", 2D) = "red" {}
    _Splat3 ("Layer 3 (A)", 2D) = "white" {}
    _Splat2 ("Layer 2 (B)", 2D) = "white" {}
    _Splat1 ("Layer 1 (G)", 2D) = "white" {}
    _Splat0 ("Layer 0 (R)", 2D) = "white" {}
    _Normal3 ("Normal 3 (A)", 2D) = "bump" {}
    _Normal2 ("Normal 2 (B)", 2D) = "bump" {}
    _Normal1 ("Normal 1 (G)", 2D) = "bump" {}
    _Normal0 ("Normal 0 (R)", 2D) = "bump" {}
    _Metallic0 ("Metallic 0", Range(0.0, 1.0)) = 0.0	
    _Metallic1 ("Metallic 1", Range(0.0, 1.0)) = 0.0	
    _Metallic2 ("Metallic 2", Range(0.0, 1.0)) = 0.0	
    _Metallic3 ("Metallic 3", Range(0.0, 1.0)) = 0.0
    
    // used in fallback on old cards & base map
    _MainTex ("BaseMap (RGB)", 2D) = "white" {}
    _Color ("Main Color", Color) = (1,1,1,1)
}

CGINCLUDE
    #define _METALLICGLOSSMAP
ENDCG

SubShader {
    Tags {
        "SplatCount" = "4"
        "Queue" = "Geometry-100"
        "RenderType" = "Opaque"
    }

    Pass {
        Name "FORWARD" 
        Tags { "LightMode" = "ForwardBase" }

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF

        #pragma multi_compile __ _TERRAIN_NORMAL_MAP
        
        #pragma multi_compile_fwdbase
        #pragma multi_compile_fog
        //#pragma multi_compile __ VTRANSPARENCY_ON
            
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_FORWARDBASE
        
        #include "Assets/Alloy/Shaders/Definition/Terrain.cginc"
        #include "Assets/Alloy/Shaders/Forward/Base.cginc"

        ENDCG
    }
    
    Pass {
        Name "FORWARD_DELTA"
        Tags { "LightMode" = "ForwardAdd" }
        
        Blend One One
        ZWrite Off

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF

        #pragma multi_compile __ _TERRAIN_NORMAL_MAP
        
        #pragma multi_compile_fwdadd_fullshadows
        #pragma multi_compile_fog
        //#pragma multi_compile __ VTRANSPARENCY_ON
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader

        #define UNITY_PASS_FORWARDADD

        #include "Assets/Alloy/Shaders/Definition/Terrain.cginc"
        #include "Assets/Alloy/Shaders/Forward/Add.cginc"

        ENDCG
    }
    
    Pass {
        Name "SHADOWCASTER"
        Tags { "LightMode" = "ShadowCaster" }
        
        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        
        #pragma multi_compile_shadowcaster

        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_SHADOWCASTER
        
        #include "Assets/Alloy/Shaders/Definition/Terrain.cginc"
        #include "Assets/Alloy/Shaders/Forward/Shadow.cginc"

        ENDCG
    }
    
    Pass {
        Name "DEFERRED"
        Tags { "LightMode" = "Deferred" }

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers nomrt gles
        
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF

        #pragma multi_compile __ _TERRAIN_NORMAL_MAP
        
        #pragma multi_compile_prepassfinal
        #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_DEFERRED
        
        #include "Assets/Alloy/Shaders/Definition/Terrain.cginc"
        #include "Assets/Alloy/Shaders/Forward/Gbuffer.cginc"

        ENDCG
    }
    
    Pass {
        Name "Meta"
        Tags { "LightMode" = "Meta" }

        Cull Off

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers nomrt gles
        
        #pragma shader_feature _DETAIL_MULX2
                        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_META
        
        #include "Assets/Alloy/Shaders/Definition/Terrain.cginc"
        #include "Assets/Alloy/Shaders/Forward/Meta.cginc"

        ENDCG
    }
}

Dependency "BaseMapShader" = "Hidden/Alloy/Nature/Terrain/Distant"

Fallback "Hidden/Alloy/Nature/Terrain/Distant"
CustomEditor "AlloyFieldBasedEditor"
}
