using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

[CustomEditor(typeof (SubstanceArchive), true)]
public class AlloySbarEditor : Editor
{
	protected bool IsVisible;

	private static SubstanceArchive s_lastSelectedPackage;
	private static string s_cachedSelectedMaterialInstanceName;
	private static int s_previewNoDragDropHash = "PreviewWithoutDragAndDrop".GetHashCode();

	private Vector2 m_listScroll = Vector2.zero;
	private string m_selectedMaterialInstanceName;
	private string[] m_prototypeNames;
	private Editor m_substanceEditor;

	private SubstanceStyles m_substanceStyles;
	private EditorCache m_editorCache;

	private class SubstanceStyles
	{
		public GUIContent IconToolbarPlus = EditorGUIUtility.IconContent("Toolbar Plus", "Add substance from prototype.");
		public GUIContent IconToolbarMinus = EditorGUIUtility.IconContent("Toolbar Minus", "Remove selected substance.");
		public GUIContent IconDuplicate = EditorGUIUtility.IconContent("TreeEditor.Duplicate", "Duplicate selected substance.");
		public GUIStyle ResultsGridLabel = "ObjectPickerResultsGridLabel";
		public GUIStyle ResultsGrid = "ObjectPickerResultsGrid";
		public GUIStyle GridBackground = "TE NodeBackground";
		public GUIStyle Background = "ObjectPickerBackground";
		public GUIStyle Toolbar = "TE Toolbar";
		public GUIStyle ToolbarButton = "TE toolbarbutton";
		public GUIStyle ToolbarDropDown = "TE toolbarDropDown";
	}


	public static void CallOnSubstanceEditor(string funcName, Editor substanceEditor) {
		substanceEditor.GetType().GetMethod(funcName, BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance).
			Invoke(substanceEditor, null);
	}

	public void OnEnable() {
		if (target == s_lastSelectedPackage) {
			m_selectedMaterialInstanceName = s_cachedSelectedMaterialInstanceName;
		}
		else {
			s_lastSelectedPackage = target as SubstanceArchive;
		}

		

		m_editorCache = new EditorCache();
	}

	public void OnDisable() {
		if (m_substanceEditor != null) {
			CallOnSubstanceEditor("ReimportSubstancesIfNeeded", m_substanceEditor);
			DestroyImmediate(m_substanceEditor);
		}

		if (m_editorCache != null) {
			m_editorCache.Dispose();
		}

		s_cachedSelectedMaterialInstanceName = m_selectedMaterialInstanceName;
	}

	private ProceduralMaterial GetSelectedMaterial() {
		if (GetImporter() == null) {
			return null;
		}
		ProceduralMaterial[] sortedMaterials = GetSortedMaterials();
		if (m_selectedMaterialInstanceName != null) {
			return Array.Find(sortedMaterials,
			                  (element => element.name == m_selectedMaterialInstanceName));
		}
		if (sortedMaterials.Length <= 0) {
			return null;
		}
		m_selectedMaterialInstanceName = sortedMaterials[0].name;
		return sortedMaterials[0];
	}

	private void SelectNextMaterial() {
		if (GetImporter() == null) {
			return;
		}
		string str = null;
		ProceduralMaterial[] sortedMaterials = GetSortedMaterials();
		for (int index1 = 0; index1 < sortedMaterials.Length; ++index1) {
			if (sortedMaterials[index1].name != m_selectedMaterialInstanceName) {
				continue;
			}


			int index2 = Math.Min(index1 + 1, sortedMaterials.Length - 1);

			if (index2 == index1) {
				--index2;
			}
			if (index2 >= 0) {
				str = sortedMaterials[index2].name;
			}

			break;
		}
		m_selectedMaterialInstanceName = str;
	}

	private Editor GetSelectedMaterialInspector() {
		var selectedMaterial = GetSelectedMaterial();

		if (selectedMaterial != null && m_substanceEditor != null && m_substanceEditor.target == selectedMaterial) {
			return m_substanceEditor;
		}

		DestroyImmediate(m_substanceEditor);
		m_substanceEditor = null;

		if ((selectedMaterial)) {
			m_substanceEditor = CreateSubstanceEditor(selectedMaterial);

			CallOnSubstanceEditor("DisableReimportOnDisable", m_substanceEditor);
		}

		return m_substanceEditor;
	}

	public static Editor CreateSubstanceEditor(ProceduralMaterial selectedMaterial) {
		var foundType =
			AppDomain.CurrentDomain.GetAssemblies().SelectMany(assembly => assembly.GetTypes()).First(
				type => type.Name == "ProceduralMaterialInspector");


		return CreateEditor(selectedMaterial, foundType);
	}

	public override void OnInspectorGUI() {
		if (m_substanceStyles == null) {
			m_substanceStyles = new SubstanceStyles();
		}

		EditorGUILayout.Space();
		EditorGUILayout.BeginVertical();
		MaterialListing();
		MaterialManagement();
		EditorGUILayout.EndVertical();
		Editor materialInspector = GetSelectedMaterialInspector();

		if (!(materialInspector)) {
			return;
		}


		materialInspector.DrawHeader();

		m_editorCache[materialInspector.target].OnInspectorGUI();
	}


	public static void DrawSubstanceInspector(Editor materialInspector) {
		CallOnSubstanceEditor("DisplayRestrictedInspector", materialInspector);
	}

	private SubstanceImporter GetImporter() {
		return AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(target)) as SubstanceImporter;
	}

	private void MaterialListing() {
		ProceduralMaterial[] sortedMaterials = GetSortedMaterials();
		
		if (sortedMaterials.Any(proceduralMaterial => proceduralMaterial.isProcessing)) {
			Repaint();
			SceneView.RepaintAll();
		}


		int length = sortedMaterials.Length;
		var width = Screen.width - 36.0f;

		if (width * 2.0 < length * 60.0f) {
			width -= 16f;
		}

		int times = Mathf.Max(1, Mathf.FloorToInt(width / 60f));
		int totalWidth = Mathf.CeilToInt(length / (float) times);
		var viewRect = new Rect(0.0f, 0.0f, times * 60f, totalWidth * 76f);

		Rect rect = GUILayoutUtility.GetRect(viewRect.width, Mathf.Clamp(viewRect.height, 76f, 152f) + 1f);

		var backgroundRect = new Rect(rect.x + 1f, rect.y + 1f, rect.width - 2f, rect.height - 1f);
		GUI.Box(rect, GUIContent.none, m_substanceStyles.GridBackground);
		GUI.Box(backgroundRect, GUIContent.none, m_substanceStyles.Background);

		m_listScroll = GUI.BeginScrollView(backgroundRect, m_listScroll, viewRect, false, false);


		for (int index = 0; index < sortedMaterials.Length; ++index) {
			ProceduralMaterial proceduralMaterial = sortedMaterials[index];

			if (proceduralMaterial == null) {
				continue;
			}
			
			var previewRect = new Rect((index % times) * 60f, index / times * 76, 60f, 76f);

			bool selected = proceduralMaterial.name == m_selectedMaterialInstanceName;
			Event current = Event.current;
			int controlId = GUIUtility.GetControlID(s_previewNoDragDropHash, FocusType.Native,
			                                        previewRect);

			switch (current.GetTypeForControl(controlId)) {
				case EventType.MouseDown:
					if (current.button == 0 && previewRect.Contains(current.mousePosition)) {
						
						if (current.clickCount == 1) {
							m_selectedMaterialInstanceName = proceduralMaterial.name;
							current.Use();
							break;
						}

						if (current.clickCount == 2) {
							AssetDatabase.OpenAsset(proceduralMaterial);
							GUIUtility.ExitGUI();
							current.Use();
						}
					}

					break;


				case EventType.Repaint:
					Rect gridPos = previewRect;
					gridPos.y = previewRect.yMax - 16f;
					gridPos.height = 16f;
					m_substanceStyles.ResultsGridLabel.Draw(gridPos, new GUIContent(proceduralMaterial.name),
					                                        false, false, selected, selected);
					break;
			}
				
				
			previewRect.height -= 16f;

			m_editorCache[proceduralMaterial].OnPreviewGUI(previewRect, EditorStyles.toolbarButton);
		}

		GUI.EndScrollView();
	}


	public override bool HasPreviewGUI() {
		return GetSelectedMaterialInspector() != null;
	}

	public override void OnPreviewGUI(Rect position, GUIStyle style) {
		Editor materialInspector = GetSelectedMaterialInspector();

		if (!(materialInspector)) {
			return;
		}

		materialInspector.OnPreviewGUI(position, style);
	}


	public override void OnPreviewSettings() {
		Editor materialInspector = GetSelectedMaterialInspector();
		if (!(materialInspector)) {
			return;
		}
		materialInspector.OnPreviewSettings();
	}


	public void InstantiatePrototype(object prototypeName) {
		m_selectedMaterialInstanceName = GetImporter().InstantiateMaterial(prototypeName as string);
		ApplyAndRefresh(false);
	}

	private ProceduralMaterial[] GetSortedMaterials() {
		ProceduralMaterial[] materials = GetImporter().GetMaterials();
		Array.Sort(materials, new SubstanceNameComparer());
		return materials;
	}
	
	private bool ButtonMouseDown(Rect position, GUIContent content, FocusType fType, GUIStyle style) {
		int controlId = GUIUtility.GetControlID("ButtonMouseDown".GetHashCode(), fType, position);
		Event current = Event.current;
		EventType type = current.type;
		switch (type) {
			case EventType.KeyDown:
				if (GUIUtility.keyboardControl == controlId && current.character == 32) {
					Event.current.Use();
					return true;
				}

				break;
			case EventType.Repaint:

				style.Draw(position, content, controlId, false);
				break;

			default:
				if (type == EventType.MouseDown && position.Contains(current.mousePosition) && current.button == 0) {
					Event.current.Use();
					return true;
				}
				break;
		}

		return false;
	}

	private void MaterialManagement() {
		SubstanceImporter importer = GetImporter();
		
		if (m_prototypeNames == null) {
			m_prototypeNames = importer.GetPrototypeNames();
		}
		
		var selectedMaterial = GetSelectedMaterial();

		GUILayout.BeginHorizontal(m_substanceStyles.Toolbar);
		GUILayout.FlexibleSpace();
		EditorGUI.BeginDisabledGroup(EditorApplication.isPlaying);

		if (m_prototypeNames.Length > 1) {
			Rect rect = GUILayoutUtility.GetRect(m_substanceStyles.IconToolbarPlus, m_substanceStyles.ToolbarDropDown);


			if (ButtonMouseDown(rect, m_substanceStyles.IconToolbarPlus, FocusType.Passive,
			                    m_substanceStyles.ToolbarDropDown)) {
				
				var genericMenu = new GenericMenu();
				
				for (int index = 0; index < m_prototypeNames.Length; ++index) {
					genericMenu.AddItem(new GUIContent(m_prototypeNames[index]), false,
					                    InstantiatePrototype, m_prototypeNames[index]);
				}
				
				genericMenu.DropDown(rect);
			}
		}
		else if (m_prototypeNames.Length == 1 &&
		         GUILayout.Button(m_substanceStyles.IconToolbarPlus, m_substanceStyles.ToolbarButton)) {
			m_selectedMaterialInstanceName = GetImporter().InstantiateMaterial(m_prototypeNames[0]);
			ApplyAndRefresh(true);
		}

		EditorGUI.BeginDisabledGroup(selectedMaterial == null);
		
		if (GUILayout.Button(m_substanceStyles.IconToolbarMinus, m_substanceStyles.ToolbarButton) &&
			GetSortedMaterials().Length > 1) {
			SelectNextMaterial();
			importer.DestroyMaterial(selectedMaterial);
			ApplyAndRefresh(true);
		}

		if (GUILayout.Button(m_substanceStyles.IconDuplicate, m_substanceStyles.ToolbarButton)) {
			string str = importer.CloneMaterial(selectedMaterial);
			if (str != string.Empty) {
				m_selectedMaterialInstanceName = str;
				ApplyAndRefresh(true);
			}
		}

		EditorGUI.EndDisabledGroup();
		EditorGUI.EndDisabledGroup();
		EditorGUILayout.EndHorizontal();
	}

	private void ApplyAndRefresh(bool exitGUI) {
		AssetDatabase.ImportAsset(AssetDatabase.GetAssetPath(target), ImportAssetOptions.ForceUncompressedImport);
		
		if (exitGUI) {
			GUIUtility.ExitGUI();
		}
		
		Repaint();
	}


	public class SubstanceNameComparer : IComparer
	{
		public int Compare(object o1, object o2) {
			var unityObject1 = o1 as Object;

			if (unityObject1 != null) {
				var unityObject2 = o2 as Object;

				if (unityObject2 != null) {
					return EditorUtility.NaturalCompare(unityObject1.name, unityObject2.name);
				}
			}

			return 0;
		}
	}

	class EditorCache : IDisposable
	{
		private Dictionary<Object, Editor> m_editorCache;
		private Dictionary<Object, bool> m_usedEditors;

		public Editor this[Object o] {
			get {
				m_usedEditors[o] = true;
				if (m_editorCache.ContainsKey(o)) {
					return m_editorCache[o];
				}
				Editor editorWrapper1 = CreateEditor(o);

				if (editorWrapper1 == null) {
					return null;
				}

				Editor editorWrapper2 = editorWrapper1;
				m_editorCache[o] = editorWrapper2;
				return editorWrapper2;
			}
		}


		public EditorCache() {
			m_editorCache = new Dictionary<Object, Editor>();
			m_usedEditors = new Dictionary<Object, bool>();
		}

		~EditorCache() {
			Debug.LogError("Failed to dispose EditorCache.");
		}

		public void CleanupUntouchedEditors() {
			var list = new List<Object>();
			using (
				Dictionary<Object, Editor>.KeyCollection.Enumerator enumerator = m_editorCache.Keys.GetEnumerator()) {
				while (enumerator.MoveNext()) {
					Object current = enumerator.Current;
					if (current != null && !m_usedEditors.ContainsKey(current)) {
						list.Add(current);
					}
				}
			}
			if (m_editorCache != null) {
				using (List<Object>.Enumerator enumerator = list.GetEnumerator()) {
					while (enumerator.MoveNext()) {
						Object current = enumerator.Current;


						if (current == null) {
							continue;
						}
						
						DestroyImmediate(m_editorCache[current]);
						m_editorCache.Remove(current);
					}
				}
			}
			m_usedEditors.Clear();
		}

		private void CleanupAllEditors() {
			m_usedEditors.Clear();
			CleanupUntouchedEditors();
		}

		public void Dispose() {
			CleanupAllEditors();
			GC.SuppressFinalize(this);
		}
	}
}