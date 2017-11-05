# Changelog

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
