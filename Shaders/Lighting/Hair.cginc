// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Hair.cginc
/// @brief Hair lighting model. Forward-only.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_LIGHTING_HAIR_CGINC
#define ALLOY_SHADERS_LIGHTING_HAIR_CGINC

#ifndef A_AREA_SPECULAR_OFF
    #define A_AREA_SPECULAR_OFF
#endif

#define A_SURFACE_CUSTOM_FIELDS \
    half3 highlightTint0; \
    half highlightShift0; \
    half3 highlightTint1; \
    half highlightShift1; \
    half3 highlightTangent; \
    half3 highlightTangentWorld; \
    half3 specularColor0; \
    half roughness0; \
    half3 specularColor1; \
    half roughness1;

#include "Assets/Alloy/Shaders/Framework/Lighting.cginc"

/// Amount that diffuse lighting should wrap around.
/// Expects values in the range [0,1].
half _HairDiffuseWrapAmount;

/// Overall hair specularity.
/// Expects values in the range [0,1].
half _HairSpecularity;

/// Rotation of the hair highlight
/// Expects rotation values in degrees.
half _AnisoAngle;

/// Primary highlight tint color.
/// Expects a linear LDR color.
half3 _HighlightTint0;

/// Primary highlight position shift along normal.
/// Expects values in the range [-n,n].
half _HighlightShift0;

/// Primary highlight width.
/// Expects values in the range [0,1].
half _HighlightWidth0;

/// Secondary highlight tint color.
/// Expects a linear LDR color.
half3 _HighlightTint1;

/// Secondary highlight position shift along normal.
/// Expects values in the range [-n,n].
half _HighlightShift1;

/// Secondary highlight width.
/// Expects values in the range [0,1].
half _HighlightWidth1;

/// Kajiya-Kay anisotropic specular.
/// @param  d           Direct lighting data.
/// @param  s           Material surface data.
/// @param  f0          Fresnel reflectance at incidence zero, LDR color.
/// @param  roughness   Linear roughness [0,1].
/// @param  shift       Amount to shift the highlight along the normal [0,1].
/// @return             Kajiya-Kay specular.
half3 aKajiyaKay(
    ADirect d,
    ASurface s,
    half3 f0,
    half roughness,
    half shift)
{
    // Convert Beckmann roughness to Blinn Phong specular power.
    // cf http://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
    half a = aLinearToBeckmannRoughness(roughness);
    half sp = (2.0h / (a * a)) - 2.0h;
    
    // Modified Kajiya-kay.
    // cf http://developer.amd.com/wordpress/media/2012/10/Scheuermann_HairRendering.pdf
    half tdhm = dot(normalize(s.highlightTangentWorld + s.normalWorld * shift), d.halfAngleWorld);
    
    // HACK: Treat like Normalized Blinn Phong NDF, with 1/4 precombined.
    // Semi-physical, and looks more consistent with the IBL.
    half spec = (sp * 0.125h + 0.25h) * pow(sqrt(1.0h - tdhm * tdhm), sp);
    
    /// Only use spec color since fresnel makes wide highlights white at edges.
    return f0 * spec;
}

void aPreLighting(
    inout ASurface s)
{
    aStandardPreLighting(s);

    // Tangent
    s.highlightTangentWorld = aTangentToWorld(s, s.highlightTangent);
    
    // Hair data.	
    s.specularColor0 = s.f0 * s.highlightTint0;
    s.roughness0 = lerp(s.roughness, 1.0h, _HighlightWidth0);
    
    s.specularColor1 = s.f0 * _HighlightTint1;
    s.roughness1 = lerp(s.roughness, 1.0h, _HighlightWidth1);
    
    // Average values from the two highlights for IBL.
    s.f0 = (s.specularColor0 + s.specularColor1) * 0.5h;
    s.roughness = (s.roughness0 + s.roughness1) * 0.5h;
}

half3 aDirectLighting( 
    ADirect d,
    ASurface s)
{
    half3 specular = 0.0h;

    // Energy-conserving wrap lighting.
    // cf http://seblagarde.wordpress.com/2012/01/08/pi-or-not-to-pi-in-game-lighting-equation/
    half denom = (1.0h + _HairDiffuseWrapAmount);
    half3 diffuse = s.albedo * saturate((d.NdotLm + _HairDiffuseWrapAmount) / (denom * denom));
    
#ifndef _SPECULARHIGHLIGHTS_OFF
    // Scheuermann hair lighting
    // Anisotropy and area light approximation don't play well together, so recalculate H.
    // cf http://www.shaderwrangler.com/publications/hairsketch/hairsketch.pdf
    half3 d0 = aKajiyaKay(d, s, s.specularColor0, s.roughness0, s.highlightShift0);
    half3 d1 = aKajiyaKay(d, s, s.specularColor1, s.roughness1, s.highlightShift1);

    specular = aSpecularLightingToggle(s, (s.specularOcclusion * d.specularIntensity * d.NdotL) * max(d0, d1));
#endif
    
    // max() for energy conservation where the specular highlights overlap.
    return d.color * d.shadow * (diffuse + specular);
}

half3 aIndirectLighting(
    AIndirect i,
    ASurface s)
{
    // Yoshiharu Gotanda's fake interreflection for specular occlusion.
    // Modified to better account for surface f0.
    // cf http://research.tri-ace.com/Data/cedec2011_RealtimePBR_Implementation_e.pptx pg65
    half3 ambient = i.diffuse * s.ambientOcclusion;
    
    // No environment BRDF, as it makes the hair look greasy.
    return s.albedo * ambient
             + aSpecularLightingToggle(s, s.f0 * lerp(ambient, i.specular, s.specularOcclusion));
}

#endif // ALLOY_SHADERS_LIGHTING_HAIR_CGINC
