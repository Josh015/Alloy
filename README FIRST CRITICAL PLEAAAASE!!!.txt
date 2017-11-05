Greetings!
Welcome to the Alloy Shader Framework Readme

First off, you will notice this package has two packages within it. 
One of these contains the shaders and supporting editor extensions. 
The other contains sample textures, assets, materials and a scene.

DO NOT IMPORT THE SHADER PACKAGE OVER AN OLDER VERSION OF ALLOY!!!
We have had to make significant structural changes to Alloy for this update,
so it simply isn't compatible with older versions. 
You MUST clear your current copy of Alloy out of your project first.
Once you have done this, import the shader package first.
This will take 30-60 mins based on your cpu speed (thanks multicompile...)
After this, you can import the sample assets package (which should import far more speedily).

Usage Instructions:

Before using this shader set, there are a couple things you _must_ set up in your project. 
If you do not set up these options, you will get visual artifacts caused by broken math.

Setup Steps:

1. Open Edit->Project Settings->Player
2. Open the 'Other Settings' rollout
3. Set 'Color Space' to 'Linear'
4. If you want to use lots of dynamic lights, set 'Rendering Path' to 'Deferred Lighting'
5. Select your camera in your scene
6. Check the 'HDR' box
!!!SUPER IMPORTANT STEP!!!
7. Now save a scene, and CLOSE UNITY COMPLETELY
-This is necessary for the overwritten deferred shader to 'kick in' for the project.-
8. Open Unity and your project back up.
Now you're ready to play!

See the Alloy Documentation PDF for full usage details.

