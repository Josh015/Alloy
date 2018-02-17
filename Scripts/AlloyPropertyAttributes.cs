using UnityEngine;

public class AlloyMinValueAttribute : PropertyAttribute {
    public float Min;

    public AlloyMinValueAttribute(float min) {
        Min = min;
    }
}


public class AlloyMaxValueAttribute : PropertyAttribute {
    public float Max;

    public AlloyMaxValueAttribute(float min) {
        Max = min;
    }
}

