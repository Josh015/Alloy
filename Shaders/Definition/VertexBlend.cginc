// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file VertexBlend.cginc
/// @brief Vertex Blend shader definition.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_DEFINITION_VERTEX_BLEND_CGINC
#define ALLOY_SHADERS_DEFINITION_VERTEX_BLEND_CGINC

#define A_VERTEX_BLEND_ON

#include "Assets/Alloy/Shaders/Lighting/Standard.cginc"
#include "Assets/Alloy/Shaders/Type/Standard.cginc"

void aSurfaceShader(
    inout ASurface s)
{
    aVertexBlend(s);
    aDetail(s);
    aAo2(s);
    aDecal(s);
    aWetness(s);
}

#endif // ALLOY_SHADERS_DEFINITION_VERTEX_BLEND_CGINC
