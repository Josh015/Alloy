// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file WeatheredBlend.cginc
/// @brief Weathered Blend shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_MODS_SHADERS_DEFINITION_WEATHERED_BLEND_CGINC
#define ALLOY_MODS_SHADERS_DEFINITION_WEATHERED_BLEND_CGINC

#define A_METALLIC_ON
#define A_AMBIENT_OCCLUSION_ON
#define A_MAIN_TEXTURES_ON
#define A_MAIN_TEXTURES_CUTOUT_OFF
#define A_EMISSION_MASK_MAP_OFF
#define A_EMISSION_EFFECTS_MAP_OFF
#define A_RIM_EFFECTS_MAP_OFF
#define A_SECONDARY_TEXTURES_ON

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

A_SAMPLER_2D(_Layered2MatPackedMap);
sampler2D _Layered2MatBumpMap;
sampler2D _Layered2MatPackedFxMap;
half _Layered2MatOxidation;
half3 _Layered2MatDustTint;
half _Layered2MatDustiness;
half _Layered2MatRougherness;
half _Layered2MatOcclusion;
half _Layered2MatBumpScale;
    
float _DecalMode;
    
void aSurfaceShader(
    inout ASurface s)
{
    s.baseUv = A_BV(s, A_TEX_TRANSFORM_UV(s, _Layered2MatPackedMap));
    s.baseTiling = _Layered2MatPackedMap_ST.xy;
    aParallax(s);
    
    half4 packedMap = tex2D(_Layered2MatPackedMap, s.baseUv);
    half3 normals = UnpackScaleNormal(tex2D(_Layered2MatBumpMap, s.baseUv), _Layered2MatBumpScale);
    half4 packedFx = tex2D(_Layered2MatPackedFxMap, s.baseUv);

    s.baseUv = A_BV(s, A_TEX_TRANSFORM_UV_SCROLL(s, _MainTex));
    aMainTextures(s);
    
    s.mask = 1.0h - packedMap.a;
    aSecondaryTextures(s);
    aCutout(s);
    
    s.normalTangent = A_NT(s, BlendNormals(s.normalTangent, normals));
    s.ambientOcclusion *= aOcclusionStrength(packedMap.g, _Layered2MatOcclusion);
    s.mask = packedMap.r;
    aDetail(s);

    s.mask = _DecalMode < 0.5f ? 1.0h : (_DecalMode < 1.5f ? packedMap.a : 1.0h - packedMap.a);
    aDecal(s);

    s.mask = 1.0h;
    aWetness(s);
        
    half curvature = packedMap.b;
    s.baseColor *= lerp(_Layered2MatDustTint, A_WHITE, curvature);
    s.specularity = lerp(s.specularity * (1.0h - _Layered2MatDustiness), s.specularity, curvature);
    s.metallic = lerp(s.metallic * (1.0h - _Layered2MatOxidation), s.metallic, curvature);
    s.roughness = lerp(lerp(s.roughness, 1.0h, _Layered2MatRougherness), s.roughness, curvature);
        
#ifdef A_EMISSION_ON
    float2 incandescenceUv = A_TEX_TRANSFORM_UV_SCROLL(s, _IncandescenceMap);
    s.mask = aGammaToLinear(packedFx.r * tex2D(_Layered2MatPackedFxMap, incandescenceUv).g);
    aEmission(s);
#endif
#ifdef A_RIM_ON
    float2 rimUv = A_TEX_TRANSFORM_UV_SCROLL(s, _RimTex);
    s.mask = aGammaToLinear(packedFx.b * tex2D(_Layered2MatPackedFxMap, rimUv).a);
    aRim(s);
#endif
}

#endif // ALLOY_MODS_SHADERS_DEFINITION_WEATHERED_BLEND_CGINC
