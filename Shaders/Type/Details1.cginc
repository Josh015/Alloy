// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Details1.cginc
/// @brief Unity Details1 shader type callbacks.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_TYPE_DETAILS1_CGINC
#define ALLOY_SHADERS_TYPE_DETAILS1_CGINC

#ifndef A_TEX_UV_OFF
    #define A_TEX_UV_OFF
#endif

#ifndef A_TEX_SCROLL_OFF
    #define A_TEX_SCROLL_OFF
#endif

#ifndef A_OPACITY_MASK_ON
    #define A_OPACITY_MASK_ON
#endif

#include "Assets/Alloy/Shaders/Framework/Type.cginc"

#include "TerrainEngine.cginc"

void aVertexShader(
    inout AVertex v)
{
    aStandardVertexShader(v);

    // Adapt vertex data so we can reuse wind code.
    appdata_full IN;

    UNITY_INITIALIZE_OUTPUT(appdata_full, IN);
    IN.vertex = v.positionObject;
    IN.color = v.color;

    WavingGrassVert(IN);
    v.positionObject = IN.vertex;
    v.color = IN.color;
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

}

#endif // ALLOY_SHADERS_TYPE_DETAILS1_CGINC
