// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Legacy/TriPlanar/Lite" {
Properties {
    // Global Settings
    _Mode ("'Rendering Mode' {RenderingMode:{Opaque:{_Cutoff}, Cutout:{}, Fade:{_Cutoff}, Transparent:{_Cutoff}}}", Float) = 0
    _SrcBlend ("__src", Float) = 0
    _DstBlend ("__dst", Float) = 0
    _ZWrite ("__zw", Float) = 1
    [LM_TransparencyCutOff] 
    _Cutoff ("'Opacity Cutoff' {Min:0, Max:1}", Float) = 0.5
    [Toggle(EFFECT_BUMP)]
    _HasBumpMap ("'Normals Source' {Dropdown:{VertexNormals:{_PrimaryBumpMap,_PrimaryBumpScale,_SecondaryBumpMap,_SecondaryBumpScale,_TertiaryBumpMap,_TertiaryBumpScale,_QuaternaryBumpMap,_QuaternaryBumpScale}, NormalMaps:{}}}", Float) = 1
        
    // Primary Textures 
    _PrimaryTextures ("'Primary Textures' {Section:{Color:0}}", Float) = 0
    _PrimaryColor ("'Tint' {}", Color) = (1,1,1,1)	
    _PrimaryMainTex ("'Base Color(RGB) Rough(A)' {Visualize:{RGB, A}}", 2D) = "white" {}
    _PrimaryMainTexVelocity ("Scroll", Vector) = (0,0,0,0) 
    _PrimaryBumpMap ("'Normals' {Visualize:{NRM}, Parent:_PrimaryMainTex}", 2D) = "bump" {}
    _PrimaryColorVertexTint ("'Vertex Color Tint' {Min:0, Max:1}", Float) = 0
    _PrimaryMetallic ("'Metallic' {Min:0, Max:1}", Float) = 0
    _PrimarySpecularity ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _PrimarySpecularTint ("'Specular Tint' {Min:0, Max:1}", Float) = 0
    _PrimaryRoughness ("'Roughness' {Min:0, Max:1}", Float) = 1
    _PrimaryBumpScale ("'Normal Strength' {}", Float) = 1
    
    // Secondary Textures 
    [Toggle(_SECONDARY_TRIPLANAR_ON)] 
    _SecondaryTextures ("'Secondary Textures' {Feature:{Color:1}}", Float) = 0
    _SecondaryColor ("'Tint' {}", Color) = (1,1,1,1)	
    _SecondaryMainTex ("'Base Color(RGB) Rough(A)' {Visualize:{RGB, A}}", 2D) = "white" {}
    _SecondaryMainTexVelocity ("Scroll", Vector) = (0,0,0,0) 
    _SecondaryBumpMap ("'Normals' {Visualize:{NRM}, Parent:_SecondaryMainTex}", 2D) = "bump" {}
    _SecondaryColorVertexTint ("'Vertex Color Tint' {Min:0, Max:1}", Float) = 0
    _SecondaryMetallic ("'Metallic' {Min:0, Max:1}", Float) = 0
    _SecondarySpecularity ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _SecondarySpecularTint ("'Specular Tint' {Min:0, Max:1}", Float) = 0
    _SecondaryRoughness ("'Roughness' {Min:0, Max:1}", Float) = 1
    _SecondaryBumpScale ("'Normal Strength' {}", Float) = 1
    
    // Tertiary Textures 
    [Toggle(_TERTIARY_TRIPLANAR_ON)] 
    _TertiaryTextures ("'Tertiary Textures' {Feature:{Color:2}}", Float) = 0
    _TertiaryColor ("'Tint' {}", Color) = (1,1,1,1)	
    _TertiaryMainTex ("'Base Color(RGB) Rough(A)' {Visualize:{RGB, A}}", 2D) = "white" {}
    _TertiaryMainTexVelocity ("Scroll", Vector) = (0,0,0,0) 
    _TertiaryBumpMap ("'Normals' {Visualize:{NRM}, Parent:_TertiaryMainTex}", 2D) = "bump" {}
    _TertiaryColorVertexTint ("'Vertex Color Tint' {Min:0, Max:1}", Float) = 0
    _TertiaryMetallic ("'Metallic' {Min:0, Max:1}", Float) = 0
    _TertiarySpecularity ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _TertiarySpecularTint ("'Specular Tint' {Min:0, Max:1}", Float) = 0
    _TertiaryRoughness ("'Roughness' {Min:0, Max:1}", Float) = 1
    _TertiaryBumpScale ("'Normal Strength' {}", Float) = 1

    // Quaternary Textures 
    [Toggle(_QUATERNARY_TRIPLANAR_ON)] 
    _QuaternaryTextures ("'Quaternary Textures' {Feature:{Color:3}}", Float) = 0
    _QuaternaryColor ("'Tint' {}", Color) = (1,1,1,1)	
    _QuaternaryMainTex ("'Base Color(RGB) Rough(A)' {Visualize:{RGB, A}}", 2D) = "white" {}
    _QuaternaryMainTexVelocity ("Scroll", Vector) = (0,0,0,0) 
    _QuaternaryBumpMap ("'Normals' {Visualize:{NRM}, Parent:_QuaternaryMainTex}", 2D) = "bump" {}
    _QuaternaryColorVertexTint ("'Vertex Color Tint' {Min:0, Max:1}", Float) = 0
    _QuaternaryMetallic ("'Metallic' {Min:0, Max:1}", Float) = 0
    _QuaternarySpecularity ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _QuaternarySpecularTint ("'Specular Tint' {Min:0, Max:1}", Float) = 0
    _QuaternaryRoughness ("'Roughness' {Min:0, Max:1}", Float) = 1
    _QuaternaryBumpScale ("'Normal Strength' {}", Float) = 1
    
    // Triplanar
    _TriplanarProperties ("'Triplanar' {Section:{Color:4}}", Float) = 0
    [Toggle(_TRIPLANARMODE_WORLD)]
    _TriplanarMode ("'Mode' {Dropdown:{Object:{}, World:{}}}", Float) = 1
    _TriplanarBlendSharpness ("'Sharpness' {Min:1, Max:50}", Float) = 2
    
    // Rim Emission 
    [Toggle(_RIM_ON)] 
    _Rim ("'Rim Emission' {Feature:{Color:11}}", Float) = 0
    [HDR]
    _RimColor ("'Tint' {}", Color) = (1,1,1)
    [Gamma]
    _RimWeight ("'Weight' {Min:0, Max:1}", Float) = 1
    [Gamma]
    _RimBias ("'Fill' {Min:0, Max:1}", Float) = 0
    _RimPower ("'Falloff' {Min:0.01}", Float) = 4

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
        "Queue" = "Geometry" 
        "RenderType" = "Opaque"
        //"DisableBatching" = "LODFading"
    }
    LOD 400

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
        #pragma shader_feature _TRIPLANARMODE_WORLD
        #pragma shader_feature _SECONDARY_TRIPLANAR_ON
        #pragma shader_feature _TERTIARY_TRIPLANAR_ON
        #pragma shader_feature _QUATERNARY_TRIPLANAR_ON
        #pragma shader_feature _RIM_ON
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
        
        #include "Assets/Alloy/Legacy/Shaders/Definition/TriPlanar.cginc"
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
        #pragma shader_feature _TRIPLANARMODE_WORLD
        #pragma shader_feature _SECONDARY_TRIPLANAR_ON
        #pragma shader_feature _TERTIARY_TRIPLANAR_ON
        #pragma shader_feature _QUATERNARY_TRIPLANAR_ON
        #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
        
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_fwdadd_fullshadows
        #pragma multi_compile_fog
        //#pragma multi_compile __ VTRANSPARENCY_ON
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader

        #define UNITY_PASS_FORWARDADD

        #include "Assets/Alloy/Legacy/Shaders/Definition/TriPlanar.cginc"
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
        #pragma shader_feature _TRIPLANARMODE_WORLD
        #pragma shader_feature _SECONDARY_TRIPLANAR_ON
        #pragma shader_feature _TERTIARY_TRIPLANAR_ON
        #pragma shader_feature _QUATERNARY_TRIPLANAR_ON
        
        #pragma multi_compile_shadowcaster
        #pragma multi_compile_instancing

        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_SHADOWCASTER
        
        #include "Assets/Alloy/Legacy/Shaders/Definition/TriPlanar.cginc"
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
        #pragma shader_feature _TRIPLANARMODE_WORLD
        #pragma shader_feature _SECONDARY_TRIPLANAR_ON
        #pragma shader_feature _TERTIARY_TRIPLANAR_ON
        #pragma shader_feature _QUATERNARY_TRIPLANAR_ON
        #pragma shader_feature _RIM_ON
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
        
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_prepassfinal
        #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
        #pragma multi_compile_instancing
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_DEFERRED
        
        #include "Assets/Alloy/Legacy/Shaders/Definition/TriPlanar.cginc"
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
        
        #pragma shader_feature _TRIPLANARMODE_WORLD
        #pragma shader_feature _SECONDARY_TRIPLANAR_ON
        #pragma shader_feature _TERTIARY_TRIPLANAR_ON
        #pragma shader_feature _QUATERNARY_TRIPLANAR_ON
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_META
        
        #include "Assets/Alloy/Legacy/Shaders/Definition/TriPlanar.cginc"
        #include "Assets/Alloy/Shaders/Forward/Meta.cginc"

        ENDCG
    }
}

FallBack "VertexLit"
CustomEditor "AlloyFieldBasedEditor"
}
