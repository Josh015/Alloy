using UnityEditor;
using UnityEngine;

[CustomPropertyDrawer(typeof(AlloyMinValueAttribute))]
public class MinValueDrawer : PropertyDrawer {
    // Draw the property inside the given rect
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label) {
        // Using BeginProperty / EndProperty on the parent property means that
        // prefab override logic works on the entire property.
        EditorGUI.BeginProperty(position, label, property);

        // Draw label
        EditorGUI.BeginChangeCheck();

        float newVal = EditorGUI.FloatField(position, label, property.floatValue);
        
        if (EditorGUI.EndChangeCheck()) {
            newVal = Mathf.Max((attribute as AlloyMinValueAttribute).Min, newVal);
            property.floatValue = newVal;
        }

        EditorGUI.EndProperty();
    }
}

[CustomPropertyDrawer(typeof(AlloyMaxValueAttribute))]
public class MaxValueDrawer : PropertyDrawer {
    // Draw the property inside the given rect
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label) {
        // Using BeginProperty / EndProperty on the parent property means that
        // prefab override logic works on the entire property.
        EditorGUI.BeginProperty(position, label, property);

        // Draw label

        EditorGUI.BeginChangeCheck();

        float newVal = EditorGUI.FloatField(position, label, property.floatValue);

        if (EditorGUI.EndChangeCheck()) {
            newVal = Mathf.Min((attribute as AlloyMaxValueAttribute).Max, newVal);
            property.floatValue = newVal;
        }
        EditorGUI.EndProperty();
    }
}