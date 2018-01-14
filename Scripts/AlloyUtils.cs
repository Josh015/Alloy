using UnityEngine;

public static class AlloyUtils {
    public const string Name = "Alloy";
    public const string Version = "4.3.0";
    public const float SectionColorMax = 20.0f;

    public const string Path = Name + "/";
    public const string MenuItem = "Window/" + Path;
    public const string ComponentMenu = Path + Name + " ";

    public static string AssetsPath {
        get { return Application.dataPath + "/" + Path; }
    }

    //public static float IntensityToLumens(float intensity) {
    //    return Mathf.Floor(Mathf.GammaToLinearSpace(intensity) * 100.0f);
    //}

    //public static float LumensToIntensity(float lumens) {
    //    return Mathf.LinearToGammaSpace(lumens / 100.0f);
    //}
}
