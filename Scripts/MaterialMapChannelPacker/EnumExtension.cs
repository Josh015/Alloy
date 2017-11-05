using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace Alloy {
	public class EnumFlagsAttribute : PropertyAttribute {
	}

	public static class EnumExtension {
		public static bool HasFlag(this Enum keys, Enum flag) {
			int keysVal = Convert.ToInt32(keys);
			int flagVal = Convert.ToInt32(flag);

			return (keysVal & flagVal) == flagVal;
		}
	}

}