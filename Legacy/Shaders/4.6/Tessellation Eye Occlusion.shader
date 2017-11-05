// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/
 
Shader "Alloy/Legacy/Tessellation/Human/Eye/Occlusion" {
Properties {
    // Main Textures
    _MainTextures ("'Eye OcclusionTextures' {Section:{Color:0}}", Float) = 0
    _Color ("'Tint' {}", Color) = (1,1,1,1)	
    _MainTex ("'Base Color(RGB) Opacity(A)' {Visualize:{RGB, A}}", 2D) = "white" {}
    _MainTexVelocity ("Scroll", Vector) = (0,0,0,0) 
    _MainTexUV ("UV Set", Float) = 0
    _AoMap ("'Ambient Occlusion(G)' {Visualize:{RGB}, Parent:_MainTex}", 2D) = "white" {}
    _BaseColorVertexTint ("'Vertex Color Tint' {Min:0, Max:1}", Float) = 0
     
    // Main Properties
    _MainPhysicalProperties ("'Main Properties' {Section:{Color:1}}", Float) = 0
    _Occlusion ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
    
    // Tessellation
    _TessellationProperties ("'Tessellation' {Section:{Color:5}}", Float) = 0
    [KeywordEnum(Displacement, Phong)] 
    _TessellationMode ("'Mode' {Dropdown:{Displacement:{_Phong}, Phong:{_DispTex, _Displacement}}}", Float) = 0
    _DispTex ("'Heightmap(G)' {Visualize:{RGB}}", 2D) = "black" {}
    _DispTexVelocity ("Scroll", Vector) = (0,0,0,0)
    _Displacement ("'Displacement' {Min:0, Max:30}", Float) = 0.3	
    _Phong ("'Phong Strength' {Min:0, Max:1}", Float) = 0.5
    _EdgeLength ("'Edge Length' {Min:2, Max:50}", Float) = 15

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

    // Advanced Options
    _AdvancedOptions ("'Advanced Options' {Section:{Color:20}}", Float) = 0
    _RenderQueue ("'Render Queue' {RenderQueue:{}}", Float) = 0
    _EnableInstancing ("'Enable Instancing' {EnableInstancing:{}}", Float) = 0
}

CGINCLUDE
    #define _ALPHAPREMULTIPLY_ON
    #define A_TESSELLATION_SHADER
ENDCG

SubShader {
    Tags {
        "Queue" = "Transparent-1" 
        "IgnoreProjector" = "True" 
        "RenderType" = "Transparent" 
        "ForceNoShadowCasting" = "True"
        //"DisableBatching" = "LODFading"
    }
    LOD 400
    Offset -1,-1

    Pass {
        Name "FORWARD" 
        Tags { "LightMode" = "ForwardBase" }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        CGPROGRAM
        //#pragma target 4.6
        #pragma exclude_renderers gles
        
        #pragma shader_feature _TESSELLATIONMODE_DISPLACEMENT _TESSELLATIONMODE_PHONG
        #pragma shader_feature _DISSOLVE_ON
        
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
        
        #include "Assets/Alloy/Legacy/Shaders/Definition/EyeOcclusion.cginc"
        #include "Assets/Alloy/Shaders/Forward/Base.cginc"

        ENDCG
    }
}

FallBack "Alloy/Legacy/Human/Eye/Occlusion"
CustomEditor "AlloyFieldBasedEditor"
}
