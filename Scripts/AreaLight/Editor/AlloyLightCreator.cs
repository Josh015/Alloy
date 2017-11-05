using UnityEditor;
using UnityEngine;

public static class AlloyLightCreator {
    const string c_lightMenuPath = "GameObject/Light/";
    const string c_undoMessage = "Created ";
    const string c_directionalLight = "Alloy Directional Light";
    const string c_pointLight = "Alloy Point Light";
    const string c_spotLight = "Alloy Spotlight";

    [MenuItem(c_lightMenuPath + c_directionalLight)]
	static void CreateDirectionalLight() {
        BuildLight(c_directionalLight, LightType.Directional);
	}
    
	[MenuItem(c_lightMenuPath + c_pointLight)]
	static void CreateSphereAreaLight() {
        BuildLight(c_pointLight, LightType.Point);
	}

	[MenuItem(c_lightMenuPath + c_spotLight)]
	static void CreateSpotSphereAreaLight() {
        BuildLight(c_spotLight, LightType.Spot);
	}

    static void BuildLight(string name, LightType type) {
        var go = new GameObject();
        var lastSceneView = SceneView.lastActiveSceneView;

        Undo.RegisterCreatedObjectUndo(go, c_undoMessage + name);
        go.name = name;

        var light = go.AddComponent<Light>();
        light.type = type;

        go.AddComponent<AlloyAreaLight>();

        if (lastSceneView != null)
            go.transform.position = lastSceneView.pivot;
        else
            go.transform.position = Vector3.zero;

        Selection.activeGameObject = go;
    }
}