// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy/Tessellation/Transmission/OneSided (Forward)" {
Properties {
    // Global Settings
    _Mode ("'Rendering Mode' {RenderingMode:{Opaque:{_Cutoff}, Cutout:{}, Fade:{_Cutoff}, Transparent:{_Cutoff}}}", Float) = 0
    _SrcBlend ("__src", Float) = 0
    _DstBlend ("__dst", Float) = 0
    _ZWrite ("__zw", Float) = 1
    [LM_TransparencyCutOff] 
    _Cutoff ("'Opacity Cutoff' {Min:0, Max:1}", Float) = 0.5
    [Toggle(EFFECT_BUMP)]
    _HasBumpMap ("'Normals Source' {Dropdown:{VertexNormals:{_BumpMap,_BumpScale,_DetailNormalMap,_DetailNormalMapScale,_WetNormalMap,_WetNormalMapScale}, NormalMaps:{}}}", Float) = 1
    [Toggle(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)]
    _MainRoughnessSource ("'Roughness Source' {Dropdown:{PackedMapAlpha:{}, BaseColorAlpha:{_SpecTex,_Occlusion}}}", Float) = 0
    [Enum(Front, 1, Back, 2)] 
    _ShadowCullMode ("'Shadow Cull Mode' {Dropdown:{Off:{}, Front:{}, Back:{}}}", Float) = 2
    
    // Main Textures
    _MainTextures ("'Main Textures' {Section:{Color:0}}", Float) = 0
    [LM_Albedo] [LM_Transparency] 
    _Color ("'Tint' {}", Color) = (1,1,1,1)	
    [LM_MasterTilingOffset] [LM_Albedo] 
    _MainTex ("'Base Color(RGB) Opacity(A)' {Visualize:{RGB, A}}", 2D) = "white" {}
    _MainTexVelocity ("Scroll", Vector) = (0,0,0,0) 
    _MainTexUV ("UV Set", Float) = 0
    [LM_Metallic]
    _SpecTex ("'Metal(R) AO(G) Spec(B) Rough(A)' {Visualize:{R, G, B, A}, Parent:_MainTex}", 2D) = "white" {}
    [LM_NormalMap]
    _BumpMap ("'Normals' {Visualize:{NRM}, Parent:_MainTex}", 2D) = "bump" {}
    _BaseColorVertexTint ("'Vertex Color Tint' {Min:0, Max:1}", Float) = 0
     
    // Main Properties
    _MainPhysicalProperties ("'Main Properties' {Section:{Color:1}}", Float) = 0
    [LM_Metallic]
    _Metal ("'Metallic' {Min:0, Max:1}", Float) = 1
    _Specularity ("'Specularity' {Min:0, Max:1}", Float) = 1
    _SpecularTint ("'Specular Tint' {Min:0, Max:1}", Float) = 0
    _Roughness ("'Roughness' {Min:0, Max:1}", Float) = 1
    _Occlusion ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
    _BumpScale ("'Normal Strength' {}", Float) = 1
        
    // Transmission
    _TransmissionProperties ("'Transmission' {Section:{Color:3}}", Float) = 0
    _TransColor ("'Tint' {}", Color) = (1,1,1)
    _TransTex ("'Transmission(RGB)' {Visualize:{RGB}, Parent:_MainTex}", 2D) = "white" {}
    [Gamma]
    _TransScale ("'Weight' {Min:0, Max:1}", Float) = 1
    _TransDistortion ("'Bump Distortion' {Min:0, Max:1}", Float) = 0.05
    _TransPower ("'Falloff' {Min:1}", Float) = 1
    
    // Tessellation
    _TessellationProperties ("'Tessellation' {Section:{Color:5}}", Float) = 0
    [KeywordEnum(Displacement, Phong)] 
    _TessellationMode ("'Mode' {Dropdown:{Displacement:{_Phong}, Phong:{_DispTex, _Displacement}}}", Float) = 0
    _DispTex ("'Heightmap(G)' {Visualize:{RGB}}", 2D) = "black" {}
    _DispTexVelocity ("Scroll", Vector) = (0,0,0,0)
    _Displacement ("'Displacement' {Min:0, Max:30}", Float) = 0.3	
    _Phong ("'Phong Strength' {Min:0, Max:1}", Float) = 0.5
    _EdgeLength ("'Edge Length' {Min:2, Max:50}", Float) = 15
    
    // AO2
    [Toggle(_AO2_ON)] 
    _AO2 ("'AO2' {Feature:{Color:6}}", Float) = 0
    _Ao2Map ("'AO2(G)' {Visualize:{RGB}}", 2D) = "white" {} 
    _Ao2MapUV ("UV Set", Float) = 1
    _Ao2Occlusion ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
    
    // Detail
    [Toggle(_DETAIL_MULX2)] 
    _DetailT ("'Detail' {Feature:{Color:7}}", Float) = 0
    [Toggle(_NORMALMAP)]
    _DetailMaskSource ("'Mask Source' {Dropdown:{TextureAlpha:{}, VertexColorAlpha:{_DetailMask}}}", Float) = 0
    _DetailMask ("'Mask(A)' {Visualize:{A}, Parent:_MainTex}", 2D) = "white" {}
    _DetailMaskStrength ("'Mask Strength' {Min:0, Max:1}", Float) = 1
    [Enum(Mul, 0, MulX2, 1)] 
    _DetailMode ("'Color Mode' {Dropdown:{Mul:{}, MulX2:{}}}", Float) = 0
    _DetailAlbedoMap ("'Color(RGB)' {Visualize:{RGB}}", 2D) = "white" {}
    _DetailAlbedoMapVelocity ("Scroll", Vector) = (0,0,0,0) 
    _DetailAlbedoMapUV ("UV Set", Float) = 0
    _DetailNormalMap ("'Normals' {Visualize:{NRM}, Parent:_DetailAlbedoMap}", 2D) = "bump" {}
    _DetailWeight ("'Weight' {Min:0, Max:1}", Float) = 1
    _DetailNormalMapScale ("'Normal Strength' {}", Float) = 1
    
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
    #define A_TESSELLATION_SHADER
ENDCG

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
        //#pragma target 4.6
        #pragma exclude_renderers gles
        
        #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
        #pragma shader_feature EFFECT_BUMP
        #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        #pragma shader_feature _TESSELLATIONMODE_DISPLACEMENT _TESSELLATIONMODE_PHONG
        #pragma shader_feature _AO2_ON
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _NORMALMAP
        #pragma shader_feature _TEAMCOLOR_ON
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _EMISSION
        #pragma shader_feature _RIM_ON
        #pragma shader_feature _DISSOLVE_ON
        #pragma shader_feature _WETNESS_ON
        #pragma shader_feature _WETMASKSOURCE_VERTEXCOLORALPHA
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
        
        #include "Assets/Alloy/Shaders/Definition/Transmission.cginc"
        #include "Assets/Alloy/Shaders/Forward/Base.cginc"

        ENDCG
    }
    
    Pass {
        Name "FORWARD_DELTA"
        Tags { "LightMode" = "ForwardAdd" }
        
        Blend [_SrcBlend] One
        ZWrite Off

        CGPROGRAM
        //#pragma target 4.6
        #pragma exclude_renderers gles
        
        #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
        #pragma shader_feature EFFECT_BUMP
        #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        #pragma shader_feature _TESSELLATIONMODE_DISPLACEMENT _TESSELLATIONMODE_PHONG
        #pragma shader_feature _AO2_ON
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _NORMALMAP
        #pragma shader_feature _TEAMCOLOR_ON
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _DISSOLVE_ON
        #pragma shader_feature _WETNESS_ON
        #pragma shader_feature _WETMASKSOURCE_VERTEXCOLORALPHA
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

        #include "Assets/Alloy/Shaders/Definition/Transmission.cginc"
        #include "Assets/Alloy/Shaders/Forward/Add.cginc"

        ENDCG
    }
    
    Pass {
        Name "SHADOWCASTER"
        Tags { "LightMode" = "ShadowCaster" }
        
        Cull [_ShadowCullMode]
        
        CGPROGRAM
        //#pragma target 4.6
        #pragma exclude_renderers gles
        
        #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
        #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        #pragma shader_feature _TESSELLATIONMODE_DISPLACEMENT _TESSELLATIONMODE_PHONG
        #pragma shader_feature _DISSOLVE_ON
        
        #pragma multi_compile_shadowcaster
        #pragma multi_compile_instancing

        #pragma hull aMainHullShader
        #pragma vertex aMainTessellationVertexShader
        #pragma domain aMainDomainShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_SHADOWCASTER
        
        #include "Assets/Alloy/Shaders/Definition/Transmission.cginc"
        #include "Assets/Alloy/Shaders/Forward/Shadow.cginc"

        ENDCG
    }
    
    Pass {
        Name "Meta"
        Tags { "LightMode" = "Meta" }

        Cull Off

        CGPROGRAM
        //#pragma target 4.6
        #pragma exclude_renderers nomrt gles
        
        #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _NORMALMAP
        #pragma shader_feature _TEAMCOLOR_ON
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _EMISSION
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_META
        
        #include "Assets/Alloy/Shaders/Definition/Transmission.cginc"
        #include "Assets/Alloy/Shaders/Forward/Meta.cginc"

        ENDCG
    }
}

FallBack "Alloy/Transmission/OneSided (Forward)"
CustomEditor "AlloyFieldBasedEditor"
}
