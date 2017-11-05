#if UNITY_EDITOR
using UnityEditor;
#endif

using System;
using UnityEngine;
using UnityEngine.Serialization;

[ExecuteInEditMode]
[RequireComponent(typeof(Light))]
[AddComponentMenu(AlloyUtils.ComponentMenu + "Area Light")]
public class AlloyAreaLight : MonoBehaviour {
    // Minimum non-zero value for light size, so we can use sign for specular toggle.
    const float c_minimumLightSize = 0.00001f;

    // Minimum light intensity to prevent divide by zero (because Epsilon causes infinity).
    const float c_minimumLightIntensity = 0.01f;

    [HideInInspector]
    public Texture2D DefaultSpotLightCookie;

    [FormerlySerializedAs("m_size")]
    [SerializeField] 
    float m_radius;

    [SerializeField]
    float m_length;

    [SerializeField] 
    bool m_hasSpecularHightlight = true;

    Light m_light;
    Color m_lastColor;
    float m_lastIntensity;
    float m_lastRange;

    Light Light {
        get {
            // Ensures that we have the light component, even if light is disabled.
            if (m_light == null)
                m_light = GetComponent<Light>();

            return m_light;
        }
    }

    public float Radius {
        get { return m_radius; }
        set {
            if (m_radius != value) {
                m_radius = value;
                UpdateBinding();
            }
        }
    }

    public float Length {
        get { return m_length; }
        set {
            if (m_length != value) {
                m_length = value;
                UpdateBinding();
            }
        }
    }
    
    public bool HasSpecularHighlight {
        get { return m_hasSpecularHightlight; }
        set {
            if (m_hasSpecularHightlight != value) {
                m_hasSpecularHightlight = value;
                UpdateBinding();
            }
        }
    }

    void Reset() {
        m_hasSpecularHightlight = true;
        m_radius = 0.0f;
        m_length = 0.0f;

        m_lastColor = Color.black;
        m_lastIntensity = 0.0f;
        m_lastRange = 0.0f;

        UpdateBinding();
    }

    // Must run after all other light scripts and animation clips.
    void LateUpdate() {
        var l = Light;

        // Poll the Light component, since we can't extend it.
        if (l.color != m_lastColor
            || l.intensity != m_lastIntensity
            || l.range != m_lastRange) {
            UpdateBinding();
        }
    }

    public void UpdateBinding() {
        var l = Light;
        var color = l.color;
        var intensity = l.intensity;
        var range = l.range;

#if UNITY_EDITOR
        EnsureCookie();
#endif

        if (l.type == LightType.Directional) {
            m_radius = Mathf.Clamp01(m_radius);
            color.a = 10.0f * m_radius; // Cancel 0.1 * n in the shader.
        }
        else {
            // Radius packed into fractional component of number.
            var maxRadius = range;
            m_radius = Mathf.Clamp(m_radius, 0.0f, maxRadius);
            color.a = Mathf.Min(0.999f, m_radius / maxRadius);
            
            if (l.type == LightType.Point) {
                // Length packed into integer component of number.
                var maxLength = 2.0f * range;
                m_length = Mathf.Clamp(m_length, 0.0f, maxLength);
                color.a += Mathf.Ceil(1000.0f * Mathf.Min(1.0f, m_length / maxLength));
            }
        }

        // Specular highlight toggle in sign component of number.
        color.a = Mathf.Max(c_minimumLightSize, color.a); // Must be non-zero!
        color.a *= (m_hasSpecularHightlight ? 1.0f : -1.0f);

        // Cancel Unity's implicit intensity multiply.
        color.a /= Mathf.Max(intensity, c_minimumLightIntensity);
        l.color = color;

        m_lastColor = color;
        m_lastIntensity = intensity;
        m_lastRange = range;
    }

#if UNITY_EDITOR
    public void EnsureCookie() {
        var l = Light;

        if (l.type == LightType.Spot && l.cookie == null) {
            l.cookie = DefaultSpotLightCookie;
            EditorUtility.SetDirty(this);
        } else if (l.type == LightType.Point && l.cookie == DefaultSpotLightCookie) {
            l.cookie = null;
            EditorUtility.SetDirty(this);
        }
    }
#endif

    // DEPRECATED BEGIN
    [Obsolete("Please use Unity Light component's \"color\" field.")]
    public Color Color {
        get { return Light.color; }
        set { Light.color = value; }
    }

    [Obsolete("Please use Unity Light component's \"intensity\" field.")]
    public float Intensity {
        get { return Light.intensity; }
        set { Light.intensity = value; }
    }

    [Obsolete("No longer used. Please remove all references to it.")]
    public bool IsAnimated { get; set; }
    // DEPRECATED END
}
