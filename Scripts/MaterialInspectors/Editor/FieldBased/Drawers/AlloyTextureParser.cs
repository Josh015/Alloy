// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System;
using System.Linq;
using UnityEditor;

public class AlloyTextureParser : AlloyFieldParser
{
    protected override AlloyFieldDrawer GenerateDrawer(AlloyInspectorBase editor) {
        var ret = new AlloyTextureFieldDrawer(editor, MaterialProperty);

        foreach (var token in Arguments) {
            var argName = token.ArgumentName;
            var argToken = token.ArgumentToken;

            switch (argName) {
                case "Visualize": {
                        var container = argToken as AlloyCollectionToken;
                        if (container != null) {
                            ret.DisplayModes = container.SubTokens.Select(t => (AlloyTextureFieldDrawer.TextureVisualizeMode)Enum.Parse(typeof(AlloyTextureFieldDrawer.TextureVisualizeMode), t.Token)).ToArray();
                        }
                    }

                    break;

                case "Parent": {
                        ret.ParentTexture = argToken.Token;
                    }

                    break;

                case "Controls":
                    var valueToken = argToken as AlloyValueToken;
                    if (valueToken != null) {
                        ret.Controls = valueToken.BoolValue;
                    }
                    break;

                //				case "Keyword":
                //					ret.Keyword = argToken.Token;
                //					break;
            }
        }

        return ret;
    }

    public AlloyTextureParser(MaterialProperty field)
        : base(field) {
    }
}



public class AlloyCubeParser : AlloyFieldParser
{
    public AlloyCubeParser(MaterialProperty field)
        : base(field) {

    }

    protected override AlloyFieldDrawer GenerateDrawer(AlloyInspectorBase editor) {
        return new AlloyDefaultDrawer(editor, MaterialProperty);
    }
}