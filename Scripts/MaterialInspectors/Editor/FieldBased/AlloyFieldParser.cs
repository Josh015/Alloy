// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using UnityEditor.AnimatedValues;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using Alloy;
using UnityEditor;


//Generates drawers for a certain field
public abstract class AlloyFieldParser {
	protected List<AlloyToken> Tokens;

	public bool HasSettings;
	public string DisplayName;

	protected MaterialProperty MaterialProperty;
	protected AlloyArgumentToken[] Arguments;

	protected AlloyFieldParser(MaterialProperty prop) {
		var lexer = new AlloyFieldLexer();
		Tokens = lexer.GenerateTokens(prop.displayName);

		if (Tokens.Count == 0) {
			Debug.LogError("No tokens found!");
			return;
		}

		MaterialProperty = prop;
		DisplayName = Tokens[0].Token;

		if (Tokens.Count <= 1) {
			return;
		}

		var settingsToken = Tokens[1] as AlloyCollectionToken;
		if (settingsToken == null) {
			return;
		}

		HasSettings = true;
		Arguments = settingsToken.SubTokens.OfType<AlloyArgumentToken>().ToArray();
	}

	public AlloyFieldDrawer GetDrawer(AlloyInspectorBase editor) {
		if (!HasSettings) {
			return null;
		}

		var drawer = GenerateDrawer(editor);
		if (drawer != null) {
			drawer.DisplayName = DisplayName;
		}

		return drawer;
	}

	protected abstract AlloyFieldDrawer GenerateDrawer(AlloyInspectorBase editor);
}

public class AlloyFieldDrawerArgs {
	public AlloyFieldBasedEditor Editor;
	public AlloyTabGroup TabGroup;
	public Material[] Materials;
	public MaterialProperty[] Properties;
	public List<string> PropertiesSkip = new List<string>();
	public string CurrentTab;
	public int MatInst;
	public bool DoDraw = true;
	public List<AlloyTabAdd> TabsToAdd = new List<AlloyTabAdd>();
	public string[] AllTabNames;
	public Dictionary<string, AnimBool> OpenCloseAnim;

	public MaterialProperty GetMaterialProperty(string velName) {
		return Properties.FirstOrDefault(p => p.name == velName);
	}
}

public class AlloyTabAdd {
    public string Name;
    public Color Color;

    public GenericMenu.MenuFunction Enable;
}

public abstract class AlloyFieldDrawer {
	public MaterialProperty Property;
    public int Index;

	public string DisplayName;
	public abstract void Draw(AlloyFieldDrawerArgs args);

	protected MaterialEditor MatEditor;

	protected void BeginMaterialProperty(MaterialProperty property) {
		MatEditor.BeginAnimatedCheck(Property);
		EditorGUI.BeginChangeCheck();
		EditorGUI.showMixedValue = Property.hasMixedValue;
	}

	protected bool EndMaterialProperty() {
		bool change = EditorGUI.EndChangeCheck();
		MatEditor.EndAnimatedCheck();
		EditorGUI.showMixedValue = false;
		return change;
	}

	public AlloyFieldDrawer(AlloyInspectorBase editor, MaterialProperty property) {
		Property = property;
		MatEditor = editor.MatEditor;
	}

	protected void FloatFieldMin(string displayName, float min) {
		BeginMaterialProperty(Property);
		float newVal = EditorGUILayout.FloatField(displayName, Property.floatValue);

		if (EndMaterialProperty()) {
			Property.floatValue = Mathf.Max(newVal, min);
		}
	}

	protected void FloatFieldMax(string displayName, float max) {
		BeginMaterialProperty(Property);
		float newVal = EditorGUILayout.FloatField(displayName, Property.floatValue);

		if (EndMaterialProperty()) {
			Property.floatValue = Mathf.Min(newVal, max);
		}
	}

	protected void FloatFieldSlider(string displayName, float min, float max) {
		BeginMaterialProperty(Property);
		float newVal = EditorGUILayout.Slider(displayName, Property.floatValue, min, max, GUILayout.MinWidth(20.0f));

		if (EndMaterialProperty()) {
			Property.floatValue = Mathf.Clamp(newVal, min, max);
		}
	}

	public void PropField(string displayName) {
		MatEditor.ShaderProperty(Property, displayName);
	}

	public virtual bool ShouldDraw(AlloyFieldDrawerArgs args) {
		return args.DoDraw && !args.PropertiesSkip.Contains(Property.name);
	}

	public virtual void OnSceneGUI(Material[] materials) {
	}

	public virtual void OnDisable() {
	}
}