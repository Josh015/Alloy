// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Unlit.cginc
/// @brief Unlit lighting model. Forward+Deferred.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_LIGHTING_UNLIT_CGINC
#define ALLOY_SHADERS_LIGHTING_UNLIT_CGINC

#define A_UNLIT_MODE

#include "Assets/Alloy/Shaders/Framework/Lighting.cginc"

void aPreLighting(
    inout ASurface s)
{
    // Preserve normals and emission. Kill everything else.
    s.albedo = A_BLACK;
    s.specularOcclusion = 0.0h;
    s.f0 = A_BLACK;
    s.roughness = 1.0h;
    s.materialType = A_MATERIAL_TYPE_OPAQUE;
    s.subsurface = 0.0h;
}

half3 aDirectLighting( 
    ADirect d,
    ASurface s)
{
    return A_BLACK;
}

half3 aIndirectLighting(
    AIndirect i,
    ASurface s)
{
    return A_BLACK;
}

#endif // ALLOY_SHADERS_LIGHTING_UNLIT_CGINC
