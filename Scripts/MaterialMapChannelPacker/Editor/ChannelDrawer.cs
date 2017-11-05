// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEditor;
using UnityEngine;

namespace Alloy {
	[CustomPropertyDrawer(typeof(EnumFlagsAttribute))]
	public class ChannelDrawer : PropertyDrawer {
		public override void OnGUI(Rect position, SerializedProperty property, GUIContent label) {
			EditorGUI.BeginProperty(position, label, property);

			EditorGUI.BeginChangeCheck();
			int index = EditorGUI.MaskField(position, label, property.intValue, property.enumDisplayNames);

			if (EditorGUI.EndChangeCheck()) {
				property.intValue = index;
			}

			EditorGUI.EndProperty();
		}
	}
}