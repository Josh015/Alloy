// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using System;
using System.Linq;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Alloy;

[CanEditMultipleObjects]
public class AlloyInspectorDefinitionBasedEditor : AlloyInspectorBase
{
	private AlloyInspectorDefinition m_definition;

	private bool[] m_hasTab;

	private Shader m_curShader;

	protected string InspectorDefinition;

	protected override void OnAlloyShaderEnable() {
		m_definition =
			AssetDatabase.LoadAssetAtPath(InspectorDefinition, typeof (AlloyInspectorDefinition)) as AlloyInspectorDefinition;

		InitProperties();
	}

	private void InitProperties() {
		if (m_definition == null || m_definition.Tabs == null) {
			return;
		}

		MaterialProperties = GetMaterialProperties(targets);
		MaterialPropNames = new string[MaterialProperties.Length];
		
		for (int i = 0; i < MaterialProperties.Length; ++i) {
			MaterialPropNames[i] = MaterialProperties[i].name;
		}

		var mat = target as Material;
		m_curShader = mat.shader;

		m_hasTab = new bool[m_definition.Tabs.Length];

		for (int i = 0; i < m_definition.Tabs.Length; i++) {
			var tab = m_definition.Tabs[i];

			if (tab.Fields.Any(definition => MaterialPropNames.Contains(definition.Name))) {
				m_hasTab[i] = true;
			}
		}
	}

	protected override void OnAlloyShaderGUI() {
		if (m_definition == null || m_definition.Tabs == null) {
			Debug.LogError("No inspector definition file! Contact alloy support");
			return;
		}

		var mat = target as Material;
		var parametersToHide = new List<string>();

		if (mat.shader != m_curShader) {
			InitProperties();
		}

		for (int i = 0; i < m_definition.Tabs.Length; i++) {
			if (!m_hasTab[i]) {
				continue;
			}

			var tab = m_definition.Tabs[i];

			if (!TabGroup.TabArea(tab.Name, tab.Color, tab.Name + MatInst)) {
				continue;
			}

			UpdateHiddenParameters(tab, parametersToHide);

			foreach (var field in tab.Fields) {
				if (parametersToHide.Contains(field.Name)) {
					continue;
				}

				AlloyFieldProperty(field);
			}

			GUILayout.Space(10.0f);
		}
	}

	private void UpdateHiddenParameters(AlloyInspectorTab tab, List<string> parametersToHide) {
		foreach (var field in tab.Fields) {
			if (!field.IsDropDown) {
				continue;
			}

			var mode = (int) GetProperty(field.Name).floatValue;
			var parameterHideSettings = field.DropDownSettings.ParameterHideSettings;

			if ((parameterHideSettings.Length - 1) >= mode) {
				var parameters = parameterHideSettings[mode].ParametersToHide;

				foreach (var parameter in parameters) {
					if (!parametersToHide.Contains(parameter)) {
						parametersToHide.Add(parameter);
					}
				}
			}
		}
	}
}
