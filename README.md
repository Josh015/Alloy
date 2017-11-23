# Alloy
This code is provided AS IS with no support guarantees beyond attempting to keep pace with new Unity releases.

## Pre-Import Checklist
Alright, so we're ready to jump into some Alloy goodness, but there's a few things we want to make sure we're ready for depending on what the state of your project is, and what past version of Alloy (if any) are in your project.
First and foremost, if you are importing a new version of Alloy into a project where _any_ prior version of Alloy existed, it's probably a good idea to have a backup of it (manual or version controlled), just in case something goes awry.

### Import Steps
1. Ensure you are in a new blank scene.
2. ENSURE that there are NO script errors in your console preventing unity from recompiling assemblies. Alloy will NOT function properly (including our editor scripts), if you attempt to import with standing errors in your project.
3. Import the Alloy package from the Unity Asset Store download window if you have not yet done so.
4. The first thing you'll notice in the Alloy folder is that there is a sub-directory called 'Packages'.Within this directory there will be a package named Alloy3xx_ShadersAndEditorCore. Import this package first.
5. If you are a Windows user, and wish to use Alloy Tesselation Shaders (DX11 only), import the Alloy3xx_SM5Shaders folder. In general these shaders take a bit longer to compile/import, so we suggest only importing the variants you intend on using.
6. Lastly, if you'd like to check out our shweet samples, import the Alloy3SampleAssets package. Enjoy!

## Setting Up Your Project
Before using Alloy, there a couple things you MUST set up in your project:

1. Open Edit->Project Settings->Graphics.
2. Set the 'Deferred' setting to 'Custom shader'.
3. Open the picker below, and select the 'Alloy Deferred Shading' shader.
   * See "Advanced Setup" section for additional options.
4. Set the 'Deferred Reflections' setting to 'Custom shader'.
5. Open the picker below, and select the 'Alloy Deferred Reflections' shader.
6. Open Edit->Project Settings->Player.
7. Open the 'Other Settings' rollout.
8. Set 'Color Space' to 'Linear'.
9. If you wish to use many lights, set 'Rendering Path' to 'Deferred'.
10. Select your camera in your scene.
11. Check the 'HDR' box.
12. Open Edit->Project Settings->Quality.
13. Ensure 'Anti-aliasing' on the Quality Setting your are using is set to 'none', or HDR will be silently disabled on your camera (ಠ_ಠ THANKS UNITY ಠ_ಠ).
14. Go to Window->Alloy->Light Migrator and wait for it to finish updating your scene's existing lights.
15. Now save your scene.

## Advanced Setup
To use the Skin, SpeedTree, and/or Transmission shaders in deferred mode, you MUST do the following:

1. Open Edit->Project Settings->Graphics.
2. Set the 'Deferred' setting to 'Custom shader'.
3. Open the picker below, and select either the 'Alloy Deferred Skin' or 'Alloy Deferred Transmission' shader based on your performance requirements.
   * 'Alloy Deferred Transmission' covers the SpeedTree and Transmission shaders.
   * 'Alloy Deferred Skin' covers the Skin, SpeedTree, and Transmission shaders.
4. Go to the "Hierarchy" tab, and select your camera.
5. Add the component "Alloy/Alloy Effects Manager".
6. Add or remove the "Skin Scattering" and/or "Transmission" tabs to reduce cost.
7. Set your materials to the "Alloy/Human/Skin" or "Alloy/Transmission/*" shaders.

## Documentation
1. Go to Window->Alloy->Documentation.
2. Change windows to the newly opened browser tab.

Now you're ready to play!
