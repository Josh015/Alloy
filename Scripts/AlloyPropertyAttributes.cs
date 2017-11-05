using UnityEngine;

public class MinValueAttribute : PropertyAttribute {
    public float Min;

    public MinValueAttribute(float min) {
        Min = min;
    }
}


public class MaxValueAttribute : PropertyAttribute {
    public float Max;

    public MaxValueAttribute(float min) {
        Max = min;
    }
}

