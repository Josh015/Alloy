// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

Shader "Alloy Mods/Weathered Blend" {
Properties {
    // Global Settings
    _Mode ("'Rendering Mode' {RenderingMode:{Opaque:{_Cutoff}, Cutout:{}, Fade:{_Cutoff}, Transparent:{_Cutoff}}}", Float) = 0
    _SrcBlend ("__src", Float) = 0
    _DstBlend ("__dst", Float) = 0
    _ZWrite ("__zw", Float) = 1
    [LM_TransparencyCutOff] 
    _Cutoff ("'Opacity Cutoff' {Min:0, Max:1}", Float) = 0.5
    [Toggle(EFFECT_BUMP)]
    _HasBumpMap ("'Normals Source' {Dropdown:{VertexNormals:{_Layered2MatBumpMap,_Layered2MatBumpScale,_BumpMap,_BumpScale,_DetailNormalMap,_DetailNormalMapScale,_WetNormalMap,_WetNormalMapScale,_BumpMap2,_BumpScale2}, NormalMaps:{}}}", Float) = 1
    [Toggle(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)]
    _MainRoughnessSource ("'Roughness Source' {Dropdown:{PackedMapAlpha:{}, BaseColorAlpha:{_SpecTex,_Occlusion,_MaterialMap2,_Occlusion2}}}", Float) = 0
    
    // Weathered Blend Textures
    _Layered2MatTextures ("'Weathered Blend Textures' {Section:-1}", Float) = 0
    _Layered2MatPackedMap ("'Det(R) AO(G) Curv(B) Mask(A)' {Visualize:{R,G,B,A}}", 2D) = "white" {} 
    _Layered2MatPackedMapUV ("UV Set", Float) = 0
    _Layered2MatBumpMap ("'Normals' {Visualize:{NRM}, Parent:_Layered2MatPackedMap}", 2D) = "bump" {} 
    _Layered2MatPackedFxMap ("'E Mask(R) Map(G) R Mask(B) Map(A)' {Visualize:{R,G,B,A}, Parent:_Layered2MatPackedMap}", 2D) = "white" {}

    // Weathered Blend
    _Layered2MatProperties ("'Weathered Blend' {Section:-1}", Float) = 0
    _Layered2MatOxidation ("'Oxidation' {Min:0, Max:1}", Float) = 1
    _Layered2MatDustTint ("'Dust Tint' {}", Color) = (1,1,1)
    _Layered2MatDustiness ("'Dustiness' {Min:0, Max:1}", Float) = 1
    _Layered2MatRougherness ("'Rougherness' {Min:0, Max:1}", Float) = 1
    _Layered2MatOcclusion ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
    _Layered2MatBumpScale ("'Normal Strength' {}", Float) = 1
    
    // Packed FX Emission Properties
    [Toggle(_EMISSION)] 
    _Emission ("'Packed FX Emission' {Feature:{Color:10}}", Float) = 0
    [LM_Emission] 
    [HDR]
    _EmissionColor ("'Tint' {}", Color) = (1,1,1)
    _IncandescenceMap_ST ("'Texcoords' {Vector:TexCoord}", Vector) = (1,1,0,0) 
    _IncandescenceMapVelocity ("Scroll", Vector) = (0,0,0,0) 
    _IncandescenceMapUV ("UV Set", Float) = 0
    [Gamma]
    _EmissionWeight ("'Weight' {Min:0, Max:1}", Float) = 1
    
    // Packed FX Rim Properties
    [Toggle(_RIM_ON)] 
    _Rim ("'Packed FX Rim' {Feature:{Color:11}}", Float) = 0
    [HDR]
    _RimColor ("'Tint' {}", Color) = (1,1,1)
    _RimTex_ST ("'Texcoords' {Vector:TexCoord}", Vector) = (1,1,0,0) 
    _RimTexVelocity ("Scroll", Vector) = (0,0,0,0) 
    _RimTexUV ("UV Set", Float) = 0
    [Gamma]
    _RimWeight ("'Weight' {Min:0, Max:1}", Float) = 1
    [Gamma]
    _RimBias ("'Fill' {Min:0, Max:1}", Float) = 0
    _RimPower ("'Falloff' {Min:0.01}", Float) = 4
    
    // Parallax
    [Toggle(_PARALLAXMAP)]
    _ParallaxT ("'Parallax' {Feature:{Color:5}}", Float) = 0
    [Toggle(_BUMPMODE_POM)]
    _BumpMode ("'Mode' {Dropdown:{Parallax:{_MinSamples, _MaxSamples}, POM:{}}}", Float) = 0
    _ParallaxMap ("'Heightmap(G)' {Visualize:{RGB}, Parent:_MainTex}", 2D) = "black" {}
    _Parallax ("'Height' {Min:0, Max:0.08}", Float) = 0.02
    _MinSamples ("'Min Samples' {Min:1}", Float) = 4
    _MaxSamples ("'Max Samples' {Min:1}", Float) = 20
    
    // Detail
    [Toggle(_DETAIL_MULX2)] 
    _DetailT ("'Detail' {Feature:{Color:7}}", Float) = 0
    _DetailAlbedoMap ("'Color(RGB)' {Visualize:{RGB}}", 2D) = "white" {}
    _DetailAlbedoMapVelocity ("Scroll", Vector) = (0,0,0,0) 
    _DetailAlbedoMapUV ("UV Set", Float) = 0
    _DetailNormalMap ("'Normals' {Visualize:{NRM}, Parent:_DetailAlbedoMap}", 2D) = "bump" {}
    _DetailWeight ("'Weight' {Min:0, Max:1}", Float) = 1
    _DetailNormalMapScale ("'Normal Strength' {}", Float) = 1
        
    // Decal
    [Toggle(_DECAL_ON)] 
    _Decal ("'Decal' {Feature:{Color:9}}", Float) = 0	
    [Enum(All, 0, Mat1, 1, Mat2, 2)] 
    _DecalMode ("'Mode' {Dropdown:{All:{}, Mat1:{}, Mat2:{}}}", Float) = 0
    _DecalColor ("'Tint' {}", Color) = (1,1,1,1)
    _DecalTex ("'Base Color(RGB) Opacity(A)' {Visualize:{RGB, A}}", 2D) = "black" {} 
    _DecalTexUV ("UV Set", Float) = 0
    _DecalWeight ("'Weight' {Min:0, Max:1}", Float) = 1
    _DecalSpecularity ("'Specularity' {Min:0, Max:1}", Float) = 0.5
    _DecalAlphaVertexTint ("'Vertex Alpha Tint' {Min:0, Max:1}", Float) = 0
    
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
    
    // Secondary Textures 
    _SecondaryTextures ("'Secondary Textures' {Section:{Color:15}}", Float) = 0
    _Color2 ("'Tint' {}", Color) = (1,1,1,1)	
    _MainTex2 ("'Base Color(RGB) Opacity(A)' {Visualize:{RGB, A}}", 2D) = "white" {}
    _MainTex2Velocity ("Scroll", Vector) = (0,0,0,0) 
    _MainTex2UV ("UV Set", Float) = 0
    _MaterialMap2 ("'Metal(R) AO(G) Spec(B) Rough(A)' {Visualize:{R, G, B, A}, Parent:_MainTex2}", 2D) = "white" {}
    _BumpMap2 ("'Normals' {Visualize:{NRM}, Parent:_MainTex2}", 2D) = "bump" {}
    _BaseColorVertexTint2 ("'Vertex Color Tint' {Min:0, Max:1}", Float) = 0
    
    // Secondary Properties 
    _SecondaryPhysicalProperties ("'Secondary Properties' {Section:{Color:16}}", Float) = 0
    _Metallic2 ("'Metallic' {Min:0, Max:1}", Float) = 1
    _Specularity2 ("'Specularity' {Min:0, Max:1}", Float) = 1
    _SpecularTint2 ("'Specular Tint' {Min:0, Max:1}", Float) = 0
    _Roughness2 ("'Roughness' {Min:0, Max:1}", Float) = 1
    _Occlusion2 ("'Occlusion Strength' {Min:0, Max:1}", Float) = 1
    _BumpScale2 ("'Normal Strength' {}", Float) = 1

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
        #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        #pragma shader_feature _PARALLAXMAP
        #pragma shader_feature _BUMPMODE_POM
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _EMISSION
        #pragma shader_feature _RIM_ON
        #pragma shader_feature _WETNESS_ON
        #pragma shader_feature _WETMASKSOURCE_VERTEXCOLORALPHA
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
        
        #include "Assets/Alloy/Mods/Shaders/Definition/WeatheredBlend.cginc"
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
        #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        #pragma shader_feature _PARALLAXMAP
        #pragma shader_feature _BUMPMODE_POM
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _WETNESS_ON
        #pragma shader_feature _WETMASKSOURCE_VERTEXCOLORALPHA
        #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
        
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_fwdadd_fullshadows
        #pragma multi_compile_fog
        //#pragma multi_compile __ VTRANSPARENCY_ON
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader

        #define UNITY_PASS_FORWARDADD

        #include "Assets/Alloy/Mods/Shaders/Definition/WeatheredBlend.cginc"
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
        #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        #pragma shader_feature _DISSOLVE_ON
        
        #pragma multi_compile_shadowcaster
        #pragma multi_compile_instancing

        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_SHADOWCASTER
        
        #include "Assets/Alloy/Mods/Shaders/Definition/WeatheredBlend.cginc"
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
        #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        #pragma shader_feature _PARALLAXMAP
        #pragma shader_feature _BUMPMODE_POM
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _EMISSION
        #pragma shader_feature _RIM_ON
        #pragma shader_feature _WETNESS_ON
        #pragma shader_feature _WETMASKSOURCE_VERTEXCOLORALPHA
        #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
        
        //#pragma multi_compile __ LOD_FADE_PERCENTAGE LOD_FADE_CROSSFADE
        #pragma multi_compile_prepassfinal
        #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
        #pragma multi_compile_instancing
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_DEFERRED
        
        #include "Assets/Alloy/Mods/Shaders/Definition/WeatheredBlend.cginc"
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
        
        #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        #pragma shader_feature _DETAIL_MULX2
        #pragma shader_feature _DECAL_ON
        #pragma shader_feature _EMISSION
        
        #pragma vertex aMainVertexShader
        #pragma fragment aMainFragmentShader
        
        #define UNITY_PASS_META
        
        #include "Assets/Alloy/Mods/Shaders/Definition/WeatheredBlend.cginc"
        #include "Assets/Alloy/Shaders/Forward/Meta.cginc"

        ENDCG
    }
}

FallBack "VertexLit"
CustomEditor "AlloyFieldBasedEditor"
}
