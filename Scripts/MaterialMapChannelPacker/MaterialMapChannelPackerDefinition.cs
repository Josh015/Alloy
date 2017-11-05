// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System;
using System.Collections.Generic;
using Alloy;
using UnityEngine;

public class MaterialMapChannelPackerDefinition : ScriptableObject {
	public List<PackedMapDefinition> PackedMaps;

	public PackedMapDefinition PackedPack { get { return PackedMaps[0]; } }
	public PackedMapDefinition DetailPack { get { return PackedMaps[1]; } }
	public PackedMapDefinition TerrainPack { get { return PackedMaps[2]; } }


	[Header("Global settings")] public NormalMapChannelTextureChannelMapping NRMChannel = new NormalMapChannelTextureChannelMapping();

	[Space(15.0f)] public string VarianceText;
	public string AutoRegenerateText;

	public bool IsPackedMap(string path) {
		for (int i = 0; i < PackedMaps.Count; i++) {
			var map = PackedMaps[i];
			if (path.EndsWith(map.Suffix, StringComparison.InvariantCultureIgnoreCase)) {
				return true;
			}
		}

		return false;
	}
}