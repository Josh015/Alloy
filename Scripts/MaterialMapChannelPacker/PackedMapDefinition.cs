using UnityEngine;
using System.Collections.Generic;

namespace Alloy {
    [CreateAssetMenu(fileName = "PackedMapDefinition.asset", menuName = "Alloy Packed Map Definition")]
    public class PackedMapDefinition : ScriptableObject {
        public string Title;
        public string Suffix;
        public bool VarianceBias = true;

        public TextureImportConfig ImportSettings = new TextureImportConfig();


        public List<MapTextureChannelMapping> Channels = new List<MapTextureChannelMapping>();
    }
}