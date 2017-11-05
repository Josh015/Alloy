// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/


using UnityEditor;
using UnityEngine;

public static class AlloyFieldDrawerFactory {
    private static AlloyFieldParser GetFieldParser(MaterialProperty prop) {

        switch (prop.type) {
            case MaterialProperty.PropType.Texture:
                if (prop.textureDimension == UnityEngine.Rendering.TextureDimension.Cube) {
                    return new AlloyCubeParser(prop);
                }

                return new AlloyTextureParser(prop);

            case MaterialProperty.PropType.Range:
            case MaterialProperty.PropType.Float:
                return new AlloyFloatParser(prop);

            case MaterialProperty.PropType.Color:
                return new AlloyColorParser(prop);

            case MaterialProperty.PropType.Vector:
                return new AlloyVectorParser(prop);

            default:
                Debug.LogError("No appopriate parser found to generate a drawer");
                return null;
        }
    }

    public static AlloyFieldDrawer GetFieldDrawer(AlloyInspectorBase editor, MaterialProperty prop) {
        AlloyFieldParser parser = GetFieldParser(prop);

        if (parser != null) {
            return parser.GetDrawer(editor);
        }

        return null;
    }
}

