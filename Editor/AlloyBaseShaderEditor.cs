using UnityEditor;
using UnityEngine;
using System.Collections;

[CanEditMultipleObjects]
public class AlloyBaseShaderEditor : AlloyInspectorDefinitionBasedEditor
{
	protected override void OnAlloyShaderEnable()
	{
		InspectorDefinition = "Assets/Alloy/Editor/inspectorDefinition.asset";
		base.OnAlloyShaderEnable();
	}
}
