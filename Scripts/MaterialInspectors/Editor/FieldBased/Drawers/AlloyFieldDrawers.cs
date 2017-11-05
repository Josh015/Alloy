// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System.Linq;
using UnityEditor;
using UnityEngine;

public class AlloyDefaultDrawer : AlloyFieldDrawer
{
    public override void Draw(AlloyFieldDrawerArgs args) {
        PropField(DisplayName);
    }

    public AlloyDefaultDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
    }
}

public class AlloyLightmapEmissionDrawer : AlloyFieldDrawer {
    public override void Draw(AlloyFieldDrawerArgs args) {
        args.Editor.MatEditor.LightmapEmissionProperty();
        
        foreach (var material in args.Materials) {
            // Setup lightmap emissive flags
            MaterialGlobalIlluminationFlags flags = material.globalIlluminationFlags;
            if ((flags & (MaterialGlobalIlluminationFlags.BakedEmissive | MaterialGlobalIlluminationFlags.RealtimeEmissive)) != 0) {
                flags &= ~MaterialGlobalIlluminationFlags.EmissiveIsBlack;
                
            
                material.globalIlluminationFlags = flags;
            }
        }
    }

    public AlloyLightmapEmissionDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
    }
}

public class AlloyRenderQueueDrawer : AlloyFieldDrawer {
    public override void Draw(AlloyFieldDrawerArgs args) {
        args.Editor.MatEditor.RenderQueueField();
    }

    public AlloyRenderQueueDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
    }
}

public class AlloyEnableInstancingDrawer : AlloyFieldDrawer {
    public override void Draw(AlloyFieldDrawerArgs args) {
        args.Editor.MatEditor.EnableInstancingField();
    }

    public AlloyEnableInstancingDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
    }
}

public class AlloyRenderingModeDrawer : AlloyBlendModeDropdownDrawer {    
    private enum RenderingMode {
        Opaque,
        Cutout,
        Fade,
        Transparent
    }

    private static readonly BlendModeOptionConfig[] s_renderingModes = {
        new BlendModeOptionConfig() {
            Type = (int)RenderingMode.Opaque,
            OverrideTag = "",
            SrcBlend = UnityEngine.Rendering.BlendMode.One,
            DstBlend = UnityEngine.Rendering.BlendMode.Zero,
            ZWrite = 1,
            Keyword = "",
            RenderQueue = -1
        },
        new BlendModeOptionConfig() {
            Type = (int)RenderingMode.Cutout,
            OverrideTag = "TransparentCutout",
            SrcBlend = UnityEngine.Rendering.BlendMode.One,
            DstBlend = UnityEngine.Rendering.BlendMode.Zero,
            ZWrite = 1,
            Keyword = "_ALPHATEST_ON",
            RenderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest,
        },
        new BlendModeOptionConfig() {
            Type = (int)RenderingMode.Fade,
            OverrideTag = "Transparent",
            SrcBlend = UnityEngine.Rendering.BlendMode.SrcAlpha,
            DstBlend = UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha,
            ZWrite = 0,
            Keyword = "_ALPHABLEND_ON",
            RenderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent
        },
        new BlendModeOptionConfig() {
            Type = (int)RenderingMode.Transparent,
            OverrideTag = "Transparent",
            SrcBlend = UnityEngine.Rendering.BlendMode.One,
            DstBlend = UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha,
            ZWrite = 0,
            Keyword = "_ALPHAPREMULTIPLY_ON",
            RenderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent
        },
    };

    public AlloyRenderingModeDrawer(AlloyInspectorBase editor, MaterialProperty property) 
        : base(editor, property, s_renderingModes) {
    }
}

public class AlloySpeedTreeGeometryTypeDrawer : AlloyBlendModeDropdownDrawer {
    private enum SpeedTreeGeometryType {
        Branch,
        BranchDetail,
        Frond,
        Leaf,
        Mesh,
    }

    private static readonly BlendModeOptionConfig[] s_geometryTypes = {
        new BlendModeOptionConfig() {
            Type = (int)SpeedTreeGeometryType.Branch,
            OverrideTag = "",
            SrcBlend = UnityEngine.Rendering.BlendMode.One,
            DstBlend = UnityEngine.Rendering.BlendMode.Zero,
            ZWrite = 1,
            Keyword = "GEOM_TYPE_BRANCH",
            RenderQueue = -1
        },
        new BlendModeOptionConfig() {
            Type = (int)SpeedTreeGeometryType.BranchDetail,
            OverrideTag = "",
            SrcBlend = UnityEngine.Rendering.BlendMode.One,
            DstBlend = UnityEngine.Rendering.BlendMode.Zero,
            ZWrite = 1,
            Keyword = "GEOM_TYPE_BRANCH_DETAIL",
            RenderQueue = -1
        },
        new BlendModeOptionConfig() {
            Type = (int)SpeedTreeGeometryType.Frond,
            OverrideTag = "TransparentCutout",
            SrcBlend = UnityEngine.Rendering.BlendMode.One,
            DstBlend = UnityEngine.Rendering.BlendMode.Zero,
            ZWrite = 1,
            Keyword = "GEOM_TYPE_FROND",
            RenderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest
        },
        new BlendModeOptionConfig() {
            Type = (int)SpeedTreeGeometryType.Leaf,
            OverrideTag = "TransparentCutout",
            SrcBlend = UnityEngine.Rendering.BlendMode.One,
            DstBlend = UnityEngine.Rendering.BlendMode.Zero,
            ZWrite = 1,
            Keyword = "GEOM_TYPE_LEAF",
            RenderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest
        },
        new BlendModeOptionConfig() {
            Type = (int)SpeedTreeGeometryType.Mesh,
            OverrideTag = "",
            SrcBlend = UnityEngine.Rendering.BlendMode.One,
            DstBlend = UnityEngine.Rendering.BlendMode.Zero,
            ZWrite = 1,
            Keyword = "GEOM_TYPE_MESH",
            RenderQueue = -1
        }, 
    };
    
    public AlloySpeedTreeGeometryTypeDrawer(AlloyInspectorBase editor, MaterialProperty property) 
        : base(editor, property, s_geometryTypes)
    {
    }
}

public class AlloyColorParser : AlloyFieldParser{
    protected override AlloyFieldDrawer GenerateDrawer(AlloyInspectorBase editor) {
        var ret = new AlloyColorDrawer(editor, MaterialProperty);
        return ret;
    }
    
    public AlloyColorParser(MaterialProperty field) : base(field) {
    }
}

public class AlloyColorDrawer : AlloyFieldDrawer {
    public override void Draw(AlloyFieldDrawerArgs args) {
        PropField(DisplayName);
    }

    public AlloyColorDrawer(AlloyInspectorBase editor, MaterialProperty property) : base(editor, property) {
    }
}
