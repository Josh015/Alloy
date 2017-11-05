// Alloy Physical Shader Framework
// Copyright 2013-2014 RUST LLC.
// http://www.alloy.rustltd.com/

using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;

namespace Alloy
{
	[InitializeOnLoad]
	public static class AlloyImporterSupervisor
	{
		private static List<FailedImport> s_failedImportAttempts;

		public static bool IsFinalTry;
		private const int c_maxTries = 3;

		public static void OnFailedImport(string path) {
			if (s_failedImportAttempts == null) {
				s_failedImportAttempts = new List<FailedImport>();
			}


			if (s_failedImportAttempts.All(import => import.Path != path)) {
				s_failedImportAttempts.Add(new FailedImport {Path = path, Tries = 0});
			}
		}

		static AlloyImporterSupervisor() {
			EditorApplication.update += Update;
		}

		private struct FailedImport
		{
			public string Path;
			public int Tries;
		}

		// Update is called once per frame
		private static void Update() {
			if (s_failedImportAttempts == null) {
				s_failedImportAttempts = new List<FailedImport>();
			}


			if (s_failedImportAttempts.Count == 0) {
				return;
			}

			var failed = s_failedImportAttempts.ToArray();
			foreach (var failedImport in failed) {
				var path = failedImport.Path;
				
				


				var settings = AssetDatabase.LoadAssetAtPath(path, typeof (AlloyCustomImportObject)) as AlloyCustomImportObject;
				if (settings == null) {
					if (failedImport.Tries > c_maxTries) {
						Debug.LogError("Can't find shader map settings file! Contact aloy support");

						s_failedImportAttempts.Remove(failedImport);
					}

					continue;
				}


				IsFinalTry = true;
				settings.GenerateMap();
				IsFinalTry = false;

				s_failedImportAttempts.Remove(failedImport);
			}
		}
	}
}