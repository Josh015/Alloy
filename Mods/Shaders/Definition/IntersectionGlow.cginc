// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file IntersectionGlow.cginc
/// @brief IntersectionGlow shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_MODS_SHADERS_DEFINITION_INTERSECTION_GLOW_CGINC
#define ALLOY_MODS_SHADERS_DEFINITION_INTERSECTION_GLOW_CGINC

#define _ALPHAPREMULTIPLY_ON
#define A_VIEW_DEPTH_ON
#define A_SCREEN_UV_ON
#define A_AMBIENT_OCCLUSION_ON
#define A_EMISSIVE_COLOR_ON
#define A_MAIN_TEXTURES_ON

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

sampler2D_float _CameraDepthTexture;

half3 _ScanLineColor;
half _ScanLineWeight;
half _ScanLineWidth;

void aSurfaceShader(
    inout ASurface s)
{
#ifdef _INTERSECTION_GLOW_BACKFACE
    s.baseColor = 0.0h;
    s.opacity = 0.0h;
    s.ambientOcclusion = 0.0h;
#else
    aMainTextures(s);
    aRim(s);
    aEmission(s);
#endif

    float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, s.screenUv));
    float fade = saturate(sceneZ - s.viewDepth);
    half scan = step(1.0h - _ScanLineWidth, 1.0h - fade);

    s.emissiveColor = lerp(s.emissiveColor, _ScanLineColor * _ScanLineWeight, scan);
}

#endif // ALLOY_MODS_SHADERS_DEFINITION_INTERSECTION_GLOW_CGINC
