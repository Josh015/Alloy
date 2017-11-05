// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

///////////////////////////////////////////////////////////////////////////////
/// @file Volumetric.cginc
/// @brief Volumetric fog, light shafts, etc interfaces.
///////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_FRAMEWORK_VOLUMETRIC_CGINC
#define ALLOY_SHADERS_FRAMEWORK_VOLUMETRIC_CGINC

/// Volumetric effects for base passes.
void aVolumetricBase(inout half4 color, ASurface s);

/// Volumetric effects for additive passes.
void aVolumetricAdd(inout half4 color, ASurface s);

/// Volumetric effects for multiplicative passes.
void aVolumetricMultiply(inout half4 color, ASurface s);

#endif // ALLOY_SHADERS_FRAMEWORK_VOLUMETRIC_CGINC
