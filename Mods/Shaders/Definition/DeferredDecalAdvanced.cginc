/////////////////////////////////////////////////////////////////////////////////
/// @file DeferredDecal.cginc
/// @brief Deferred Decal surface shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_MODS_SHADERS_DEFINITION_DECAL_CGINC
#define ALLOY_MODS_SHADERS_DEFINITION_DECAL_CGINC

#define A_METALLIC_ON
#define A_AMBIENT_OCCLUSION_ON

#define A_SURFACE_CUSTOM_FIELDS \
    half decalMask2; 

#include "Assets/Alloy/Shaders/Framework/Type.cginc"
#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"

half3 _GlowColor;
half _RoughnessMin;
half _RoughnessMax;
half _AoAsCavity;

half _BaseColorWeight;
half _NormalsWeight;

void aVertexShader(
    inout AVertex v)
{
    aStandardVertexShader(v);
}

void aColorShader(
    inout half4 color,
    ASurface s)
{
    aStandardColorShader(color, s);
}

void aGbufferShader(
    inout AGbuffer gb,
    ASurface s)
{
#ifdef A_DECAL_ALPHA_FIRSTPASS_SHADER
    gb.diffuseOcclusion.a = s.decalMask2 * _BaseColorWeight; // Assumes blend mode excludes alpha.
    gb.specularSmoothness.a = s.opacity;
    gb.normalType.a = s.opacity * _NormalsWeight; // Assumes blend mode excludes alpha.
    gb.emissionSubsurface.a = s.decalMask2;
#else
    gb.diffuseOcclusion.a = aLerpOneTo(gb.diffuseOcclusion.a, s.opacity); // Decal SO will combine with surface SO.
    gb.specularSmoothness.a *= s.opacity;
#endif
}

void aSurfaceShader(
    inout ASurface s)
{
    s.baseUv = A_BV(s, A_TEX_TRANSFORM_UV_SCROLL(s, _SpecTex));
    s.baseTiling = _SpecTex_ST.xy;
    aParallax(s);
    
    s.baseColor = _Color.rgb * aBaseVertexColorTint(s);

    half4 material = aSampleMaterial(s);
    
    s.opacity = _Color.a * material.A_SPECULARITY_CHANNEL;
    s.emissiveColor = _GlowColor;
    s.decalMask2 = material.A_METALLIC_CHANNEL;
    
    s.metallic = _Metal;
    s.ambientOcclusion = aLerpOneTo(material.A_AO_CHANNEL, _Occlusion);
    s.specularity = _Specularity;
    s.roughness = lerp(_RoughnessMin, _RoughnessMax, material.A_ROUGHNESS_CHANNEL);

    s.baseColor *= aLerpOneTo(s.ambientOcclusion, _AoAsCavity);
    s.normalTangent = A_NT(s, aSampleBump(s));
}

#endif // ALLOY_MODS_SHADERS_DEFINITION_DECAL_CGINC
