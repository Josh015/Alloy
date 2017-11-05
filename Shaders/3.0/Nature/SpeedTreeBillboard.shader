// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Nature/SpeedTree Billboard" {
Properties {
    // Global Settings
    [LM_TransparencyCutOff] 
    _Cutoff ("'Opacity Cutoff' {Min:0, Max:1}", Float) = 0.5
    [MaterialEnum(None,0,Fastest,1)] 
    _WindQuality ("'Wind Quality' {Dropdown:{None:{}, Fastest:{}}}", Float) = 0
    [Toggle(EFFECT_BUMP)]
    _HasBumpMap ("'Normals Source' {Dropdown:{VertexNormals:{_BumpMap,_BumpScale}, NormalMaps:{}}}", Float) = 1
    
    // Main Textures
    _MainTextures ("'SpeedTree Textures' {Section:{Color:0}}", Float) = 0
    [LM_Albedo] [LM_Transparency] 
    _Color ("'Tint' {}", Color) = (1,1,1,1)	
    [LM_MasterTilingOffset] [LM_Albedo] 
    _MainTex ("'Base Color(RGB) Opacity(A)' {Visualize:{RGB, A}, Controls:False}", 2D) = "white" {}
    [LM_NormalMap]
    _BumpMap ("'Normals' {Visualize:{NRM}, Parent:_MainTex}", 2D) = "bump" {}
    _HueVariation ("'Hue Variation' {}", Color) = (1.0,0.5,0.0,0.1)

    // Main Properties
    _MainPhysicalProperties ("'SpeedTree Properties' {Section:{Color:1}}", Float) = 0
    _BumpScale ("'Normal Strength' {}", Float) = 1

    // Forward Rendering Options
    _ForwardRenderingOptions ("'Forward Rendering Options' {Section:{Color:19}}", Float) = 0
    [ToggleOff] 
    _SpecularHighlights ("'Specular Highlights' {Toggle:{On:{}, Off:{}}}", Float) = 1.0
    [ToggleOff] 
    _GlossyReflections ("'Glossy Reflections' {Toggle:{On:{}, Off:{}}}", Float) = 1.0

    // Advanced Options
    _AdvancedOptions ("'Advanced Options' {Section:{Color:20}}", Float) = 0
    _RenderQueue ("'Render Queue' {RenderQueue:{}}", Float) = 0
}

// NOTE: Instancing disabled because it makes the billboard jump around wildly.

SubShader {
    Tags {
        "Queue" = "AlphaTest"
        "IgnoreProjector" = "True"
        "RenderType" = "TransparentCutout"
        //"DisableBatching" = "LODFading"
    }
    LOD 400

    Pass {
        Name "FORWARD" 
        Tags { "LightMode" = "ForwardBase" }

        Cull Off

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        
        #pragma shader_feature EFFECT_BUMP
        #pragma shader_feature EFFECT_HUE_VARIATION
        #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
        
        #pragma multi_compile __ LOD_FADE_CROSSFADE
        #pragma multi_compile __ BILLBOARD_FACE_CAMERA_POS
        #pragma multi_compile_fwdbase
        #pragma multi_compile_fog
        //#pragma multi_compile __ VTRANSPARENCY_ON
            
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_FORWARDBASE
        
        #include "Assets/Alloy/Shaders/Definition/SpeedTreeBillboard.cginc"
        #include "Assets/Alloy/Shaders/Forward/Base.cginc"

        ENDCG
    }
    
    Pass {
        Name "FORWARD_DELTA"
        Tags { "LightMode" = "ForwardAdd" }
        
        Blend One One
        ZWrite Off
        Cull Off

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        
        #pragma shader_feature EFFECT_BUMP
        #pragma shader_feature EFFECT_HUE_VARIATION
        #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
        
        #pragma multi_compile __ LOD_FADE_CROSSFADE
        #pragma multi_compile __ BILLBOARD_FACE_CAMERA_POS
        #pragma multi_compile_fwdadd_fullshadows
        #pragma multi_compile_fog
        //#pragma multi_compile __ VTRANSPARENCY_ON
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader

        #define UNITY_PASS_FORWARDADD

        #include "Assets/Alloy/Shaders/Definition/SpeedTreeBillboard.cginc"
        #include "Assets/Alloy/Shaders/Forward/Add.cginc"

        ENDCG
    }
    
    Pass {
        Name "SHADOWCASTER"
        Tags { "LightMode" = "ShadowCaster" }
        
        Cull Off

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles

        #pragma multi_compile __ LOD_FADE_CROSSFADE
        #pragma multi_compile __ BILLBOARD_FACE_CAMERA_POS
        #pragma multi_compile_shadowcaster

        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_SHADOWCASTER
        
        #include "Assets/Alloy/Shaders/Definition/SpeedTreeBillboard.cginc"
        #include "Assets/Alloy/Shaders/Forward/Shadow.cginc"

        ENDCG
    }
    
    Pass {
        Name "DEFERRED"
        Tags { "LightMode" = "Deferred" }

        Cull Off

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers nomrt gles
        
        #pragma shader_feature EFFECT_BUMP
        #pragma shader_feature EFFECT_HUE_VARIATION
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
        
        #pragma multi_compile __ LOD_FADE_CROSSFADE
        #pragma multi_compile __ BILLBOARD_FACE_CAMERA_POS
        #pragma multi_compile_prepassfinal
        #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_DEFERRED
        
        #include "Assets/Alloy/Shaders/Definition/SpeedTreeBillboard.cginc"
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
        
        #pragma multi_compile __ LOD_FADE_CROSSFADE
        #pragma multi_compile __ BILLBOARD_FACE_CAMERA_POS

        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_META
        
        #include "Assets/Alloy/Shaders/Definition/SpeedTreeBillboard.cginc"
        #include "Assets/Alloy/Shaders/Forward/Meta.cginc"

        ENDCG
    }
}

FallBack "VertexLit"
CustomEditor "AlloyFieldBasedEditor"
}
