// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using Alloy;
using UnityEditor;
using UnityEditor.AnimatedValues;
using UnityEngine;
using UnityEngine.UI;

public class AlloyVectorParser : AlloyFieldParser {
	protected override AlloyFieldDrawer GenerateDrawer(AlloyInspectorBase editor) {
		AlloyFieldDrawer ret = null;

		for (int i = 0; i < Arguments.Length; i++) {
			var argument = Arguments[i];
			var valProp = argument.ArgumentToken as AlloyValueToken;

			switch (argument.ArgumentName) {
				case "Vector":

					if (valProp != null) {
						ret = SetupVectorDrawer(editor, valProp, ret);
					}
					break;
			}
		}

		if (ret == null) {
			ret = new AlloyVectorDrawer(editor, MaterialProperty);
			((AlloyVectorDrawer) ret).Mode = AlloyVectorDrawer.VectorMode.Vector4;
		}


		return ret;
	}

	AlloyFieldDrawer SetupVectorDrawer(AlloyInspectorBase editor,
		AlloyValueToken valProp,
		AlloyFieldDrawer ret) {
		if (valProp.ValueType == AlloyValueToken.ValueTypeEnum.String) {
			switch (valProp.StringValue) {
				case "Euler":
					ret = new AlloyVectorDrawer(editor, MaterialProperty);
					((AlloyVectorDrawer) ret).Mode = AlloyVectorDrawer.VectorMode.Euler;
					break;

				case "TexCoord":
					ret = new AlloyTexCoordDrawer(editor, MaterialProperty);
					break;

				case "Channels":
					ret = new AlloyMaskDrawer(editor, MaterialProperty);
					break;

				default:
					Debug.LogError("Non supported vector property!");
					break;
			}
		}
		else if (valProp.ValueType == AlloyValueToken.ValueTypeEnum.Float) {
			switch ((int) valProp.FloatValue) {
				case 2:
					ret = new AlloyVectorDrawer(editor, MaterialProperty);
					((AlloyVectorDrawer) ret).Mode = AlloyVectorDrawer.VectorMode.Vector2;
					break;

				case 3:
					ret = new AlloyVectorDrawer(editor, MaterialProperty);
					((AlloyVectorDrawer) ret).Mode = AlloyVectorDrawer.VectorMode.Vector3;
					break;

				case 4:
					ret = new AlloyVectorDrawer(editor, MaterialProperty);
					((AlloyVectorDrawer) ret).Mode = AlloyVectorDrawer.VectorMode.Vector4;
					break;

				default:
					Debug.LogError("Non supported vector property!");
					break;
			}
		}
		return ret;
	}

	public AlloyVectorParser(MaterialProperty field)
		: base(field) {
	}
}

public class AlloyVectorDrawer : AlloyFieldDrawer {
	public enum VectorMode {
		Vector2,
		Vector3,
		Vector4,
		Euler
	}

	public VectorMode Mode = VectorMode.Vector4;

	public override void Draw(AlloyFieldDrawerArgs args) {
		Vector4 newVal = Vector4.zero;
		var label = new GUIContent(DisplayName);

		BeginMaterialProperty(Property);

		switch (Mode) {
			case VectorMode.Vector4:
				newVal = EditorGUILayout.Vector4Field(label.text, Property.vectorValue);
				break;

			case VectorMode.Vector3:
				newVal = EditorGUILayout.Vector3Field(label.text, Property.vectorValue);
				break;

			case VectorMode.Vector2:
				newVal = EditorGUILayout.Vector2Field(label.text, Property.vectorValue);
				break;

			case VectorMode.Euler:
				var value = args.GetMaterialProperty(Property.name + "EulerUI").vectorValue;
				//var value = (Vector4)args.Editor.GetProperty(MaterialProperty.PropType.Vector, Property.name + "EulerUI").colorValue;
				newVal = Quaternion.Euler(value) * Vector3.up;
				GUI.changed = true;
				break;
		}

		if (EndMaterialProperty()) {
			Property.vectorValue = newVal;
		}
	}

	public AlloyVectorDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
	}
}

public class AlloyTexCoordDrawer : AlloyTextureFieldDrawer {
    AnimBool m_tabOpen = new AnimBool(false);

	public AlloyTexCoordDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
	}

	public override void Draw(AlloyFieldDrawerArgs args) {
        TexInst = args.MatInst;

        bool isOpen = TabGroup.Foldout(DisplayName, SaveName, GUILayout.Width(10.0f));
        m_tabOpen.target = isOpen;

        if (m_tabOpen.value) {
            EditorGUILayout.BeginFadeGroup(m_tabOpen.faded);
            DrawTextureControls(args);
            EditorGUILayout.EndFadeGroup();
        }

        if (m_tabOpen.isAnimating) {
            args.Editor.MatEditor.Repaint();
        }
    }
}

public class AlloyMaskDrawer : AlloyFieldDrawer {
	public AlloyMaskDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
	}

	public override void Draw(AlloyFieldDrawerArgs args) {
		Vector4 newVal = Property.vectorValue;
		var label = new GUIContent(DisplayName);

		BeginMaterialProperty(Property);

		GUILayout.BeginHorizontal();
		GUILayout.Label(label);

		newVal.x = GUILayout.Toggle(newVal.x > 0.5f, "R", EditorStyles.toolbarButton) ? 1.0f : 0.0f;
		newVal.y = GUILayout.Toggle(newVal.y > 0.5f, "G", EditorStyles.toolbarButton) ? 1.0f : 0.0f;
		newVal.z = GUILayout.Toggle(newVal.z > 0.5f, "B", EditorStyles.toolbarButton) ? 1.0f : 0.0f;
		newVal.w = GUILayout.Toggle(newVal.w > 0.5f, "A", EditorStyles.toolbarButton) ? 1.0f : 0.0f;
		GUILayout.EndHorizontal();

		if (EndMaterialProperty()) {
			Property.vectorValue = newVal;
		}
	}
}