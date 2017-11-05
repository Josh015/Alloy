// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Nature/SpeedTree (Forward)" {
Properties {
    // Global Settings
    _GeometryType ("'Geometry Type' {SpeedTreeGeometryType:{Branch:{_Cutoff,_DetailTex,_DetailNormalMap,_TransmissionProperties,_TransTex,_TransScale,_TransColor,_TransShadowWeight,_TransDistortion,_TransPower}, BranchDetail:{_Cutoff,_TransmissionProperties,_TransTex,_TransScale,_TransColor,_TransShadowWeight,_TransDistortion,_TransPower}, Frond:{_DetailTex,_DetailNormalMap}, Leaf:{_DetailTex,_DetailNormalMap}, Mesh:{_Cutoff,_DetailTex,_DetailNormalMap,_TransmissionProperties,_TransTex,_TransScale,_TransColor,_TransShadowWeight,_TransDistortion,_TransPower}}}", Float) = 0
    [LM_TransparencyCutOff] 
    _Cutoff ("'Opacity Cutoff' {Min:0, Max:1}", Float) = 0.333
    [MaterialEnum(Off,0,Front,1,Back,2)] 
    _Cull ("'Cull Mode' {Dropdown:{Off:{}, Front:{}, Back:{}}}", Int) = 2
    [MaterialEnum(None,0,Fastest,1,Fast,2,Better,3,Best,4,Palm,5)] 
    _WindQuality ("'Wind Quality' {Dropdown:{None:{}, Fastest:{}, Fast:{}, Better:{}, Best:{}, Palm:{}}}", Float) = 0
    [Toggle(EFFECT_BUMP)]
    _HasBumpMap ("'Normals Source' {Dropdown:{VertexNormals:{_BumpMap,_BumpScale,_DetailNormalMap,_WetNormalMap,_WetNormalMapScale}, NormalMaps:{}}}", Float) = 1
    
    // SpeedTree Textures
    _MainTextures ("'SpeedTree Textures' {Section:{Color:0}}", Float) = 0
    [LM_Albedo] [LM_Transparency] 
    _Color ("'Tint' {}", Color) = (1,1,1,1)	
    [LM_MasterTilingOffset] [LM_Albedo] 
    _MainTex ("'Base Color(RGB) Opacity(A)' {Visualize:{RGB, A}, Controls:False}", 2D) = "white" {}
    [LM_NormalMap]
    _BumpMap ("'Normals' {Visualize:{NRM}, Controls:False}", 2D) = "bump" {}
    _DetailTex ("'Detail(RGB) Opacity(A)' {Visualize:{RGB}, Controls:False}", 2D) = "black" {}
    _DetailNormalMap ("'Detail Normals' {Visualize:{NRM}, Controls:False}", 2D) = "bump" {}
    [Toggle(EFFECT_HUE_VARIATION)]
    _HasHueVariation ("'Hue Variation?' {Toggle:{On:{}, Off:{_HueVariation}}}", Float) = 1
    _HueVariation ("'Hue Variation' {}", Color) = (1.0,0.5,0.0,0.1)

    // SpeedTree Properties
    _MainPhysicalProperties ("'SpeedTree Properties' {Section:{Color:1}}", Float) = 0
    _Specularity ("'Specularity' {Min:0, Max:1}", Float) = 1
    _SpecularTint ("'Specular Tint' {Min:0, Max:1}", Float) = 0.0
    _Roughness ("'Roughness' {Min:0, Max:1}", Float) = 0.9
    _Occlusion ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
    _BumpScale ("'Normal Strength' {}", Float) = 1
    
    // Transmission
    _TransmissionProperties ("'Transmission' {Section:{Color:3}}", Float) = 0
    _TransColor ("'Tint' {}", Color) = (1,1,1)
    _TransTex ("'Transmission(A)' {Visualize:{A}, Parent:_MainTex}", 2D) = "white" {}
    //[Gamma]
    _TransScale ("'Weight' {Min:0, Max:1}", Float) = 1.0
    _TransShadowWeight ("'Shadow Weight' {Min:0, Max:1}", Float) = 0.5
    _TransDistortion ("'Bump Distortion' {Min:0, Max:1}", Float) = 0.05
    _TransPower ("'Falloff' {Min:1}", Float) = 1
    
    // Parallax
    [Toggle(_PARALLAXMAP)]
    _ParallaxT ("'Parallax' {Feature:{Color:5}}", Float) = 0
    [Toggle(_BUMPMODE_POM)]
    _BumpMode ("'Mode' {Dropdown:{Parallax:{_MinSamples, _MaxSamples}, POM:{}}}", Float) = 0
    _ParallaxMap ("'Heightmap(G)' {Visualize:{RGB}, Parent:_MainTex}", 2D) = "black" {}
    _Parallax ("'Height' {Min:0, Max:0.08}", Float) = 0.02
    _MinSamples ("'Min Samples' {Min:1}", Float) = 4
    _MaxSamples ("'Max Samples' {Min:1}", Float) = 20
        
    // Team Color
    [Toggle(_TEAMCOLOR_ON)] 
    _TeamColor ("'Team Color' {Feature:{Color:8}}", Float) = 0
    [Enum(Masks, 0, Tint, 1)]
    _TeamColorMasksAsTint ("'Texture Mode' {Dropdown:{Masks:{}, Tint:{_TeamColorMasks, _TeamColor0, _TeamColor1, _TeamColor2, _TeamColor3}}}", Float) = 0
    _TeamColorMaskMap ("'Masks(RGBA)' {Visualize:{R, G, B, A, RGB}, Parent:_MainTex}", 2D) = "black" {}
    _TeamColorMasks ("'Channels' {Vector:Channels}", Vector) = (1,1,1,0)
    _TeamColor0 ("'Tint R' {}", Color) = (1,0,0)
    _TeamColor1 ("'Tint G' {}", Color) = (0,1,0)
    _TeamColor2 ("'Tint B' {}", Color) = (0,0,1)
    _TeamColor3 ("'Tint A' {}", Color) = (0.5,0.5,0.5)
    
    // Decal
    [Toggle(_DECAL_ON)] 
    _Decal ("'Decal' {Feature:{Color:9}}", Float) = 0	
    _DecalColor ("'Tint' {}", Color) = (1,1,1,1)
    _DecalTex ("'Base Color(RGB) Opacity(A)' {Visualize:{RGB, A}}", 2D) = "black" {} 
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
    [Gamma]
    _EmissionWeight ("'Weight' {Min:0, Max:1}", Float) = 1

    // Rim Emission 
    [Toggle(_RIM_ON)] 
    _Rim ("'Rim Emission' {Feature:{Color:11}}", Float) = 0
    [HDR]
    _RimColor ("'Tint' {}", Color) = (1,1,1)
    _RimTex ("'Effect(RGB)' {Visualize:{RGB}}", 2D) = "white" {}
    _RimTexVelocity ("Scroll", Vector) = (0,0,0,0) 
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
    _DissolveCutoff ("'Cutoff' {Min:0, Max:1}", Float) = 0
    [Gamma]
    _DissolveGlowWeight ("'Glow Weight' {Min:0, Max:1}", Float) = 1
    _DissolveEdgeWidth ("'Glow Width' {Min:0, Max:1}", Float) = 0.01
    
    // Wetness
    [Toggle(_WETNESS_ON)]
    _WetnessProperties ("'Wetness' {Feature:{Color:13}}", Float) = 0
    [Toggle(_WETMASKSOURCE_VERTEXCOLORALPHA)]
    _WetMaskSource ("'Mask Source' {Dropdown:{TextureAlpha:{}, VertexColorAlpha:{_WetMask}}}", Float) = 0
    _WetMask ("'Mask(A)' {Visualize:{A}}", 2D) = "white" {}
    _WetMaskVelocity ("Scroll", Vector) = (0,0,0,0)
    _WetMaskUV ("UV Set", Float) = 0
    _WetMaskStrength ("'Mask Strength' {Min:0, Max:1}", Float) = 1
    _WetTint ("'Tint' {}", Color) = (1,1,1,1)
    _WetNormalMap ("'Normals' {Visualize:{NRM}}", 2D) = "bump" {}
    _WetNormalMapVelocity ("Scroll", Vector) = (0,0,0,0)
    _WetNormalMapUV ("UV Set", Float) = 0
    _WetWeight ("'Weight' {Min:0, Max:1}", Float) = 1
    _WetRoughness ("'Roughness' {Min:0, Max:1}", Float) = 0.2
    _WetNormalMapScale ("'Normal Strength' {}", Float) = 1

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
    #define A_FORWARD_ONLY_SHADER
ENDCG

SubShader {
    Tags {
        "Queue" = "Geometry"
        "IgnoreProjector" = "True"
        "RenderType" = "Opaque"
        "DisableBatching" = "LODFading"
    }
    LOD 400

    Pass {
        Name "FORWARD" 
        Tags { "LightMode" = "ForwardBase" }

        Cull [_Cull]

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        
        #pragma shader_feature GEOM_TYPE_BRANCH GEOM_TYPE_BRANCH_DETAIL GEOM_TYPE_FROND GEOM_TYPE_LEAF GEOM_TYPE_MESH
        #pragma shader_feature EFFECT_BUMP
        #pragma shader_feature EFFECT_HUE_VARIATION
        #pragma shader_feature _PARALLAXMAP
        #pragma shader_feature _BUMPMODE_POM
        #pragma shader_feature _TEAMCOLOR_ON
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _EMISSION
        #pragma shader_feature _RIM_ON
        #pragma shader_feature _DISSOLVE_ON
        #pragma shader_feature _WETNESS_ON
        #pragma shader_feature _WETMASKSOURCE_VERTEXCOLORALPHA
        #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
        
        #pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_fwdbase
        #pragma multi_compile_fog
        #pragma multi_compile_instancing
        //#pragma instancing_options assumeuniformscaling lodfade maxcount:50
        //#pragma multi_compile __ VTRANSPARENCY_ON
            
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_FORWARDBASE
        
        #include "Assets/Alloy/Shaders/Definition/SpeedTree.cginc"
        #include "Assets/Alloy/Shaders/Forward/Base.cginc"

        ENDCG
    }
    
    Pass {
        Name "FORWARD_DELTA"
        Tags { "LightMode" = "ForwardAdd" }
        
        Blend One One
        ZWrite Off
        Cull [_Cull]

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles
        
        #pragma shader_feature GEOM_TYPE_BRANCH GEOM_TYPE_BRANCH_DETAIL GEOM_TYPE_FROND GEOM_TYPE_LEAF GEOM_TYPE_MESH
        #pragma shader_feature EFFECT_BUMP
        #pragma shader_feature EFFECT_HUE_VARIATION
        #pragma shader_feature _PARALLAXMAP
        #pragma shader_feature _BUMPMODE_POM
        #pragma shader_feature _TEAMCOLOR_ON
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _DISSOLVE_ON
        #pragma shader_feature _WETNESS_ON
        #pragma shader_feature _WETMASKSOURCE_VERTEXCOLORALPHA
        #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
        
        #pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_fwdadd_fullshadows
        #pragma multi_compile_fog
        //#pragma multi_compile __ VTRANSPARENCY_ON
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader

        #define UNITY_PASS_FORWARDADD

        #include "Assets/Alloy/Shaders/Definition/SpeedTree.cginc"
        #include "Assets/Alloy/Shaders/Forward/Add.cginc"

        ENDCG
    }
    
    Pass {
        Name "SHADOWCASTER"
        Tags { "LightMode" = "ShadowCaster" }
        
        Cull [_Cull]

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers gles

        #pragma shader_feature GEOM_TYPE_BRANCH GEOM_TYPE_BRANCH_DETAIL GEOM_TYPE_FROND GEOM_TYPE_LEAF GEOM_TYPE_MESH
        #pragma shader_feature _DISSOLVE_ON
        
        #pragma multi_compile_shadowcaster
        #pragma multi_compile_instancing
        //#pragma instancing_options assumeuniformscaling lodfade maxcount:50

        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_SHADOWCASTER
        
        #include "Assets/Alloy/Shaders/Definition/SpeedTree.cginc"
        #include "Assets/Alloy/Shaders/Forward/Shadow.cginc"

        ENDCG
    }
    
    Pass {
        Name "Meta"
        Tags { "LightMode" = "Meta" }

        Cull Off

        CGPROGRAM
        #pragma target 3.0
        #pragma exclude_renderers nomrt gles
        
        #pragma shader_feature GEOM_TYPE_BRANCH GEOM_TYPE_BRANCH_DETAIL GEOM_TYPE_FROND GEOM_TYPE_LEAF GEOM_TYPE_MESH
        #pragma shader_feature _TEAMCOLOR_ON
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _EMISSION

        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_META
        
        #include "Assets/Alloy/Shaders/Definition/SpeedTree.cginc"
        #include "Assets/Alloy/Shaders/Forward/Meta.cginc"

        ENDCG
    }
}

FallBack "VertexLit"
CustomEditor "AlloyFieldBasedEditor"
}
