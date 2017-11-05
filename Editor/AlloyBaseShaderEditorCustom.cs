using UnityEngine;
using System.Collections;

public class AlloyBaseShaderEditorCustom : AlloyInspectorDefinitionBasedEditor
{
	protected override void OnAlloyShaderEnable() {
		InspectorDefinition = "Assets/Alloy/Editor/inspectorDefinitionCustom.asset";
		base.OnAlloyShaderEnable();
	}
}