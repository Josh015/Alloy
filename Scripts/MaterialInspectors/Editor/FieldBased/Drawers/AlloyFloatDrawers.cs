// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System;
using System.Text.RegularExpressions;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;

public class AlloyDropdownOption {
    public string Name;
    public string[] HideFields;
}

public class AlloyFloatParser : AlloyFieldParser {
    private readonly Color32 c_defaultSectionColor = new Color32(97, 97, 97, 255);

    protected override AlloyFieldDrawer GenerateDrawer(AlloyInspectorBase editor) {
        AlloyFieldDrawer retDrawer = null;

        foreach (var token in Arguments) {
            var argName = token.ArgumentName;
            var argToken = token.ArgumentToken;

            switch (argName) {
                case "Min":
                    AlloyFloatDrawer minDrawer = null;
                    var minValToken = argToken as AlloyValueToken;
                        
                    if (retDrawer != null)
                        minDrawer = retDrawer as AlloyFloatDrawer;
                        
                    if (minDrawer == null)
                        minDrawer = new AlloyFloatDrawer(editor, MaterialProperty);

                    minDrawer.HasMin = true;
                    minDrawer.MinValue = minValToken.FloatValue;
                    retDrawer = minDrawer;
                    break;

                case "Max":
                    AlloyFloatDrawer maxDrawer = null;
                    var maxValToken = argToken as AlloyValueToken;
                    
                    if (retDrawer != null)
                        maxDrawer = retDrawer as AlloyFloatDrawer;

                    if (maxDrawer == null)
                        maxDrawer = new AlloyFloatDrawer(editor, MaterialProperty);

                    maxDrawer.HasMax = true;
                    maxDrawer.MaxValue = maxValToken.FloatValue;
                    retDrawer = maxDrawer;
                    break;

                case "Section":
                    retDrawer = new AlloySectionDrawer(editor, MaterialProperty);
                    SetSectionOption(retDrawer, argToken);
                    break;

                case "Feature":
                    retDrawer = new AlloyFeatureDrawer(editor, MaterialProperty);
                    SetSectionOption(retDrawer, argToken);
                    break;

                case "Toggle":
                    retDrawer = new AlloyToggleDrawer(editor, MaterialProperty);
                    SetToggleOption(retDrawer, argToken);
                    break;
                    
                case "SpeedTreeGeometryType":
                    retDrawer = new AlloySpeedTreeGeometryTypeDrawer(editor, MaterialProperty);
                    SetDropdownOption(retDrawer, argToken);
                    break;

                case "RenderingMode":
                    retDrawer = new AlloyRenderingModeDrawer(editor, MaterialProperty);
                    SetDropdownOption(retDrawer, argToken);
                    break;

                case "Dropdown":
                    retDrawer = new AlloyDropdownDrawer(editor, MaterialProperty);
                    SetDropdownOption(retDrawer, argToken);
                    break;

                case "LightmapEmissionProperty":
                    retDrawer = new AlloyLightmapEmissionDrawer(editor, MaterialProperty);
                    break;

                case "RenderQueue":
                    retDrawer = new AlloyRenderQueueDrawer(editor, MaterialProperty);
                    break;

                case "EnableInstancing":
                    retDrawer = new AlloyEnableInstancingDrawer(editor, MaterialProperty);
                    break;
            }
        }

        if (retDrawer == null)
            retDrawer = new AlloyFloatDrawer(editor, MaterialProperty);

        return retDrawer;
    }

    private static void SetDropdownOption(AlloyFieldDrawer retDrawer, AlloyToken argToken) {
        var drawer = retDrawer as AlloyDropdownDrawer;

        if (drawer == null) {
            return;
        }

        var options = argToken as AlloyCollectionToken;

        if (options == null) {
            return;
        }

        var dropOptions = new List<AlloyDropdownOption>();

        for (int i = 0; i < options.SubTokens.Count; i++) {
            AlloyArgumentToken arg = (AlloyArgumentToken)options.SubTokens[i];
            var collection = arg.ArgumentToken as AlloyCollectionToken;

            if (collection == null) {
                continue;
            }
            

            // Split PascalCase name into words separated by spaces while skipping acronyms.
            var dropOption = new AlloyDropdownOption {
                Name = Regex.Replace(arg.ArgumentName, @"(?<=[A-Za-z])(?=[A-Z][a-z])|(?<=[a-z0-9])(?=[0-9]?[A-Z])", " "),
                HideFields = collection.SubTokens.Select(alloyToken => alloyToken.Token).ToArray()
            };
            dropOptions.Add(dropOption);
        }

        drawer.DropOptions = dropOptions.ToArray();
    }

    private static void SetToggleOption(AlloyFieldDrawer retDrawer, AlloyToken argToken) {
        var drawer = retDrawer as AlloyToggleDrawer;

        if (drawer == null) {
            return;
        }
        var collectionToken = argToken as AlloyCollectionToken;

        if (collectionToken == null) {
            return;
        }
        foreach (var token in collectionToken.SubTokens) {
            var arg = token as AlloyArgumentToken;

            if (arg != null && arg.ArgumentName == "On") {
                var onToken = arg.ArgumentToken as AlloyCollectionToken;

                if (onToken != null) {
                    drawer.OnHideFields = onToken.SubTokens.Select(colToken => colToken.Token).ToArray();
                }
            }
            else if (arg != null && arg.ArgumentName == "Off") {
                var offToken = arg.ArgumentToken as AlloyCollectionToken;

                if (offToken != null) {
                    drawer.OffHideFields = offToken.SubTokens.Select(colToken => colToken.Token).ToArray();
                }
            }
        }
    }

    private static void SetMinOption(AlloyFieldDrawer retDrawer, AlloyToken argToken) {
        var floatDrawer = retDrawer as AlloyFloatDrawer;
        var minValToken = argToken as AlloyValueToken;

        if (floatDrawer != null) {
            floatDrawer.HasMin = true;

            if (minValToken != null) {
                floatDrawer.MinValue = minValToken.FloatValue;
            }
        }
    }
    
    void SetSectionOption(AlloyFieldDrawer retDrawer, AlloyToken argToken) {
        var sectionDrawer = retDrawer as AlloyTabDrawer;

        if (sectionDrawer != null) {
            var collectionToken = argToken as AlloyCollectionToken;
            
            if (collectionToken == null) {
                sectionDrawer.Color = c_defaultSectionColor;
            }
            else { 
                foreach (var token in collectionToken.SubTokens) {
                    var arg = token as AlloyArgumentToken;

                    if (arg != null && arg.ArgumentName == "Color") {
                        var value = arg.ArgumentToken as AlloyValueToken;

                        // Calculate color from section index and HSV scale factor.
                        if (value != null) {
                            var hueIndex = value.FloatValue;

                            if (hueIndex > -0.1f)
                                sectionDrawer.Color = Color.HSVToRGB((hueIndex / AlloyUtils.SectionColorMax) * 0.6f, 0.75f, 0.5f);
                        }
                        else {
                            // Manually specify color.
                            var colCollection = arg.ArgumentToken as AlloyCollectionToken;

                            if (colCollection != null) {
                                var r = colCollection.SubTokens[0] as AlloyValueToken;
                                var g = colCollection.SubTokens[1] as AlloyValueToken;
                                var b = colCollection.SubTokens[2] as AlloyValueToken;

                                if (r != null && g != null && b != null) {
                                    sectionDrawer.Color = new Color32((byte)r.FloatValue, (byte)g.FloatValue, (byte)b.FloatValue, 255);
                                }
                            }
                        }
                    }
                    else if (arg != null && arg.ArgumentName == "Hide") {
                        var featureDrawer = sectionDrawer as AlloyFeatureDrawer;
                        var offToken = arg.ArgumentToken as AlloyCollectionToken;

                        if (offToken != null) {
                            featureDrawer.HideFields = offToken.SubTokens.Select(colToken => colToken.Token).ToArray();
                        }
                    }
                }
            }
        }
    }

    public AlloyFloatParser(MaterialProperty field)
        : base(field) {
    }
}


public abstract class AlloyTabDrawer : AlloyFieldDrawer
{
    public Color Color;
    Func<bool, Action<Rect>> m_foldoutAction;

    protected void SetAllTabsOpenedTo(bool open, AlloyFieldDrawerArgs args) {
        foreach (var tab in args.AllTabNames) {
            args.TabGroup.SetOpen(tab + args.MatInst, open);
        }
    }

    public override bool ShouldDraw(AlloyFieldDrawerArgs args) {
        return !args.PropertiesSkip.Contains(Property.name);
    }

    protected void DrawNow(AlloyFieldDrawerArgs args, bool optional) {
        var firstDrawer = Index == 0;
        var firstTab = string.IsNullOrEmpty(args.CurrentTab);
        
        if (firstDrawer) {
            GUILayout.Space(-10.0f);
        }
        else if (firstTab) {
            GUILayout.Space(5.0f);
        }
        else {
            if (args.DoDraw) {
                GUILayout.Space(8.0f);
            }

            EditorGUILayout.EndFadeGroup();
        }

        if (!optional || args.Editor.TabIsEnabled(Property)) {
            bool open;

            if (firstTab && !optional) {
                bool openAll = args.AllTabNames.All(tab => args.TabGroup.IsOpen(tab + args.MatInst));
                bool closeOpen;
                bool all = openAll;
                
                open = args.TabGroup.TabArea(DisplayName, Color, true, m_foldoutAction(all), out closeOpen, DisplayName + args.MatInst);

                if (closeOpen) {
                    openAll = !openAll;
                    SetAllTabsOpenedTo(openAll, args);
                }
            }
            else {
                bool removed;
                open = args.TabGroup.TabArea(DisplayName, Color, optional, out removed, DisplayName + args.MatInst);

                if (removed) {
                    args.Editor.DisableTab(DisplayName, Property, args.MatInst);
                }
            }

            var anim = args.OpenCloseAnim[Property.name];
            anim.target = open;

            args.CurrentTab = Property.name;
            args.DoDraw = EditorGUILayout.BeginFadeGroup(anim.faded);
        }
        else {
            args.DoDraw = false;

            args.TabsToAdd.Add(new AlloyTabAdd { Color = Color, Name = DisplayName, Enable = () => args.Editor.EnableTab(DisplayName, Property, args.MatInst) });
        }
    }

    protected AlloyTabDrawer(AlloyInspectorBase editor, MaterialProperty property)
        : base(editor, property) {
        m_foldoutAction = all => r => GUI.Label(r, all ? "v" : ">", EditorStyles.whiteLabel);
    }
}

public class AlloySectionDrawer : AlloyTabDrawer {
    public override void Draw(AlloyFieldDrawerArgs args) {
        DrawNow(args, false);
    }

    public AlloySectionDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
    }
}

public class AlloyFeatureDrawer : AlloyTabDrawer {
    public string[] HideFields;

    public override bool ShouldDraw(AlloyFieldDrawerArgs args) {
        return true;
    }

    public override void Draw(AlloyFieldDrawerArgs args) {
        bool current = Property.floatValue > 0.5f;

        DrawNow(args, true);
        
        if (!current) {
            if (HideFields != null) {
                args.PropertiesSkip.AddRange(HideFields);
            }
        }
    }

    public AlloyFeatureDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
    }
}

public class AlloyFloatDrawer : AlloyFieldDrawer
{
    public bool HasMin;
    public float MinValue;

    public bool HasMax;
    public float MaxValue;

    int m_selectedIndex;

    public override void Draw(AlloyFieldDrawerArgs args) {
        if (HasMin || HasMax) {
            if (HasMin && HasMax) {
                FloatFieldSlider(DisplayName, MinValue, MaxValue);
            }
            else if (HasMin) {
                FloatFieldMin(DisplayName, MinValue);
            }
            else {
                FloatFieldMax(DisplayName, MaxValue);
            }
        }
        else {
            PropField(DisplayName);
        }
    }

    public AlloyFloatDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
    }
}

public class AlloyDropdownDrawer : AlloyFieldDrawer {
    public AlloyDropdownOption[] DropOptions;

    protected virtual bool OnSetOption(int newOption, AlloyFieldDrawerArgs args) {
        return false;
    }

    public override void Draw(AlloyFieldDrawerArgs args) {
		int current = (int)Property.floatValue;
		var label = new GUIContent(DisplayName);

		BeginMaterialProperty(Property);

	    int newVal = EditorGUILayout.Popup(label, current, DropOptions.Select(option => new GUIContent(option.Name)).ToArray());
		EditorGUI.showMixedValue = false;

		if (!OnSetOption(newVal, args) && EditorGUI.EndChangeCheck()) {
			Property.floatValue = newVal;
            MaterialEditor.ApplyMaterialPropertyDrawers(args.Materials);
        }
		
		MatEditor.EndAnimatedCheck();
		args.PropertiesSkip.AddRange(DropOptions[current].HideFields);
	}

	public AlloyDropdownDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
    }
}

public abstract class AlloyBlendModeDropdownDrawer : AlloyDropdownDrawer {
    public struct BlendModeOptionConfig {
        public int Type;
        public string OverrideTag;
        public UnityEngine.Rendering.BlendMode SrcBlend;
        public UnityEngine.Rendering.BlendMode DstBlend;
        public int ZWrite;
        public string Keyword;
        public int RenderQueue;
    }

    protected BlendModeOptionConfig[] BlendModeOptionConfigs = null;

    public AlloyBlendModeDropdownDrawer(AlloyInspectorBase editor, MaterialProperty property, BlendModeOptionConfig[] blendModeOptionConfigs) : base(editor, property) {
        BlendModeOptionConfigs = blendModeOptionConfigs;

        // Get default from keyword.
        var keywords = editor.Target.shaderKeywords;
        property.floatValue = 0.0f;

        foreach (var setting in BlendModeOptionConfigs) {
            if (keywords.Contains(setting.Keyword)) {
                property.floatValue = setting.Type;
                break;
            }
        }
    }

    protected override bool OnSetOption(int newOption, AlloyFieldDrawerArgs args) {
        base.OnSetOption(newOption, args);

        foreach (var material in args.Materials) {
            if (Property.floatValue != newOption) {
                foreach (var setting in BlendModeOptionConfigs) {
                    var keyword = setting.Keyword;

                    if (newOption != setting.Type) {
                        material.DisableKeyword(keyword);
                    }
                    else {
                        material.SetOverrideTag("RenderType", setting.OverrideTag);
                        material.SetInt("_SrcBlend", (int)setting.SrcBlend);
                        material.SetInt("_DstBlend", (int)setting.DstBlend);
                        material.SetInt("_ZWrite", setting.ZWrite);
                        material.EnableKeyword(keyword);
                        material.renderQueue = setting.RenderQueue;
                    }
                }

                material.SetInt(Property.name, newOption);
                EditorUtility.SetDirty(material);
            }
        }

        Undo.RecordObjects(args.Materials, "set " + Property.name);
        return true;
    }
}

public class AlloyToggleDrawer : AlloyFieldDrawer {
    public string[] OnHideFields;
    public string[] OffHideFields;

    public override void Draw(AlloyFieldDrawerArgs args) {
        bool current = Property.floatValue > 0.5f;
        var label = new GUIContent(DisplayName);
		

		//EditorGUI.BeginProperty(new Rect(), label, Serialized);

	    EditorGUI.showMixedValue = Property.hasMixedValue;

		EditorGUI.BeginChangeCheck();
        current = EditorGUILayout.Toggle(label, current);

        if (EditorGUI.EndChangeCheck()) {
            Property.floatValue = current ? 1.0f : 0.0f;
            MaterialEditor.ApplyMaterialPropertyDrawers(args.Materials);
        }
		
		//EditorGUI.EndProperty();

	    EditorGUI.showMixedValue = false;


		if (!current) {
            if (OffHideFields != null) {
                args.PropertiesSkip.AddRange(OffHideFields);
            }
        } else {
            if (OnHideFields != null) {
                args.PropertiesSkip.AddRange(OnHideFields);
            }
        }
    }

    public AlloyToggleDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
    }
}