// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Alloy {
    [CustomEditor(typeof (PackedMapDefinition))]
    public class PackedMapDefintionEdtior : Editor {
        public override void OnInspectorGUI() {
            serializedObject.Update();
            
            EditorGUILayout.PropertyField(serializedObject.FindProperty("Title"));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("Suffix"));
            EditorGUILayout.PropertyField(serializedObject.FindProperty("ImportSettings"), true);

            GUILayout.Space(20.0f);

            var map = target as PackedMapDefinition;
            var channels = serializedObject.FindProperty("Channels");

            //int rI = 0, gI = 0, bI = 0, aI = 0;
            int rO = 0, gO = 0, bO = 0, aO = 0;

            int del = -1;

            for (int i = 0; i < channels.arraySize; i++) {
                var ser = channels.GetArrayElementAtIndex(i);
                var channel = map.Channels[i];
                var outputs = channel.OutputChannels;

                if (GUILayout.Button("", "OL Minus")) {
                    del = i;
                }

                EditorGUILayout.PropertyField(ser.FindPropertyRelative("Title"));
                EditorGUILayout.PropertyField(ser.FindPropertyRelative("HelpText"));
                EditorGUILayout.PropertyField(ser.FindPropertyRelative("BackgroundColor"));

                if (!channel.RoughnessCorrect) {
                    EditorGUILayout.PropertyField(ser.FindPropertyRelative("OutputVariance"));
                }

                if (!channel.OutputVariance) {
                    EditorGUILayout.PropertyField(ser.FindPropertyRelative("RoughnessCorrect"));
                }

                EditorGUILayout.PropertyField(ser.FindPropertyRelative("HideChannel"));

                EditorGUILayout.PropertyField(ser.FindPropertyRelative("CanInvert"));

                if (channel.CanInvert) {
                    EditorGUILayout.PropertyField(ser.FindPropertyRelative("InvertByDefault"));
                }

                EditorGUILayout.PropertyField(ser.FindPropertyRelative("InputChannels"));
                EditorGUILayout.PropertyField(ser.FindPropertyRelative("OutputChannels"));

                EditorGUILayout.PropertyField(ser.FindPropertyRelative("DefaultMode"));

                if (outputs.HasFlag(MapChannel.R)) {
                    rO++;
                }

                if (outputs.HasFlag(MapChannel.G)) {
                    gO++;
                }

                if (outputs.HasFlag(MapChannel.B)) {
                    bO++;
                }

                if (outputs.HasFlag(MapChannel.A)) {
                    aO++;
                }
            }

            if (rO == 0 || gO == 0 || bO == 0 || aO == 0) {
                EditorGUILayout.HelpBox("Missing output channel!", MessageType.Error);
            }

            if (rO > 1 || gO > 1 || bO > 1 || aO > 1) {
                EditorGUILayout.HelpBox("Output channel is doubly written!", MessageType.Error);
            }

            if (del != -1) {
                channels.DeleteArrayElementAtIndex(del);
            }

            if (GUILayout.Button("", "OL Plus")) {
                channels.InsertArrayElementAtIndex(channels.arraySize);
            }
            
            GUILayout.Space(10.0f);

            if (map.Channels.Any(channel => channel.UseNormals)) {
                GUILayout.Label("Packed map uses normals");
            }

            serializedObject.ApplyModifiedProperties();
        }
    }
}