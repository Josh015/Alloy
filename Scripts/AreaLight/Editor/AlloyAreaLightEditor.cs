using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(AlloyAreaLight))]
[CanEditMultipleObjects]
public class AlloyAreaLightEditor : Editor {
    public override void OnInspectorGUI() {
        serializedObject.Update();

        var hasSpecularHightlight = serializedObject.FindProperty("m_hasSpecularHightlight");
        var maxRange = float.MaxValue;
        var isSpecularAreaLight = false;
        var isPointLight = false;

        // Light Type.
        foreach (AlloyAreaLight area in targets) {
            var light = area.GetComponent<Light>();

	        if (light.type == LightType.Directional) {
		        maxRange = 1.0f;
	        }
	        else {
		        maxRange = Mathf.Min(light.range, maxRange);
	        }

	        isPointLight = light.type == LightType.Point;

            if (isPointLight 
                || light.type == LightType.Spot  
                || light.type == LightType.Directional) {
                isSpecularAreaLight = true;
            }
        }

        // Specular Highlight.
        if (isSpecularAreaLight) {
            hasSpecularHightlight.boolValue = EditorGUILayout.Toggle("Specular Highlight", hasSpecularHightlight.boolValue);
            isSpecularAreaLight = isSpecularAreaLight && hasSpecularHightlight.boolValue;
        }

        // Radius.
        if (isSpecularAreaLight) {
            EditorGUILayout.Slider(serializedObject.FindProperty("m_radius"), 0.0f, maxRange);
        } else {
            var radius = serializedObject.FindProperty("m_radius");

            if (radius.floatValue != 0.0f) {
                GUI.changed = true;
                radius.floatValue = 0.0f;
            }
        }

        // Length.
        if (isSpecularAreaLight && isPointLight) {
            EditorGUILayout.Slider(serializedObject.FindProperty("m_length"), 0.0f, maxRange * 2.0f);
        } else { 
            var length = serializedObject.FindProperty("m_length");

            if (length.floatValue != 0.0f) {
                GUI.changed = true;
                length.floatValue = 0.0f;
            }
        }
        
        serializedObject.ApplyModifiedProperties();

        if (GUI.changed) {
            foreach (AlloyAreaLight area in targets) {
                area.UpdateBinding();
            }
        }
    }

    internal static void DrawTwoShadedWireDisc(Vector3 position, Vector3 axis, float radius) {
        Color color1 = Handles.color;
        Color color2 = color1;

        color1.a *= 0.2f;
        Handles.color = color1;
        Handles.DrawWireDisc(position, axis, radius);
        Handles.color = color2;
    }

    internal static void DrawTwoShadedWireDisc(Vector3 position, Vector3 axis, Vector3 from, float degrees, float radius) {
        Handles.DrawWireArc(position, axis, from, degrees, radius);

        Color cur = Handles.color;
        Color set = cur;

        set.a *= 0.2f;
        Handles.color = set;
        Handles.DrawWireArc(position, axis, from, degrees - 360f, radius);
        Handles.color = cur;
    }

    static Vector3[] s_directionArray = {
        Vector3.right,
        Vector3.up,
        Vector3.forward,
        -Vector3.right,
        -Vector3.up,
        -Vector3.forward
    };

    static void DoRadiusHandle(Vector3 position, float radius, float length) {
        Vector3 dif = position - Camera.current.transform.position;
        float sqrMagnitude = dif.sqrMagnitude;
        float radiusSqr = radius * radius;
        float radiusDiv = radiusSqr * radiusSqr / sqrMagnitude;
        //float ratio = radiusDiv / radiusSqr;
        float total = Mathf.Sqrt(radiusSqr - radiusDiv);

        Handles.DrawWireDisc(position - radiusSqr * dif / sqrMagnitude, dif, total);

        for (int j = 0; j < 3; j++) {
            float angle = Vector3.Angle(dif, s_directionArray[j]);

            angle = 90f - Mathf.Min(angle, 180f - angle);

            float tanAngle = Mathf.Tan(angle * Mathf.Deg2Rad);
            float viewSize = Mathf.Sqrt(radiusDiv + tanAngle * tanAngle * radiusDiv) / radius;

            if (viewSize < 1f) {
                float finalArcAngle = Mathf.Asin(viewSize) * Mathf.Rad2Deg;
                Vector3 vector2 = Vector3.Cross(s_directionArray[j], dif).normalized;
                vector2 = Quaternion.AngleAxis(finalArcAngle, s_directionArray[j]) * vector2;
                DrawTwoShadedWireDisc(position, s_directionArray[j], vector2, (90f - finalArcAngle) * 2f, radius);
            }
            else {
                DrawTwoShadedWireDisc(position, s_directionArray[j], radius);
            }
        }
    }

    float DrawCapsuleGizmo(Transform transform, float radius, float length) {
        var fwd = Vector3.forward * radius;
        var side = Vector3.up * radius;
        var halfLength = 0.5f * length;

        // Exclude light transform scale, and pre-rotate capsule to follow the Y-axis.
        Handles.matrix = Matrix4x4.TRS(transform.position, transform.rotation, Vector3.one)
                    * Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(0.0f, 0.0f, 90.0f), Vector3.one);

        Handles.DrawWireArc(-halfLength * Vector3.right, Vector3.forward, Vector3.up, 180.0f, radius);
        Handles.DrawWireArc(-halfLength * Vector3.right, Vector3.up, -Vector3.forward, 180.0f, radius);

        Handles.DrawWireArc(halfLength * Vector3.right, Vector3.forward, -Vector3.up, 180.0f, radius);
        Handles.DrawWireArc(halfLength * Vector3.right, Vector3.up, Vector3.forward, 180.0f, radius);

        Handles.DrawWireDisc(-halfLength * Vector3.right, Vector3.right, radius);
        Handles.DrawWireDisc(halfLength * Vector3.right, Vector3.right, radius);

        Handles.DrawLine(-halfLength * Vector3.right + fwd, halfLength * Vector3.right + fwd);
        Handles.DrawLine(-halfLength * Vector3.right - fwd, halfLength * Vector3.right - fwd);

        Handles.DrawLine(-halfLength * Vector3.right + side, halfLength * Vector3.right + side);
        Handles.DrawLine(-halfLength * Vector3.right - side, halfLength * Vector3.right - side);

        if (!Event.current.alt && !Event.current.shift) {
            radius = Handles.RadiusHandle(Quaternion.identity, -halfLength * Vector3.right, radius, true);
            radius = Handles.RadiusHandle(Quaternion.identity, halfLength * Vector3.right, radius, true);
        }

        Handles.matrix = Matrix4x4.identity;

        return radius;
    }

    void OnSceneGUI() {
        var area = target as AlloyAreaLight;
        var light = area.GetComponent<Light>();

        if (light.type == LightType.Point
            || light.type == LightType.Spot) {
            area.Radius = DrawCapsuleGizmo(area.transform, area.Radius, area.Length);
        }

        //DoRadiusHandle(area.transform.position, area.Size, 1.0f);

        if (GUI.changed) {
            Undo.RecordObject(area, "Adjust area light");
        }
    }
}