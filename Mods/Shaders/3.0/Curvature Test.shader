// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy Mods/Curvature Test" {
Properties {
    _CurvatureScale ("'Curvature Scale' {Min:0.001, Max:0.1}", Float) = 0.005

    // Advanced Options
    _AdvancedOptions("'Advanced Options' {Section:{Color:20}}", Float) = 0
    _RenderQueue("'Render Queue' {RenderQueue:{}}", Float) = 0
    _EnableInstancing("'Enable Instancing' {EnableInstancing:{}}", Float) = 0
}

SubShader {
    Tags { 
        "RenderType" = "Opaque" 
        "PerformanceChecks" = "False" 
        "ForceNoShadowCasting" = "True"
        //"DisableBatching" = "LODFading"
    }
    LOD 300

    Pass {
        Name "BASE"
        Tags { "LightMode" = "Always" }
        
        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
                
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_fwdbase
        #pragma multi_compile_fog
        #pragma multi_compile_instancing
            
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_FORWARDBASE
                
        #include "Assets/Alloy/Mods/Shaders/Definition/CurvatureTest.cginc"
        #include "Assets/Alloy/Shaders/Forward/Base.cginc"

        ENDCG
    }
}

FallBack "VertexLit"
CustomEditor "AlloyFieldBasedEditor"
}
