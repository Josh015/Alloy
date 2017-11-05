// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace Alloy {
	[Serializable]
	public class BaseTextureChannelMapping {
		public string Title;
		public string HelpText;
		public Color BackgroundColor;
	}

	[Flags]
	public enum MapChannel {
		R = 1,
		G = 2,
		B = 4,
		A = 8
	}

	public enum TextureValueChannelMode {
		Black,
		Gray,
		White,
		Custom,
		Texture
	}

	[Serializable]
	public class MapTextureChannelMapping : BaseTextureChannelMapping {
		public bool CanInvert;
		public bool InvertByDefault;

		[EnumFlags] public MapChannel InputChannels;
		[EnumFlags] public MapChannel OutputChannels;
		public bool RoughnessCorrect;
		public bool OutputVariance;
		public bool HideChannel;

		public TextureValueChannelMode DefaultMode;


		public int MainIndex {
			get {
				if (OutputChannels.HasFlag(MapChannel.R)) {
					return 0;
				}
				if (OutputChannels.HasFlag(MapChannel.G)) {
					return 1;
				}
				if (OutputChannels.HasFlag(MapChannel.B)) {
					return 2;
				}
				if (OutputChannels.HasFlag(MapChannel.A)) {
					return 3;
				}

				Debug.LogError(" Packed map does not have any output channels");
				return 0;
			}
		}

		private IEnumerable<int> GetIndices(MapChannel channel) {
			if (channel.HasFlag(MapChannel.R)) {
				yield return 0;
			}
			if (channel.HasFlag(MapChannel.G)) {
				yield return 1;
			}
			if (channel.HasFlag(MapChannel.B)) {
				yield return 2;
			}
			if (channel.HasFlag(MapChannel.A)) {
				yield return 3;
			}
		}

		public IEnumerable<int> InputIndices {
			get { return GetIndices(InputChannels); }
		}

		public IEnumerable<int> OutputIndices {
			get { return GetIndices(OutputChannels); }
		}

		private string GetChannelString(MapChannel channel) {
			StringBuilder sb = new StringBuilder(5);
			if (channel.HasFlag(MapChannel.R)) {
				sb.Append('R');
			}
			if (channel.HasFlag(MapChannel.G)) {
				sb.Append('G');
			}
			if (channel.HasFlag(MapChannel.B)) {
				sb.Append('B');
			}
			if (channel.HasFlag(MapChannel.A)) {
				sb.Append('A');
			}

			return sb.ToString();
		}

		public string InputString { get { return GetChannelString(InputChannels); } }
		public string OutputString { get { return GetChannelString(OutputChannels); } }
		public bool UseNormals { get { return OutputVariance || RoughnessCorrect; } }
	}


	[Serializable] public class NormalMapChannelTextureChannelMapping : BaseTextureChannelMapping { }
	[Serializable]
	public class TextureImportConfig {
		public bool IsLinear;
		public FilterMode Filter = FilterMode.Trilinear;
		public bool DefaultCompressed;
	}
}