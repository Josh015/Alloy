// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEngine;
using System.Collections.Generic;
using UnityEditor;

public static class AlloyEditor {
    public static void DrawAddTabGUI(List<AlloyTabAdd> tabsToAdd) {
        if (tabsToAdd.Count <= 0) {
            return;
        }
        
        GUI.color = new Color(0.8f, 0.8f, 0.8f, 0.8f);
        GUILayout.Label("");
        var rect = GUILayoutUtility.GetLastRect();

        rect.x -= 35.0f;
        rect.width += 10.0f;

        GUI.color = Color.clear;
        bool add = GUI.Button(rect, new GUIContent(""), "Box");
        GUI.color = new Color(0.8f, 0.8f, 0.8f, 0.8f);
        Rect subRect = rect;

        foreach (var tab in tabsToAdd) {
            GUI.color = tab.Color;
            GUI.Box(subRect, "", "ShurikenModuleTitle");

            subRect.x += rect.width / tabsToAdd.Count;
            subRect.width -= rect.width / tabsToAdd.Count;
        }

        GUI.color = new Color(0.8f, 0.8f, 0.8f, 0.8f);

        var delRect = rect;
        delRect.xMin = rect.xMax;
        delRect.xMax += 40.0f;

        if (GUI.Button(delRect, "", "ShurikenModuleTitle") || add) {
            var menu = new GenericMenu();

            foreach (var tab in tabsToAdd) {
                menu.AddItem(new GUIContent(tab.Name), false, tab.Enable);
            }

            menu.ShowAsContext();
        }

        delRect.x += 10.0f;

        GUI.Label(delRect, "+");
        rect.x += EditorGUIUtility.currentViewWidth / 2.0f - 30.0f;

        // Ensures tab text is always white, even when using light skin in pro.
        GUI.color = EditorGUIUtility.isProSkin ? new Color(0.7f, 0.7f, 0.7f) : new Color(0.9f, 0.9f, 0.9f);
        GUI.Label(rect, "Add tab", EditorStyles.whiteLabel);
        GUI.color = Color.white;
    }
}
