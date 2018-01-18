# Changelog

## 4.3.0
### Shaders
* Added Unity 2017.3 support.
* Moved "Legacy" and "Mods" into the "Alloy" folder as part of the transition to open-source.

### Integration
* Updated Substance Designer preview shader to version 2017.2.
* Updated Substance Painter preview shader to version 2017.3.

## 4.2.0
### Shaders
* Added Unity 2017.2 support.

## 4.1.1
### Shaders
* Changed "Eye" shaders to add Roughness Source, Cornea Metallic, and Sclera Metallic properties.
   + "Property" option which applies just the roughness sliders without the roughness map.
   + You may need to manually disable the material map property in your materials.
* Changed "Car Paint" shaders to add a secondary color map mode.
* Changed "Car Paint" shaders to add a Roughness Source dropdown.
   + "Property" option which applies just the roughness slider without the roughness map.
* Fixed visualize not applying parent texture transforms to children.
* Fixed "Directional Blend" shaders to stop popping issue between edit and play mode.
   + World is now the default mapping mode.
   + You must run the Material Migrator tool exactly once to fix existing materials. 
* Fixed "TriPlanar" shaders to stop popping issue between edit and play mode.
   + World is now the default mapping mode.
   + You must run the Material Migrator tool exactly once to fix existing materials. 
* Fixed "Vertex Blend" shaders to stop popping issue between edit and play mode.
   + World is now the default mapping mode.
   + You must run the Material Migrator tool exactly once to fix existing materials. 

### Mods
* Fixed "Deferred Decal Advanced" shader so that:
   + The shader actually compiles.
   + Base Color and Normals blend sliders work now.
   + Surface material type is no longer overwritten.
   + Surface shadow masks are no longer overwritten.
   + Decal specular occlusion now combines with the surface specular occlusion rather than replacing it.

## 4.1.0
### Shaders
* Added Unity 2017.1 support.
* Fixed "SpeedTree*" shaders to have Unity-recommended instancing limit.
* Removed LOD_FADE_PERCENTAGE crossfade mode.

### Scripts
* Added Unity 2017.1 support.

## 3.6.4
### Scripts
* Fixed issue where Unity static Area Lights' scene GUIs were not appearing after installing Alloy.
* Fixed intermittent object reference error for Material Inspector.

### Integration
* Added HX Volumetric Lighting integration for most particle shaders.
   + Excludes "Multiply (Double)" and "Alpha Blended Premultiply".

## 3.6.3
### Scripts
* Fixed issue where AreaLights needed to update after all other light updates and animation clips had run.

## 3.6.2
### Shaders
* Added new config option A_USE_BLACK_SPECULAR_COLOR_TOGGLE to allow killing specular lighting per-pixel.
   + Useful for RTP integration.
* Changed "Decal/Multiplicative" and "Decal/Ambient" to add missing alpha visualize option on Main Textures Base Color map.
* Completed internal API overhaul.
* Fixed metallic channel not correctly affecting translucent shadows.
* Fixed baked occlusion shadows in injection header shaders.
* Fixed lightmap shadow mixing support.

### Scripts
* Changed Camera inspector to now provide an easy button for adding Alloy Effects Manager components.
* Fixed AreaLight issue where using script to set intensity to zero could cause light to blow out in intensity.
* Removed the "Material Migrator" menu item.

### Integration
* Improved HX Volumetric Lighting integration with "Decal/Additive" shader.

## 3.6.1
### Shaders
   + Fixed the compiler errors that happened when using new shadow masks mode.
   + Fixed issue where baked light occlusion was not being applied to first directional light in forward mode.
   + Fixed the issue where the first directional light wasn't rendering in forward mode with lightmaps enabled.

### Scripts
   + Fixed issue with packer on first import where it could not detect "_PackerDefinition.asset".

## 3.6.0
### Shaders
* Added Unity 5.6 support.
* Added "Particles/Anim Alpha Blended" shader.
* Changed "Details*" shaders to have proper Alloy inspectors.
* Changed most shaders to have new controls:
   + "Render Queue" for sort order.
   + "Enable Instancing" toggle.
   + "Specular Highlights" toggle.
   + "Glossy Reflections" toggle.
* Changed RenderingModes to work correctly with shader replacement. 
   + "Cutout" tagged as "TransparentCutout". 
   + "Fade" tagged as "Transparent". 
   + "Transparent" tagged as "Transparent". 
* Changed SpeedTree GeometryTypes to work correctly with shader replacement.  
   + "Frond" tagged as "TransparentCutout". 
   + "Leaf" tagged as "TransparentCutout". 
* Fixed CarPaint shaders to have "SpecularTint" property.

### Scripts
* Changed Area Light component menu path to "Alloy/Alloy Area Light".
* Changed Area Lights to work with Unity's light inspectors, including the new "Light Explorer".
   + Now uses Unity Light component's color and intensity directly. 
   + You'll need to manually update your scripts and animation clips to point to the Unity light fields.
* Removed "Animated By Clip" option from AreaLight components.
   + Now works with animation clips and third party script tools out of the box.
   + You'll need to manually delete references to it from your animation clips.
* Renamed "Alloy Deferred Renderer Plus" component to "Alloy Effects Manager" to clarify its usage.
   + Now listed under "Alloy/Alloy Effects Manager" in the component menu.
   + Please write down your old settings before doing the update as you may need to re-enter them.
   + You may only need to toggle the component to restore its command buffers.

### Integration
* Added support for "VertExmotion".
* Updated Substance Designer shader to 6.0.
   + UV scale support.
* Updated Substance Painter shader to 2.5.
   + Specular Level channel support.
   + Parallax Mapping support.

## 3.5.2
### Shaders
* Changed deferred Skin and Transmission to work with single-pass stereo VR rendering.
* Fixed issues with deferred Transmission code that would fail to compile on some platforms.

### Integration
* Added support for "Vapor" transparency integration.

## 3.5.1
### Shaders
* Fixed "Tessellation *" shaders target 4.6 warning messages.
* Fixed "Glass *" shaders to support Unity 5.5.
   + Includes single-pass stereographic fix.

## 3.5.0
### Shaders
* Added Unity 5.5 suppport.
* Fixed shadow wind animations on SpeedTree and foliage shaders.
* Fixed "Transmission/TwoSided" shaders' compiler error when they are set to Fade or Transparent mode.
* Optimized the deferred Skin and Transmission effects.
   + Added new config flag A_USE_DEFERRED_MATERIAL_TYPE_BRANCHING to toggle optimizations.

### Known Issues
* Glass shader distortion is much weaker than expected.

## 3.4.5
### Shaders
* Added Unity terrain foliage shaders.
   + Automatically applied when using Alloy "Terrain *" shaders.
* Changed "Skin" shaders so that the base color now affects transmission correctly.
* Changed most shaders so that LOD crossfade is disabled by default.
   + Fixes the batching issue.
* Fixed area light specular highlight distortion in "Forward" Rendering Path.
* Fixed "Glass *" shaders' issue where a zero opacity would cause black voids in reflection probes.
* Fixed SpeedTree Two-Sided lighting.
* Fixed SpeedTree Geometry Type "Fronds" to show "Opacity Cutoff" control.

### Features
* Changed "Main Properties", "Secondary Properties", & "Oriented Properties" to add a "Specular Tint" parameter.
* Changed "Specular Tint" to be available in Roughness Source "Packed Map Alpha" mode as well.
* Fixed "Detail" and "Wetness" Mask Strength parameters to only affect the mask.
* Fixed "Rim Emission" faceting for Normals Source "Vertex Normals".

### Injection Headers
* Changed to be more consistent with the Unity version.
* Fixed issue where opacity was darkening materials in deferred mode.

### Mods
* Added "Core CrossFade" shader with LOD CrossFade support.
* Added "Skin VertexDetail" shaders with vertex color masking for 3-4 detail normal maps.
* Fixed "Curvature Test" shader.

### Integration
* Updated "Alloy Deferred Shading UBER" shader to support UBER 1.2.

## 3.4.4
### Scripts
* Added "Animated by Clip" toggle to the AreaLight component to support Animation Clips.
* Fixed issue where "AlloyRequiredActions.cs" was causing build errors.

## 3.4.3
### Scripts
* Changed "Material Migrator" to run on the entire project, rather than per-scene.
* Changed "Material Migrator" to fix Normals Source on existing materials.
* Changed "Keyword Report" to "Material Report".
* Changed "Material Report" to add a section for shaders to list their associated materials.
* Changed "Light Migrator" to "Light Converter".
* Fixed "Light Converter" to properly convert the intensity from Unity lights.

### Shaders
* Added config options to set which data is read from which channels in the packed maps.
* Added a "Normals Source" setting to enable/disable normal maps.
   + Setting it to "Vertex Normals" enables extensive optimizations to greatly reduce a material's cost.
* Added "Vertex Blend" shader with an optional Alpha splat, and toggleable TriPlanar mapping.
   + Add Alpha splat, and set Roughness Source to Base Color Alpha to match the old "Vertex Blend 4Splat" shader.
* Added "SpeedTree (Forward)" shader that is forward-only and supports the full set of Transmission parameters.
* Changed "Skin*" shaders to add Parallax feature. 
* Changed "Skin*" shaders and camera components to restore Bias and Scale inputs.
* Changed "Terrain" shaders to support enabling optimizations when no normal maps are used.
* Changed "Vertex Blend" to add AO2, Decal support.
* Changed "Terrain" shaders to support TriPlanar mapping as a toggleable feature. 
* Changed "Roughness Source" to be global for the whole shader, and eliminated it in Secondary and Oriented Textures sections.
* Fixed "TriPlanar" and "Oriented" shaders to correctly map textures for shadows and lightmap baking.
* Fixed "Terrain/4Splat" fog in forward mode.
* Renamed "TriPlanar/Full" to "TriPlanar" and modified it to encompass the "TriPlanar/Lite" inputs.

### Features
* Added "Wetness" feature to most of the shaders.
* Changed "Detail" to add a "Mask Strength" parameter.

### Legacy
* Moved "Terrain * TriPlanar" shaders into this set.
* Moved "TriPlanar/Lite" shaders into this set.
* Moved "Vertex Blend/4Splat *" shaders into this set.

### Mods
* Removed "Wetmask/Core" & "Wetmask/Weighted Blend".

### Integration
* Added support for "Hx Volumetric Lighting" transparency integration.
* Fixed Substance Painter custom shader to not cause rough specular in shadowed areas.
* Updated Substance Painter custom shader to support version 2.2.

## 3.4.1
_NOTE:_
* You must run the new Material Migrator tool in each of your scenes to clean up and replace old keywords.
   + Open Window->Alloy->Material Migrator.
   + After it finishes, hit Ctrl+S.

### Shaders
* Added "Eye" shader that is deferred-compatible and provides fine control of each eye component.
* Added Dithered LOD Cross-fade support to the majority of the shaders.
* Changed "Glass" shaders to support Roughness Source "Base Color Alpha" in their Main Textures.
* Changed "SpeedTree" shaders to support Transmission for Fronds and Leaves.
   + Reads alpha transmission from SpeedTree specular maps.
* Changed "SpeedTree" & "Terrain" shaders to disable UV-picking.
* Changed "Weighted Blend" shaders to add "Decal" feature.
* Changed "Decal/Ambient" to affect specular occlusion for more consistent visuals between forward/deferred reflections.
* Changed "Skin" shaders to drop "Detail" Falloff parameter due to lack of use.
* Fixed "TriPlanar" and "Vertex Blend" shaders to have properly implemented Rendering Modes and opacity.
* Fixed "Transmission" shaders to no longer double-apply metallic inputs.
* Moved "Alloy Mods/Decal Ambient" into this set.
* Optimized lighting code to be much faster when the shader doesn't expose any AO or metallic inputs.
* Updated "Alloy Deferred UBER" override shader to support UBER 1.1b (U5.4.0b10 release). 
* Updated "Skin" shader to use corrected LUTs with a slightly wider scattering area. 

### Features
* Changed "Main Textures", "Secondary Textures", and "Oriented Textures" so that their tint alpha still affects opacity when their Roughness Source is set to "Base Color Alpha".
* Changed "Detail" to add the option to use vertex color alpha as a mask.
* Changed "Detail" to drop "AO(G) Variance(A)" & "Occlusion Strength" due to their high cost and lack of widespread use.
* Changed "Directional Blend" to have a vertex color alpha tint property like "Weighted Blend".
* Changed "Directional Blend" and "Weighted Blend" to use a MUCH cheaper blending equation.
   + Cutoff is the same, Blend will need to be re-tweaked.
* Changed "TeamColor" Tint toggle into a dropdown.
* Changed "Tessellation" to remove "Combined" mode option due to lack of use.
   + Planning equivalent functionality for fewer keywords in the next release. Stay tuned.
* Fixed Parallax Mode dropdown where "POM" was displaying as "P O M".

### Injection Headers
* Fixed issue with StandardSpecular where opacity was not being adjusted for metals.

### Scripts
* Added Window->Alloy->Samples menubar item.
* Added Window->Alloy->Keyword Report menubar item.
* Added Window->Alloy->Material Migrator menubar item.
* Changed Window->Alloy->Light Migration Tool to Window->Alloy->Light Migrator menubar item.
* Changed "Material Map Channel Packer" to drop "Detail" packed map since we are no longer supporting it.
   + We recommend deleting these maps from your project since they're now useless.

### Legacy
* Changed "Skin" shaders to drop "Detail" Falloff parameter due to lack of use.
* Moved "Alloy/Eye/Eyeball" shaders into this set.
* Moved "Alloy/Eye/Eyeball (Legacy)" shaders into this set.
   + Renamed to "Eye/Eyeball (Forward)".
* Moved "Alloy/Eye/Eye Occlusion" shaders into this set.
   + Use the "Alloy/Decal/Ambient" shader instead to achieve the desired eye occlusion effect.

### Mods
* Added "Car Paint Fast ClearCoat" shader which uses an experimental new ClearCoat approximation.
* Changed "SP Car Paint" to use an experimental new ClearCoat approximation.
* Changed "Weathered Blend" to add "Occlusion Strength" and "Normal Strength" parameters.
* Changed "Weathered Blend" to base its "Detail" feature UVs on the detail color map.
* Fixed "Weathered Blend" base material map AO to be converted to linear-space before being applied.

## 3.4.0 b4
### Shaders
* Changed "Mode" to "Roughness Source", "Full" to "Packed Map Alpha", and "Lite" to "Base Color Alpha".
* Fixed issue where deferred override shaders failed to compile while creating a build.

### Scripts
* Fixed issue where Deferred Skin was getting blocky artifacts when the editor viewports were resized.
* Optimized Deferred Skin to use less bandwidth and VRAM at runtime.

## 3.4.0 b3
### Shaders
* Added most of the Alloy shader features to the "SpeedTree" shader.
* Added scroll to the "Vertex Blend TriPlanar" shaders' texture inputs.
* Fixed instancing z-fighting issue with lighting in forward mode. 
* Optimized the "Vertex Blend", "Terrain", and "TriPlanar" shaders.
* Optimized forward lights by removing redundant calculations and moving some of the work to the vertex shader.
* Disabled instancing for now since it keeps interfering with several systems:
   + SpeedTree wasn't being affected by wind. 
   + Transmission brightness was off for directional lights. 
   + Skinned meshes were crashing the editor.

## 3.4.0 b2
### Shaders
* Added single-pass stereo rendering support.
* Added "Skin (Forward)" shaders whose parameters and lighting behavior match our "Deferred Skin" pipeline.
* Added instancing support to most of the shaders, including "SpeedTree".
* Changed "Skin" shaders to remove scattering mask so that the metallic mask and controls could be restored.
* Changed "* SingleSided" & "* DoubleSided" shaders to "* OneSided" and "* TwoSided" for easier navigation.
* Fixed "SpeedTree" and "Hair" shaders' incorrect lighting on backfaces.
* Moved "Skin (Legacy)" shaders into the "Legacy" sub-folder/menu.
* Optimized "Transmission TwoSided" shaders to use fewer passes.

### Scripts
* Added Mask Cutoff parameter to "Deferred Skin" to support thresholding transmission as a scattering mask.
* Changed "Deferred Skin" to never have shadowed transmission.
* Changed "Deferred Transmission" to only be shadowed for "TwoSided", or when "OneSided" shadow culling is set to Front.
* Fixed "Deferred Skin" blocky normal artifact. 
* Removed "Deferred Skin" Bias and Scale parameters due to their lack of clarity and often being left on their defaults.

### Legacy
* Moved "Skin (Legacy)" shaders into the "Legacy" sub-folder/menu.

## 3.4.0 b1
### Shaders
* Added Unity 5.4 support.
* Added Light Probe Proxy Volume support to all lit shaders, including particles.
* Added a "Lite" mode to Main, Secondary, and Oriented Textures to get roughness from the base color map alpha.
* Fixed "Partices/VertexLit Blended" shader to support 1 Directional Light, 4 Point Lights, and Light Probes (including LPPV).
* Fixed the vertex lighting code to support the Unity attenuation config flag.
* Fixed SpeedTree shader to apply AO correctly. 
* Fixed Skin Transmission to not be so much darker than regular transmission.

### Scripts
* Optimized Deferred Skin rendering.
   + Also removed some development controls that weren't really artist-friendly.

### Mods
* Added "SP Car Paint" shader that is similar to the Substance Painter CarPaint shader.

## 3.3.5
### Shaders
* Added detail normal map support to the SpeedTree shader's "Branch Detail" mode.
* Added "nSplat" terrain shader variants.
* Added "AO2" feature to the "Transition" shaders.
* Added "Detail" feature to the "Terrain" and "Vertex Blend" TriPlanar shaders.
* Changed "Weighted Blend" and "Directional Blend" to use their secondary textures alpha to influence blending.
* Changed "Parallax" effect to reduce cost when using it in conjunction with Amplify Texture.
* Changed the internal API coding style.
   + If you use the config header, you will need to use the new flag names.
   + Contact us if you are using customized shaders and require updates.
* Fixed "Eyeball" shaders to apply pupil dilation effect with Amplify Texture.
* Fixed "Eyeball" shaders to sample normal maps when using Amplify Texture.
* Fixed the Unity attenuation option to match between Forward and Deferred mode.
* Fixed "Hair HighQuality" issue with depth of field.
* Fixed incomplete mode feature definitions for the "TriPlanar" and "Directional Blend" shaders.
* Fixed "Transition" shader's weird edge glow and blending behavior when using "Parallax" effect.
* Fixed "Oriented Blend" shader to apply "AO2" effect on top of the oriented blend layer as well as the base layer.
* Fixed missing "AO2" effect on "Directional Blend" shaders.

### Scripts
* Added a workaround for 3rd party plugins that use conflicting definitions for Unity's BlendMode enum.
* Added two new packed map modes to simplify converting Unity metallic and terrain packed maps to Alloy's formats.
* Fixed the Material Map Channel Packer to no longer transfer blurry samples from the input maps.
   + We strongly recommend that you reimport all your packed maps to apply this fix.
* Optimized the Material Map Channel Packer for much better packing speed.

### Mods
* Added "Transition Lite" shader that uses terrain packed maps for Main and Secondary Textures, as well as removing the glow effects from dissolve and transition.
* Added "Decal/Ambient" shader which is a mesh-based decal shader that multiplicatively blends only the ambient contribution.

### Known Issues
* redLights 2.0 integration is currently broken.

## 3.3.4
### Shaders
* Added support for directional disc area lights.
* Added support for enabling Unity attenuation.
   + Enable via config flag.
* Added support for Amplify Texture heightmaps in Parallax feature. 
* Fixed where the material inspector visualize shader wasn't compiling on the Mac OSX Metal build target.
* Fixed a PS4 compilation issues in the Deferred Skin post-process shaders.

### Scripts
* Updated the area light control to support radius on directional lights for disc lights.

### Integration
* Fixed the SD5 shader "Packed *" techniques to use a "packedMap" input like the original shader. 

### Mods
* Added the "Mesh Particle Core" shader that uses vertex colors to look up base and emission color from gradient textures.
* Fixed "Deferred Decal Advanced" shader's compilation error.

## 3.3.3
### Shaders
* Fixed the Skin shaders to not blur the specular illumination.

## 3.3.2
### Shaders
* Added support for Tube area lights.
   + Disable via config flag to slightly improve sphere light performance.
* Added a "Cull Mode" option to the Unlit shaders.
* Changed the mesh-based Decal shaders to be forward-compatible so that they have material inspector previews.
* Fixed Sphere Lights to remove distortion in their diffuse terms.
* Fixed Transmission to remove darkening and distortion due to large area lights.
* Removed the legacy CarPaint mask flag from the config header.

### Scripts
* Updated the area light control to support length on point lights for tube lights.

## 3.3.1
### Shaders
* Added the "Decal/Additive" mesh-based deferred decal shader.
* Fixed the Deferred Transmission and Skin effects to work with Deferred Reflection Probes disabled. 
* Fixed the Decal shaders to disable z-writes.
* Fixed the the bug where vertex colors were being double converted from gamma to linear resulting in oversaturated colors. 

### Integration
* Updated Substance Designer custom shader to support version 5.3.1.
   + Condensed all the shaders into one FX file with multiple techniques for ease of import.
* Updated Substance Painter custom shader to support version 1.6.
   + Removed the opaque shader, since the alpha test shader will work just as well in this context.

## 3.3.0
### Shaders
* Added SpeedTree shaders.
* Added the "Decal/Alpha", "Decal/Cutout", and "Decal/Multiplicative" mesh-based deferred decal shaders.
* Added deferred Eyeball shaders.
   + Renamed the existing forward-only Eyeball shaders to "Eyeball (Legacy)".
* Added deferred Skin shaders.
   + Uses new "Alloy Deferred Skin" deferred override shader & "Deferred Renderer Plus" camera component.
   + Renamed the existing forward-only Skin shaders to "Skin (Legacy)".
* Added deferred Transmission shaders.
   + Uses new "Alloy Deferred Transmission" deferred override shader & "Deferred Renderer Plus" camera component.
   + Renamed the existing forward-only Transmission shaders to "Transmission (Legacy)".
* Added support for colored light cookies to both our shaders and the Unity surface shader injection headers.
   + AreaLight script now automatically sets cookie on Spot lights that don't have one.
   + Set config flag to restore legacy behavior.
* Added a "Falloff" parameter to the Skin shader Details effect to simulate micro-occlusion at grazing angles.
* Added AO2 to the Weighted Blend shader.
* Changed all the tessellation shaders to add MacOSX support.
* Changed the TeamColor feature to offer the option to use the Masks texture directly as a color tint.
* Changed the TeamColor feature to use the new masks vector control for selecting which channels to use from the Masks map.
   + You will need to update any materials that were using RGBA masks.
* Changed the shaders to store specular occlusion directly in the Gbuffer to reduce cost and improve SSRR integration.
* Changed section names to be shorter and more readable in the material inspector.
* Changed Flakes properties so that the tint color alpha affects the flake mask.
* Changed ForwardEye shader to disable Iris highlight to simplify lighting API.
* Fixed the ForwardSkin and Skin shaders to correctly mask blurred normals.
* Fixed a bug in the override headers where they weren't correctly calculating Point/Spot lights in forward mode.
* Fixed the "Unlit" shaders so that it now renders properly when set to Fade/Transparent. 
* Fixed the "Oriented Core" shader to gamma-correct vertex colors before using them as tints.
* Fixed our tessellation shaders to not apply tessellation in their Meta passes.
* Fixed the Terrain and Vertex Blend TriPlanar modes to use per-pixel normals for specular occlusion and environment specular.
* Moved all the character shaders into the new sub-menu "Human".
* Moved the Terrain shaders into the "Nature" sub-menu to be with the SpeedTree shaders.

### Scripts
* Added more validation and warnings to the Material Map Channel Packer.
* Added a new "Deferred Renderer Plus" camera component to support deferred Skin and Transmission.
* Added per-light specular highlight toggle.
   + AreaLight component is now required on ALL lights, so use our Light Migration tool to update them.
* Changed the Light Migration tool to support the AreaLight component on all lights, and DefaultSpotCookie on Spot Lights.
* Changed all our packer definitions to be serialized to text by default to prevent issues in "Force Text", and "Mixed" modes.
* Fixed a bug in the Particle inspector where the UI wouldn't appear.

### Mods
* Added a two-pass, forward-only Full ClearCoat CarPaint shader.
* Added a prototype Deferred Decal shader.
* Added the "Intersection Glow" shader which is used for drawing clear domes with rim & emission effects that glows when it intersects other geometry.
* Added the "Masked Core" shader prototype which uses a shared packed masks texture and the ability to pick multiple masks to apply to the Detail, Emission, and Rim effects.
* Moved deferred-compatible Eyeball shader to official set.

### Documentation
* Added new sections for "Advanced Setup" of the deferred transmission and skin effects.
* Updated and reorganized most of the existing sections.

## 3.2.7
### Shaders
* Added a deferred reflections override shader.
* Added a shadow cull mode setting on the "Transmission SingleSided" shaders.

### Integration
* Changed the Subtance Painter preview shader to account for SP 1.5 changes. 
* Fixed the Subtance Painter preview shader alpha blending/test shader variants.

## 3.2.6
### Shaders
* Fixed and simplified the UBER integration by adding a dedicated deferred shader.

### Scripts
* Fixed the Map Packer pack definition corruption problem.

## 3.2.5
### Shaders
* Added "Alloy/Particles/VertexLit Blended" shader with support for vertex lighting and light probes.
* Added UBER integration to our deferred override shader.
* Added Occlusion Strength and Normal Strength parameters to all relevant shaders.
* Added Beta Alloy brdf and area light override headers for Unity's surface shader system.
   + Currently works for surface shaders using Standard, StandardSpecular, Phong, and Lambert lighting models.
* Changed default HDR Clamp from 32 to 100.
   + To restore legacy, modify setting in config header.
* Changed the "CarPaint" shaders to have the flake map RGB act as a tint, and the alpha act as the mask.
   + Set config flag to restore legacy behavior.
* Changed the Unlit shaders' Main Textures properties' Tint parameter to use an HDR Color picker.
* Changed the Unlit shaders to affect the Gbuffer in deferred mode so that image effects will detect them.
* Changed light probe sampling to be fully per-pixel by default.
   + Restore legacy behavior with config flag.
* Changed our internal Luminance code to a more modern formula, which may affect look of specular tints.
* Fixed an issue with the Skin shader where it wasn't correctly accounting for shadows and attenuation in it's LUT lookup.
* Fixed an issue in the Static Directional Specular mode where we weren't applying the direct contribution.
* Fixed the Directional Specular lightmap mode to apply AO to its diffuse contribution to look more consistent with the other lightmap modes.
* Fixed the POM distortion that occurred on large triangles at grazing angles.
* Fixed the random popping issues in the POM effect that occurred when the camera moved away from the object.
* Fixed the default value for the Transmission shaders' Bump Distortion to make the effect more apparent.
* Fixed the divide by zero compiler warnings for some of the shaders.
* Fixed a GLSL compilation issue.

### Scripts
* Changed the channel packer tool to make it data-driven and support user-defined packer modes.
* Fixed the issue where freshly imported packed maps would be broken and need to be manually reimported. 

### Mods
* Changed the Weathered Blend shader to apply parallax to the base masks and normals.

## 3.2.1
### Scripts
* Fixed incorrect gamma correction in Map packer to account for changes in Unity 5.1.

## 3.2.0
### Shaders
* Added the "TriPlanar/Full" and "TriPlanar/Lite" shaders.
* Added TriPlanar variants of "Terrain/4Splat" and "Vertex Blend/4Splat".
* Adjusted the normal projection for "Oriented/Blend" and "Oriented/Core".
* Merged "Directional/Blend World" and "Directional/Blend Object" into "Directional Blend".
* Migrated all the emission effects to using the new Unity HDR color picker.
* Modified the "Transmission DoubleSided" shader to add the parameters Shadow Weight & Invert Back Normals.
* Fixed the backface lighting for the "Transmission DoubleSided" shaders.
* Removed the legacy features flags.
* Renamed "Hair/Translucent" -> "Hair/HighQuality" and "Hair/Base" -> "Hair/LowQuality" for clarity.
* Renamed "Vertex Blend 4Splat" -> "Vertex Blend/4Splat" for grouping flexibility.

### Scripts
* Removed the legacy Intensity Gain color control from our inspector definition system.
* Removed the AlloyUtils.IntensityGain() utility function.

### Mods
* Added the deferred-compatible Eyeball shader prototype.

## 3.1.2
### Shaders
* Changed all instances of "_AlphaTestRef" property to "_Cutoff" to ensure compatibility with Unity 3.1's depth-normal pass replacement shader.
* Fixed Oriented Blend and Core shaders to swap X & Z normal mapping and to properly convert Y on the underside of the object.
* Fixed distant terrain shader to use Unity's renamed metallic texture property and roughness.

## 3.1.1
### Shaders
* Added a new "Combined" tessellation mode that combines Phong and Displacement.
* Fixed the GI code that caused weird noisy glitching artifacts on some MacOSX platforms.
* Fixed the Parallax code that was causing it to fail to compile on the PS4.
* Fixed the Detail feature code that caused it to fail to compile on some MacOSX platforms.
* Fixed the Substance Designer preview shaders' code that caused them to fail to compile on AMD GPUs.

## 3.1.0
### Shaders
* Added "Directional Blend" shaders with support for blending around an arbitrary direction on the surface.
* Added "Vertex Blend 4Splat" shaders with support for blending 4 splats using vertex colors.
* Added a secondary vertex color tint slider to the "Oriented*", "Transition", & "Weighted Blend" shaders.
* Added a Pupil Dilation control to the "Eye/Eyeball".
* Added directional control to the "Oriented Blend" shaders.
* Changed all shaders to now have the Global Illumination control at the top so all types of emission can affect GI.
   + You will need to manually set all your static objects to "None", as this control always defaults to "Realtime".
* Changed the "CarPaint" shader.
   + Added a primary tint color that is applied in the masked areas.
   + "Main Textures" tint color now affects both primary and secondary paint colors.
   + Toggle legacy behavior in the config header.
* Changed the "Eye/Eyeball" shader.
   + Split up the "Eye Properties" into two smaller sections.
   + Added a Schlera tint color.
   + "Main Textures" tint color now affects both Schlera and Iris colors.
   + Toggle legacy behavior in the config header.
* Changed our Parallax code to reduce the overall cost per active feature and simplify the API.
* Changed "Weighted Blend" & "Oriented Blend" to allow emission to be blended over.
* Changed "Weighted Blend" to remove Secondary Rim, as there should only be one rim term for the combined material.
* Changed "Transition" so that the Dissolve feature now accounts for each layer's parallax texture offsets.
* Changed API
   + Rebuilt our lighting code to give each lighting type its own shareable module, removing the code from the shaders.
   + Simplified our texture coordinate macro system so that each texture doesn't need to know about parallax.
   + Added a masking system to allow features to be externally masked for different blending behavior.
* Fixed the "Particle*" shaders so that input vertex colors now receive gamma-correction.
* Fixed the "Tessellation/Oriented*" shaders which erroniously were set to target SM3.0, and had parallax properties.
* Fixed it so that Fade rendering mode no longer increase opacity when the surface metalness increases.
* Fixed the code we use to transform normals for our Oriented shaders.
* Fixed a compiler bug on the "Eye/Eyeball" shader when using the Dissolve feature in SM3 mode.
* Fixed a Null Ref error when using substances and switching shaders.
* Fixed the rendering modes dropdown to now work with undo.
* Fixed a potential compilation bug in the Glass shader when used on consoles.

### Scripts
* Fixed the Material Map Channel Packer so that its controls now support undo.

### Mods
* Weathered Blend (an experiment in attenuating a type of 2mat blend with further mesh data).
* WetMask Set (used in the Remnants demo for combining Weighted blend with scrollable wet sections).

### Known Issues
* The visualize feature currently doesn't work properly for textures that use world-space UVs.

## 3.0.2
### Shaders
* Changed to an optimized BRDF visibility function.
   + Toggle legacy behavior in the config header.
* Changed our higher quality Environment BRDF to use a formulation that maps correctly to linear roughness.
* Changed the Environment BRDF to use our new formulation by default.
   + Required some small changes to the lighting API.
   + Toggle legacy behavior in the config header.
* Fixed a bug in the Weighted Blend shaders where the vertex tint control was not doing anything.

### Features
* Changed the TeamColor module to use our new formulation by default.
   + Toggle legacy behavior in the config header.

### Scripts
* Fixed a possible bug in the Material Map Channel Packer where it would error if any of the input textures didn't have mipmaps enabled.

### Integration
* Substance Designer
   + Changed visibility function to match Unity shaders.
   + Removed the Specular AA feature as it was never really working properly due to the lack of mipmap generation.

## 3.0.1
### Shaders  
* Added support for tinting the base color with vertex colors.
* Added a Mode dropdown to the Team Color feature to support explicitly turning off the alpha mask.
* Modified the Weighted Blend shader to control the influence of the vertex alpha on the weight.
* Modified the vertex lighting fallback to use Alloy's attenuation function.
* Modified the config header options.
* Fixed a compilation issue with the terrain shaders.
* Fixed a bug in the AlloyVertex() callback where it wouldn't properly handle vertex position modification.

### Scripts
* Fixed a potential bug on the AreaLight component where it wouldn't let you change the light intensity or color if the light was disabled. 

### Features
* Modified the Decal feature:
   + Added a Weight property to allow smoothly turning decals on and off from scripts without modifying the tint color.
   + Added a property for controlling how much the vertex color alpha weights the Decals.

### Integration
* Substance Painter
   + Updated the preview shader to support SP1.3.
   + Added Alpha translucency and cutout variants of the preview shader.

## 3.0.0 beta8
### Shaders  
* Added a cutoff control the Hair Translucent shaders to allow control over the opaque regions for better sorting.
* Modified all the Tessellation shaders to use their regular variants as fallbacks. 
* Fixed a problem with the Detail feature where it wouldn't compile on MacOSX. 

### Scripts
* Added a new tool for migrating existing punctual lights to Alloy area lights.
* Fixed our Area Light code to now convert existing light data to our representation when the Area Light component is added.
* Fixed our Terrain Packed Maps to correctly grab color info, rather than just a single channel.
  
## 3.0.0 beta7
### Shaders 
* Added a new config option for higher quality IBL fresnel.
   + Currently disabled by default as we decide if we want to make it the new default. 
* Changed the Tessellation shaders so that the Displacement property goes up to a max of 30.
* Moved the Max intensity constant to the Config header to allow easier customization. 
* Fixed a bug in our Amplify Texture support code where we were using the wrong function when sampling normals.

## 3.0.0 beta6
### Shaders 
* Changed the Particle shaders:
   + Added a rim fade feature to support light shaft effects.
   + Added a near fade feature to support fading particles that get close to the camera.
   + Centralized their code in a shared header for easier maintenance. 
* Switched to using Unity RC3's new [Gamma] attribute for some input properties to save calculations inside the shaders.

## 3.0.0 beta5
### Shaders 
* Changed the config header to add an option for enabling a minimum tessellation edge length property. 
  This can be globally set by a script to control the tessellation quality of all models.
* Changed surface shader API.
   + Changed most of the shader pass code to centralize their shared code.
* Changed the Oriented Blend shader:
   + If the Oriented material has an alpha channel, it alpha blends on top of the base material.
   + If the base material has an alpha, it will alpha through or cutout the oriented material.  

## 3.0.0 beta4
### Shaders 
* Changed surface shader API.
   + Added support for modifying vertices.
   + Added support for final color modification.
   + Added an explicit folder with default headers for various surface shader callbacks. 
* Fixed the Distort pass to now support Fog.

### Scripts
* Material Inspector
   + Fixed an issue with the visualize function where the underlying mesh would poke through on edges.

## 3.0.0 beta3
### Shaders 
* Changed the Terrain shaders.
   + Restored the additional per-splat parameters and base layer.
   + Restored deferred support. 
   + Removed 5-n splat support. 
* Fixed several Unity config problems
   + Shaders were Orthonormalizing when they shouldn't have been.
   + Shaders were using Box projection and probe blending when they shouldn't have been. 

### Scripts
* Material Inspector
   + Added a new control for Unity's LightmapEmissionProperty.

## 3.0.0 beta2
### Shaders 
* Added "Oriented/Core" shaders
   + World-textured material.
* Changed the Oriented Blend Shader
   + Changed the name to "Oriented/Blend".
   + Now uses its own property names, so allow easy copying between it and "Oriented/Core".
   + Now blends based on the per-pixel world normal, rather than the geometry world normals.
* Changed Skin shaders 
   + Added an explicit skin mask and removed implicit control through the translucency map.
   + Changed Transmission to now convert the Translucency map input to linear space.
   + Removed Metallic control and mask.
* Changed Weighted Blend/Transition shaders.
   + Secondary maps now support Scroll and UV Set selection.
* Changed all shaders.
   + Base and Detail maps now support Scroll and UV Set selection.
* Fixed the Eyeball shader to default Iris Depth to 0.08 rather than 1.
* Fixed the Terrain
   + Had to remove a bunch of features since Unity took away the ability to use them.
   + It now can use the per-splat and distant metallic feature. 

### Scripts
* Material Inspector
   + Added support for rendering a Vector2-4 control for Vector properties. 
   + Fixed a bug where it would render a color control for Vector properties.

## 3.0.0 beta1
Lighting:
* Added support for both Point and Spot Spherical Area lights!
* Modified Point and Spot lights to use Inverse Square physical attenuation.
* Modified our lighting model.
   + Diffuse now exhibits interreflection for rough materials.
   + Specular lighting now uses the GGX BRDF.
* IBL
   + Added support for Unity 5's new reflection probes, dynamic GI, directional lightmaps, etc.
   + Removed RSRM support. 

### Shaders 
* Added Car Paint shader.
* Added Prototyping shader.
* Added Hair shader.
* Added Eye shader.
* Added Eye Occlusion shader.
* Added Glass shader. 
   + Replaces Transparent Distort 
* Added Unlit shader. 
   + Replaces the old Glow shaders.
* Added Weighted Blend shaders.
* Added Oriented Blend shaders.
* Added Terrain shaders.
* Added Transmission shaders.
* Added Particle shaders.
* Added Tessellation variants of all shaders.
* Changed Skin shaders 
   + Added attenuation to the transmission effect.
   + Transmission is now in Base alpha.
   + Specularity is now in the Material Map blue channel. 
   + Transmission "weight" parameter is now converted to linear internally.

### Features
* Added Ubershaders!
   + Users can now add/remove features within a shader rather than by switching shaders.
   + Uses the new shader_feature system to compile on demand and cut down on excess keyword usage.
* Added Vertex-weighted Decal feature.
   + Can control where alpha decals appear on the mesh per-vertex.
   + Dropped detail material and normal and now rely on this variant being combined with the Detail feature.
* Added Masked Detail feature.
   + Can use a per-pixel mask to control area of influence.
* Added UV mode to AO2, Detail, Dissolve, and Effect texture controls.
* Added AO2 support to the Car Paint, Glass, and Transmission shaders.
* Merged Masked Incandescence system with Unity's new Emission feature.
   + Allows it to feed into the lightmap and dynamic GI systems.
* Changed Dissolve, Emission, and Rim effects to use Gain, rather than intensity.
   + [0,1] range with a perceptually linear gain in intensity.
   + Added a weight parameter to dissolve glow to compensate for added intensity.
* Changed primary textures to now use native Unity transforms.
   + You can now tile the other texture groups independently of the "Main Textures" group.
   + Rim and Emission color textures now have an Offset parameter.
* Changed the TeamColor feature so that the RGB masks are applied on top of the alpha mask.
   + Can now use RGB textures to save memory.
   + Testing is simpler, since you no longer need to make a texture with a zero alpha.
* Fixed the issue where tiled secondary textures (Detail, Decal, etc) would "swim" when using parallax.

### Scripts
* Light Inspector
   + All lights can now support intensities higher than 8.

* Area Light Inspector
   + Extends existing Point and Spot light gameobjects to add Size information.
  
* Material Inspector
   + Added a new in-shader DSL UI definition system.
   + Added a new ubershader UI.
      - User enables features by adding/removing properties sections.
      - Uses Unity 5's render mode selector rather than separate Opaque, Transparent, etc shaders.
   + Changed the Visualize feature
      - Added support for visualizing on Skinned Meshes.
      - Added support for submesh visualization.
      - Added UV mode support, including on parent textures.
      - Changed button to now appears outside collapsed transforms section on textures.
      - Fixed a bug where visualizing individual channels displayed with the wrong intensities.
      - Fixed the bug where visualize button appeared on materials selected inside the project window.
   + Changed the Texture controls
      - Renamed "Velocity" to "Scroll".
      - Added a "Spin" value for spinning textures on particles.
      - Added UV mode to control whether a texture uses UV0 or UV1.
   + Fixed the bug where materials would throw exceptions if they had more than one property with the same name but different types.
   + Fixed the issue with Texture controls where you couldn't pick a different texture in the same open window after picking one.
  
* Material Map Packer
   + Added a new "Terrain" packed mode for supporting maps with color and roughness.
   + Modified the save path to reduce its width for extremely deep folder paths. 
   + Fixed an issue where the float value controls were previewing a color that was too dark.
  
* RSRM Generator
   + Removed since we discontinued support for them.
  
### Integration
* Skyshop
   + Removed support.

* Substance Designer
   + Added support for Alloy's new BRDF.
   + Added support for SD4.6.
      - Support for the new "specularlevel" input, with legacy support for our own "specularity" input.
      - Emission support.
      - Opacity support, but it blends incorrectly since it is in gamma-space.
      - Tessellation support.
   + Fixed some issues that caused the Specular highlights to be too dark.  
   + Fixed an issue where the the ambient occlusion's ambient intensity was being changed. 
   + Removed support for D3D-style normal toggle, since Unity doesn't support that.
  
* Substance Painter
   + Added a new Alloy preview shader. 

Demo Assets:
* Updated all the materials to use Alloy 3.0 shaders.

Known issues:
* Visualize feature does not work correctly when used with parallax or tessellation. 

## 2.1.2
### Tools
* Material Inspector
   + Changed the Visualize feature
      - Added support for visualizing on Skinned Meshes.
      - Added support for submesh visualization.
      - Fixed a bug where visualizing individual channels displayed with the wrong intensities.
      - Fixed the bug where visualize button appeared on materials selected inside the project window.

* Material Map Packer
   + Fixed an issue where the float value controls were previewing a color that was too dark.

### Integration
* Skyshop
   + Updated Alloy to use Skyshop 1.11.

## 2.1.1
### Shaders
* Fixed the translucent & skin shaders to render correctly in deferred mode on MacOSX.
* Fixes issues when using skin shaders with Candela in deferred mode. 

### Integration
* Substance Designer
   + Updated Alloy preview shader to use the new SH diffuse lighting feature.
   + Added a new shader to render using packed material map rather than individual channels.

## 2.1.0
### Shaders
* Added support for Parallax & Parallax Occlusion Mapping modes in "\Core" and "\Transparent\Cutout" shaders.
* Added a TeamColor detail mode to the standard shaders.
* Added archviz-friendly UV1AO2 shader variants.
* Dissolve 
   + Added variants to all the standard shaders so it is easier to apply the effect to common materials.
   + Changed the Cutoff parameter to use [0,1], rather than [0,1.01].
* Skin 
   + Moved to "Skin" folder.
   + Generalized to support other shader features (Decal, Detail, Rim, etc)
   + Added custom material editor support.
* Modified “Self-Illumin/Glow” and “Self-Illumin/Glow Cutout” to use the custom editor.
* Added support for Skyshop 1.07 and up.
   + Box projection is now accessed through skyshop's sky manager UI.
   + Added support for sky blending.
   + _PLEASE NOTE:_ Alloy will no longer work with older versions of Skyshop due to changes in how they do their calculations.
* Changed the custom editor parameter names and order to improve readability.
* Fixed an issue where the misnamed Decal material map parameter prevented it from showing up in our custom editor.
* Fixed an issue where we weren’t gamma-correcting the transition glow intensity in the Transition shaders.
* Restored support for low-quality vertex lighting mode.

### PackedTextures (ie. "_AlloyPM" and "_AlloyDM")
* Added support for setting the Wrap Mode on packed textures.
   + Still defaults to "Repeat".
* Added support for setting packed textures to "Automatic TrueColor" format.
   + Best to keep it on "Automatic Compressed" unless compression artifacts are harming visuals.
* Added support for setting max size on packed textures.
   + Capped to not exceed texture's dimensions.
* Fixed issue where user could accidentally set the packed textures to an invalid format.

_NOTE:_ It is also possible to set the Aniso level, in case you didn't know.

### Substance Designer
* SD4.1 shader fix so it no longer manually gamma-corrects the environment map. 

### Bug Fixes
* Fixed an issue where our custom material inspector's tab and texture name text was hard to read in Light Skin mode.
* Minor cleanup in our RSRM Generator and Material Map Packer to make them more readable using Light Skin.

### DEPRECATED
* The following shaders and paths are to be removed after this release:
   + "Assets/Alloy/FX/Transparent/Cutout/*"
   + "Assets/Alloy/Core/Skin Bumped"

## 2.0.4
* EMERGENCY hotfix because I'm an idiot.

## 2.0.3
* Added beta Skin shader in Core set (Skin Bumped).

## 2.0.2
* Fixed inspector bug preventing custom cubes to be input.

## 2.0.0
### Shading Improvements
* Increased Specular Power Range
* Better Visibility Function * Treyarch Shlick Approximation
* Specular Occlusion (Tri-ace style)
* Specular Anti-Aliasing via Roughness Correction

### Updated Shader Features
* Smoothness changed to Roughness (to line up with SD4, and other industry conventions)
* Added Specularity Parameter for varying specular intensity on dielectrics
* New RGBA Packed Data Map (R = Metallic, G = AO, B = Spec, A = Roughness)
* Dropdown for Ambient Lighting options, rather than multiple shader variants.
* Added Exposure Boost for traditional cube reflections 
* RSRMs now affect ambient diffuse
* More controls and texture features for Masked Incandescence and Rim Lighting

### New Workflow Tools
* Custom Material Inspectors
* Alloy Packed Map Generator
* Alloy RSRM Generator Editor
* Substance Designer 4 Preview Shader with sample graphs 

### New Shader Variants
* Decal Texture Versions in Each Variant Set
* Distortive Translucent Variant Set
* Alpha Cutout Variant Set
* VFX Dissolve and Transition Shaders

### Full Skyshop Compatibility
* Global Sky Settings, Diffuse SH, FIltered Spec Cube
* Custom Overridden FIltered Spec Cube
* HDR Filtered Cube-capture using Alloy Materials
* Box Projection Support

### Known Issues
* Some faceting can occur on super smooth surfaces in deferred mode due to normal buffer precision (only Unity can fix)
* Translucent shaders only receive 1 dynamic light in deferred mode due to a Unity 4.3 glitch (we have an open bug report)
* Deferred mode is totally busted on OSX. We have no idea wtf is happening, but we're trying to figure out what it is.
* We don't have a terrain shader currently. Don't worry, we're working hard on it, but didn't want to delay this update further.


## 1.0.1
* Standardized the API naming conventions to avoid name collisions when mixing shader libraries. This will break current user-created shaders, which will need to be updated to use the new API.
   + RimLight() -> aRimLight()
   + EPSILON -> A_EPSILON
   + DeGamma() -> AlloyDeGamma()
   + LinearLuminance() -> AlloyLinearLuminance()
   + etc.
* Added a new material API to move implementation details of our material system out of the individual shaders. 
   + Direct access to the SurfaceOutput will no longer work correctly.
   + For custom shaders, we strongly recommend using the new API.
* The headers are no longer obfuscated, and come fully commented.
* Renamed “Alloy/Transparent/MaskedIncandescence Rim” to “Alloy/Effects/MaskedIncandescence Rim” since it doesn’t integrate with Unity’s translucency system for baking.
* Fixed an issue in “Alloy/Effects/MaskedIncandescence Rim” where it wasn’t getting texture coordinates from the mask texture
* Reoredered the parameters for all the “*MaskedIncandescence*” shaders so that the Mask is higher up to show that it uses the first UV set while the Incandescence texture uses the second UV set.
* Removed an unnecessary energy conserving step from the distort pass of the alpha distort shaders.
* Fixed an issue where alpha was darkening albedo in cutout shaders.
* Fixed an issue in the terrain shaders where the blend weights were being applied twice to the smoothness, causing them to be biased toward rough values where multiple splats overlapped.
