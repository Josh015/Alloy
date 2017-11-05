// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy Mods/Deferred Decal Advanced" {
Properties {
    [Toggle(EFFECT_BUMP)]
    _HasBumpMap ("'Normals Source' {Dropdown:{VertexNormals:{_BumpMap,_BumpScale,_DetailNormalMap,_DetailNormalMapScale,_WetNormalMap,_WetNormalMapScale}, NormalMaps:{}}}", Float) = 1
    
    // Main Textures
    _MainTextures ("'Deferred Decal Textures' {Section:{Color:0}}", Float) = 0
    [LM_Albedo] [LM_Transparency] 
    _Color ("'Tint' {}", Color) = (1,1,1,1)
    [HDR]
    _GlowColor("'Glow Tint' {}", Color) = (0,0,0,1)
    [LM_Metallic]
    _SpecTex ("'Glow(R) AO(G) Alpha(B) Rough(A)' {Visualize:{R, G, B, A}}", 2D) = "white" {}
    _SpecTexVelocity ("Scroll", Vector) = (0,0,0,0)
    _SpecTexUV ("UV Set", Float) = 0
    [LM_NormalMap]
    _BumpMap ("'Normals' {Visualize:{NRM}, Parent:_SpecTex}", 2D) = "bump" {}
    _BaseColorVertexTint ("'Vertex Color Tint' {Min:0, Max:1}", Float) = 0
     
    // Main Properties
    _MainPhysicalProperties ("'Deferred Decal Properties' {Section:{Color:1}}", Float) = 0
    [LM_Metallic]
    _Metal ("'Metallic' {Min:0, Max:1}", Float) = 1
    _Specularity ("'Specularity' {Min:0, Max:1}", Float) = 1
    _RoughnessMin ("'Roughness Min' {Min:0, Max:1}", Float) = 0
    _RoughnessMax ("'Roughness Max' {Min:0, Max:1}", Float) = 1
    _AoAsCavity ("'Occlusion Cavity' {Min:0, Max:1}", Float) = 0
    _Occlusion ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
    _BumpScale ("'Normal Strength' {}", Float) = 1

    // Decal Blend
    _DecalBlendProperties ("'Decal Blend' {Section:{Color:2}}", Float) = 0
    _BaseColorWeight ("'Base Color' {Min:0, Max:1}", Float) = 0
    _NormalsWeight ("'Normals' {Min:0, Max:1}", Float) = 0
    
    // Parallax
    [Toggle(_PARALLAXMAP)]
    _ParallaxT ("'Parallax' {Feature:{Color:5}}", Float) = 0
    [Toggle(_BUMPMODE_POM)]
    _BumpMode ("'Mode' {Dropdown:{Parallax:{_MinSamples, _MaxSamples}, POM:{}}}", Float) = 0
    _ParallaxMap ("'Heightmap(G)' {Visualize:{RGB}, Parent:_MainTex}", 2D) = "black" {}
    _Parallax ("'Height' {Min:0, Max:0.08}", Float) = 0.02
    _MinSamples ("'Min Samples' {Min:1}", Float) = 4
    _MaxSamples ("'Max Samples' {Min:1}", Float) = 20

    // Forward Rendering Options
    _ForwardRenderingOptions ("'Forward Rendering Options' {Section:{Color:19}}", Float) = 0
    [ToggleOff] 
    _GlossyReflections ("'Glossy Reflections' {Toggle:{On:{}, Off:{}}}", Float) = 1.0

    // Advanced Options
    _AdvancedOptions ("'Advanced Options' {Section:{Color:20}}", Float) = 0
    _RenderQueue ("'Render Queue' {RenderQueue:{}}", Float) = 0
    _EnableInstancing ("'Enable Instancing' {EnableInstancing:{}}", Float) = 0
}
SubShader {
    Tags { 
        "Queue" = "AlphaTest" 
        "IgnoreProjector" = "True" 
        "RenderType" = "Opaque" 
        "ForceNoShadowCasting" = "True" 
        //"DisableBatching" = "LODFading"
    }
    LOD 300
    Offset -1,-1
    
    Pass {
        Name "DEFERRED"
        Tags { "LightMode" = "Deferred" }

        // Only overwrite G-Buffer RGB, but weight whole G-Buffer.
        Blend SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers nomrt gles
        
        #pragma shader_feature EFFECT_BUMP
        #pragma shader_feature _PARALLAXMAP
        #pragma shader_feature _BUMPMODE_POM
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
        
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_prepassfinal
        #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
        #pragma multi_compile_instancing
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_DEFERRED
        #define A_DECAL_ALPHA_FIRSTPASS_SHADER
        
        #include "Assets/Alloy/Mods/Shaders/Definition/DeferredDecalAdvanced.cginc"
        #include "Assets/Alloy/Shaders/Forward/Gbuffer.cginc"

        ENDCG
    }
    
    Pass {
        Name "DEFERRED_ALPHA"
        Tags { "LightMode" = "Deferred" }

        // Only overwrite GBuffer A.
        Blend One One
        ColorMask A

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers nomrt gles
        
        #pragma shader_feature EFFECT_BUMP
        #pragma shader_feature _PARALLAXMAP
        #pragma shader_feature _BUMPMODE_POM
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
        
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_prepassfinal
        #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
        #pragma multi_compile_instancing
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_DEFERRED
        
        #include "Assets/Alloy/Mods/Shaders/Definition/DeferredDecalAdvanced.cginc"
        #include "Assets/Alloy/Shaders/Forward/Gbuffer.cginc"

        ENDCG
    }
} 

FallBack Off
CustomEditor "AlloyFieldBasedEditor"
}
