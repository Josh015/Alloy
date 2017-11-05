// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

/////////////////////////////////////////////////////////////////////////////////
/// @file Config.cginc
/// @brief User configuration options.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_SHADERS_CONFIG_CGINC
#define ALLOY_SHADERS_CONFIG_CGINC

/// Enables deferred shading material type branching to reduce costs.
#define A_USE_DEFERRED_MATERIAL_TYPE_BRANCHING 1

/// Enables clamping of all shader outputs to prevent blending and bloom errors.
#define A_USE_HDR_CLAMP 1

/// Max HDR intensity for lighting and emission.
#define A_HDR_CLAMP_MAX_INTENSITY 100.0

/// Enables capping tessellation quality via the global _MinEdgeLength property.
#define A_USE_TESSELLATION_MIN_EDGE_LENGTH 0

/// Enables tube area lights. Can be disabled to improve sphere light performance.
#define A_USE_TUBE_LIGHTS 1

/// Enables the Unity behavior for light cookies.
#define A_USE_UNITY_LIGHT_COOKIES 0

/// Enables the Unity behavior for attenuation.
#define A_USE_UNITY_ATTENUATION 0

/// Enables feature where black specularity/f0 kills specular lighting per-pixel.
#define A_USE_BLACK_SPECULAR_COLOR_TOGGLE 0

/// Packed map metallic channel.
#define A_METALLIC_CHANNEL r

/// Packed map ao channel.
#define A_AO_CHANNEL g

/// Packed map spcularity channel.
#define A_SPECULARITY_CHANNEL b

/// Packed map roughness channel.
#define A_ROUGHNESS_CHANNEL a


// ----Hx Volumetric Lighting----
//#include "Assets/Plugins/HxVolumetricLighting/BuiltIn-Replacement/HxVolumetricCore.cginc"

// ----Vapor----
//#include "Assets/Vapor/Shaders/VaporFramework.cginc"

// ----VertExmotion----
//#define A_USE_VERTEX_MOTION
//#include "Assets/VertExmotion/Shaders/VertExmotion.cginc"

// ----Amplify Texture----
//#include "Assets/AmplifyTexture/Shaders/Shared.cginc"

#endif // ALLOY_SHADERS_CONFIG_CGINC
