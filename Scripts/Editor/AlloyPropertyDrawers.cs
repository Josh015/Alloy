// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEditor;
using UnityEngine;


[CustomPropertyDrawer(typeof(MinValueAttribute))]
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
            newVal = Mathf.Max((attribute as MinValueAttribute).Min, newVal);
            property.floatValue = newVal;
        }

        EditorGUI.EndProperty();
    }
}

[CustomPropertyDrawer(typeof(MaxValueAttribute))]
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
            newVal = Mathf.Min((attribute as MaxValueAttribute).Max, newVal);
            property.floatValue = newVal;
        }
        EditorGUI.EndProperty();
    }
}