// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Legacy/Vertex Blend/4Splat" {
Properties {
    // Global Settings
    _Mode ("'Rendering Mode' {RenderingMode:{Opaque:{_Cutoff}, Cutout:{}, Fade:{_Cutoff}, Transparent:{_Cutoff}}}", Float) = 0
    _SrcBlend ("__src", Float) = 0
    _DstBlend ("__dst", Float) = 0
    _ZWrite ("__zw", Float) = 1
    [LM_TransparencyCutOff] 
    _Cutoff ("'Opacity Cutoff' {Min:0, Max:1}", Float) = 0.5
    [Toggle(EFFECT_BUMP)]
    _HasBumpMap ("'Normals Source' {Dropdown:{VertexNormals:{_Normal0,_Normal1,_Normal2,_Normal3,_DetailNormalMap,_DetailNormalMapScale}, NormalMaps:{}}}", Float) = 1
    
    // Splat0 Properties
    _Splat0Properties ("'Splat0' {Section:{Color:0}}", Float) = 0
    _Splat0Tint ("'Tint' {}", Color) = (1,1,1,1)
    _Splat0 ("'Base Color(RGB) Rough(A)' {Visualize:{RGB, A}}", 2D) = "white" {}
    _Splat0Velocity ("Scroll", Vector) = (0,0,0,0) 
    _Splat0UV ("UV Set", Float) = 0
    _Normal0 ("'Normals' {Visualize:{NRM}, Parent:_Splat0}", 2D) = "bump" {}
    _Metallic0 ("'Metallic' {Min:0, Max:1}", Float) = 0.0
    _SplatSpecularity0 ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _SplatSpecularTint0 ("'Specular Tint' {Min:0, Max:1}", Float) = 0.0
    _SplatRoughness0 ("'Roughness' {Min:0, Max:1}", Float) = 1.0

    // Splat1 Properties
    _Splat1Properties ("'Splat1' {Section:{Color:0}}", Float) = 0
    _Splat1Tint ("'Tint' {}", Color) = (1,1,1,1)
    _Splat1 ("'Base Color(RGB) Rough(A)' {Visualize:{RGB, A}}", 2D) = "white" {}	
    _Splat1Velocity ("Scroll", Vector) = (0,0,0,0) 
    _Splat1UV ("UV Set", Float) = 0
    _Normal1 ("'Normals' {Visualize:{NRM}, Parent:_Splat1}", 2D) = "bump" {}
    _Metallic1 ("'Metallic' {Min:0, Max:1}", Float) = 0.0
    _SplatSpecularity1 ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _SplatSpecularTint1 ("'Specular Tint' {Min:0, Max:1}", Float) = 0.0
    _SplatRoughness1 ("'Roughness' {Min:0, Max:1}", Float) = 1.0

    // Splat2 Properties
    _Splat2Properties ("'Splat2' {Section:{Color:0}}", Float) = 0
    _Splat2Tint ("'Tint' {}", Color) = (1,1,1,1)
    _Splat2 ("'Base Color(RGB) Rough(A)' {Visualize:{RGB, A}}", 2D) = "white" {}	
    _Splat2Velocity ("Scroll", Vector) = (0,0,0,0) 
    _Splat2UV ("UV Set", Float) = 0
    _Normal2 ("'Normals' {Visualize:{NRM}, Parent:_Splat2}", 2D) = "bump" {}
    _Metallic2 ("'Metallic' {Min:0, Max:1}", Float) = 0.0
    _SplatSpecularity2 ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _SplatSpecularTint2 ("'Specular Tint' {Min:0, Max:1}", Float) = 0.0
    _SplatRoughness2 ("'Roughness' {Min:0, Max:1}", Float) = 1.0
    
    // Splat3 Properties
    _Splat3Properties ("'Splat3' {Section:{Color:0}}", Float) = 0
    _Splat3Tint ("'Tint' {}", Color) = (1,1,1,1)
    _Splat3 ("'Base Color(RGB) Rough(A)' {Visualize:{RGB, A}}", 2D) = "white" {}	
    _Splat3Velocity ("Scroll", Vector) = (0,0,0,0) 
    _Splat3UV ("UV Set", Float) = 0
    _Normal3 ("'Normals' {Visualize:{NRM}, Parent:_Splat3}", 2D) = "bump" {}
    _Metallic3 ("'Metallic' {Min:0, Max:1}", Float) = 0.0
    _SplatSpecularity3 ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _SplatSpecularTint3 ("'Specular Tint' {Min:0, Max:1}", Float) = 0.0
    _SplatRoughness3 ("'Roughness' {Min:0, Max:1}", Float) = 1.0
    
    // AO2
    [Toggle(_AO2_ON)] 
    _AO2 ("'AO2' {Feature:{Color:6}}", Float) = 0
    _Ao2Map ("'AO2(G)' {Visualize:{RGB}}", 2D) = "white" {} 
    _Ao2MapUV ("UV Set", Float) = 1
    _Ao2Occlusion ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
    
    // Detail
    [Toggle(_DETAIL_MULX2)] 
    _DetailT ("'Detail' {Feature:{Color:7}}", Float) = 0
    [Enum(Mul, 0, MulX2, 1)] 
    _DetailMode ("'Color Mode' {Dropdown:{Mul:{}, MulX2:{}}}", Float) = 0
    _DetailAlbedoMap ("'Color(RGB)' {Visualize:{RGB}}", 2D) = "white" {}
    _DetailAlbedoMapUV ("UV Set", Float) = 0
    _DetailNormalMap ("'Normals' {Visualize:{NRM}, Parent:_DetailAlbedoMap}", 2D) = "bump" {}
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

SubShader {
    Tags { 
        "RenderType" = "Opaque" 
        "PerformanceChecks" = "False"
        //"DisableBatching" = "LODFading"
    }
    LOD 300

    Pass {
        Name "FORWARD" 
        Tags { "LightMode" = "ForwardBase" }

        Blend [_SrcBlend] [_DstBlend]
        ZWrite [_ZWrite]

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        
        #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
        #pragma shader_feature EFFECT_BUMP
        #pragma shader_feature _AO2_ON
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
        
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_fwdbase
        #pragma multi_compile_fog
        #pragma multi_compile_instancing
        //#pragma multi_compile __ VTRANSPARENCY_ON
            
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_FORWARDBASE
        
        #include "Assets/Alloy/Legacy/Shaders/Definition/VertexBlend.cginc"
        #include "Assets/Alloy/Shaders/Forward/Base.cginc"

        ENDCG
    }
    
    Pass {
        Name "FORWARD_DELTA"
        Tags { "LightMode" = "ForwardAdd" }
        
        Blend [_SrcBlend] One
        ZWrite Off

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        
        #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
        #pragma shader_feature EFFECT_BUMP
        #pragma shader_feature _AO2_ON
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
        
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_fwdadd_fullshadows
        #pragma multi_compile_fog
        //#pragma multi_compile __ VTRANSPARENCY_ON
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader

        #define UNITY_PASS_FORWARDADD

        #include "Assets/Alloy/Legacy/Shaders/Definition/VertexBlend.cginc"
        #include "Assets/Alloy/Shaders/Forward/Add.cginc"

        ENDCG
    }
    
    Pass {
        Name "SHADOWCASTER"
        Tags { "LightMode" = "ShadowCaster" }
        
        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles

        #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
        
        #pragma multi_compile_shadowcaster
        #pragma multi_compile_instancing

        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_SHADOWCASTER
        
        #include "Assets/Alloy/Legacy/Shaders/Definition/VertexBlend.cginc"
        #include "Assets/Alloy/Shaders/Forward/Shadow.cginc"

        ENDCG
    }
    
    Pass {
        Name "DEFERRED"
        Tags { "LightMode" = "Deferred" }

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers nomrt gles

        #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
        #pragma shader_feature EFFECT_BUMP
        #pragma shader_feature _AO2_ON
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
        
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_prepassfinal
        #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
        #pragma multi_compile_instancing
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_DEFERRED
        
        #include "Assets/Alloy/Legacy/Shaders/Definition/VertexBlend.cginc"
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
        #pragma shader_feature _DECAL_ON
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_META
        
        #include "Assets/Alloy/Legacy/Shaders/Definition/VertexBlend.cginc"
        #include "Assets/Alloy/Shaders/Forward/Meta.cginc"

        ENDCG
    }
}

Fallback "VertexLit"
CustomEditor "AlloyFieldBasedEditor"
}
