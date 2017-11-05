// Alloy Physical Shader Framework
// Copyright 2013-2017 RUST LLC.
// http://www.alloy.rustltd.com/

using System;
using UnityEngine;
using UnityEngine.Rendering;

#if UNITY_EDITOR
using UnityEditor;
#endif

[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
[RequireComponent(typeof (Camera))]
[AddComponentMenu(AlloyUtils.ComponentMenu + "Effects Manager")]
public class AlloyEffectsManager : MonoBehaviour {

    // Arbitrary range multiplier.
    private const float c_blurWdith = 0.15f;
    private const float c_blurDepthDifferenceMultiplier = 100.0f;
    private const string c_copyTransmissionBufferName = "AlloyCopyTransmission";
    private const string c_blurNormalsBufferName = "AlloyBlurNormals";
    private const CameraEvent c_copyTransmissionEvent = CameraEvent.AfterGBuffer;
    private const CameraEvent c_blurNormalsEvent = CameraEvent.BeforeLighting;

    [Serializable]
    public struct SkinSettingsData {
        public bool Enabled;
        public Texture2D Lut;

        [Range(0.0f, 1.0f)]
        public float Weight;

        [Range(0.01f, 1.0f)]
        public float MaskCutoff;

        [Range(0.0f, 1.0f)]
        public float Bias;

        [Range(0.0f, 1.0f)]
        public float Scale;

        [Range(0.0f, 1.0f)]
        public float BumpBlur;

        public Vector3 Absorption;
        public Vector3 AoColorBleed;
    }

    [Serializable]
    public struct TransmissionSettingsData {
        public bool Enabled;

        [Range(0.0f, 1.0f)] 
        public float Weight;

        [Range(0.0f, 1.0f)]
        public float ShadowWeight;

        [Range(0.0f, 1.0f)]
        [Tooltip("Amount that the transmission is distorted by surface normals.")]
        public float BumpDistortion;

        [MinValue(1.0f)] 
        public float Falloff;
    }

    public SkinSettingsData SkinSettings = new SkinSettingsData() {
        Enabled = true,
        Weight = 1.0f,
        MaskCutoff = 0.1f,
        Bias = 0.0f,
        Scale = 1.0f,
        BumpBlur = 0.7f,
        Absorption = new Vector3(-8.0f, -40.0f, -64.0f),
        AoColorBleed = new Vector3(0.4f, 0.15f, 0.13f),
    };

    public TransmissionSettingsData TransmissionSettings = new TransmissionSettingsData {
        Enabled = true,
        Weight = 1.0f,
        ShadowWeight = 0.5f,
        BumpDistortion = 0.05f,
        Falloff = 1.0f
    };

    // LUT
    [HideInInspector] public Texture2D SkinLut;

    // Shaders
    [HideInInspector] public Shader TransmissionBlitShader;
    [HideInInspector] public Shader BlurNormalsShader;

    // Private
    private Material m_deferredTransmissionBlitMaterial;
    private Material m_deferredBlurredNormalsMaterial;

    private Camera m_camera;
    private bool m_isTransmissionEnabled;
    private bool m_isScatteringEnabled;

    private CommandBuffer m_copyTransmission;
    private CommandBuffer m_renderBlurredNormals;

#if UNITY_EDITOR
    private int lastWidth = 0;
    private int lastHeight = 0;
#endif
    
    private void Awake() {
        m_camera = GetComponent<Camera>();
    }

    private void Reset() {
        ResetCommandBuffers();
    }

#if UNITY_EDITOR
    private void Update() {
        if (lastWidth != m_camera.pixelWidth
            || lastHeight != m_camera.pixelHeight) {
            ResetCommandBuffers();
        }
    }
#endif

    private void OnEnable() {
        ResetCommandBuffers();
    }

    private void OnDisable() {
        DestroyCommandBuffers();
    }

    private void OnDestroy() {
        DestroyCommandBuffers();
    }

    public void Refresh() {
        bool scatteringEnabled = SkinSettings.Enabled;
        bool transmissionEnabled = TransmissionSettings.Enabled || scatteringEnabled;

        if (m_isTransmissionEnabled == transmissionEnabled
            && m_isScatteringEnabled == scatteringEnabled) {
            RefreshProperties();
        } 
        else {
            ResetCommandBuffers();
        }
    }

    // Per camera properties.
    private void RefreshProperties() {
        if (m_isTransmissionEnabled || m_isScatteringEnabled) {
            float transmissionWeight = m_isTransmissionEnabled ? Mathf.GammaToLinearSpace(TransmissionSettings.Weight) : 0.0f;

            Shader.SetGlobalVector("_DeferredTransmissionParams",
                new Vector4(transmissionWeight, TransmissionSettings.Falloff, TransmissionSettings.BumpDistortion, TransmissionSettings.ShadowWeight));

            if (m_isScatteringEnabled) {
                // Blur shaders.
                float distanceToProjectionWindow = 1.0f / Mathf.Tan(0.5f * Mathf.Deg2Rad * m_camera.fieldOfView);
                float blurStepScale = c_blurWdith * distanceToProjectionWindow;
                float blurDepthDifferenceScale = c_blurDepthDifferenceMultiplier * distanceToProjectionWindow;

                Shader.SetGlobalVector("_DeferredBlurredNormalsParams", new Vector2(blurStepScale, blurDepthDifferenceScale));

                // Material shaders.
                var absorption = SkinSettings.Absorption;
                var aoColorBleed = SkinSettings.AoColorBleed;

                Shader.SetGlobalTexture("_DeferredSkinLut", SkinSettings.Lut);
                Shader.SetGlobalVector("_DeferredSkinParams", new Vector3(SkinSettings.Weight, 1.0f / SkinSettings.MaskCutoff, SkinSettings.BumpBlur));
                Shader.SetGlobalVector("_DeferredSkinTransmissionAbsorption", new Vector4(absorption.x, absorption.y, absorption.z, SkinSettings.Bias));
                Shader.SetGlobalVector("_DeferredSkinColorBleedAoWeights", new Vector4(aoColorBleed.x, aoColorBleed.y, aoColorBleed.z, SkinSettings.Scale));
            }
        }
    }

    private void ResetCommandBuffers() {
        m_isScatteringEnabled = SkinSettings.Enabled;
        m_isTransmissionEnabled = TransmissionSettings.Enabled || m_isScatteringEnabled;

        if (SkinSettings.Lut == null) {
            SkinSettings.Lut = SkinLut;

#if UNITY_EDITOR
            EditorUtility.SetDirty(this);
#endif
        }

        DestroyCommandBuffers();

        if ((m_isTransmissionEnabled || m_isScatteringEnabled)
            && m_camera != null
            && TransmissionBlitShader != null) {
            int outputRT = Shader.PropertyToID("_DeferredPlusBuffer");

#if UNITY_EDITOR
            // Reference for when screen size changes.
            lastWidth = m_camera.pixelWidth;
            lastHeight = m_camera.pixelHeight;
#endif

            m_deferredTransmissionBlitMaterial = new Material(TransmissionBlitShader);
            m_deferredTransmissionBlitMaterial.hideFlags = HideFlags.HideAndDontSave;

            // Copy Gbuffer emission buffer so we can get at the alpha channel for transmission.
            m_copyTransmission = new CommandBuffer();
            m_copyTransmission.name = c_copyTransmissionBufferName;
            
            if (!m_isScatteringEnabled) {
                // Copy transmission from emission buffer alpha.
                m_copyTransmission.GetTemporaryRT(outputRT, -1, -1, 0, FilterMode.Point, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
                m_copyTransmission.Blit(BuiltinRenderTextureType.CameraTarget, outputRT, m_deferredTransmissionBlitMaterial);
                m_copyTransmission.ReleaseTemporaryRT(outputRT);
            }
            else if (BlurNormalsShader != null) {
                int halfWidth = m_camera.pixelWidth / 2;
                int halfHeight = m_camera.pixelHeight / 2;
                int pingRT = Shader.PropertyToID("_DeferredBlurredNormalPingBuffer");
                int pongRT = Shader.PropertyToID("_DeferredBlurredNormalPongBuffer");

                // Bind emission buffer to be copied in blurred normal upsample pass.
                m_copyTransmission.SetGlobalTexture("_DeferredTransmissionBuffer", BuiltinRenderTextureType.CameraTarget);

                // Blur normals and copy transmission.
                m_deferredBlurredNormalsMaterial = new Material(BlurNormalsShader);
                m_deferredBlurredNormalsMaterial.hideFlags = HideFlags.HideAndDontSave;

                m_renderBlurredNormals = new CommandBuffer();
                m_renderBlurredNormals.name = c_blurNormalsBufferName;

                // RGBA8 target has sufficient precision for normals that are smooth and diffuse-only.
                m_renderBlurredNormals.GetTemporaryRT(outputRT, -1, -1, 0, FilterMode.Point, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
                m_renderBlurredNormals.GetTemporaryRT(pingRT, halfWidth, halfHeight, 0, FilterMode.Point, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear);
                m_renderBlurredNormals.GetTemporaryRT(pongRT, halfWidth, halfHeight, 0, FilterMode.Point, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear);
                    
                // Downsample, Blur X, Blur Y, Upsample.
                m_renderBlurredNormals.Blit(BuiltinRenderTextureType.GBuffer2, pingRT, m_deferredBlurredNormalsMaterial, 0);
                m_renderBlurredNormals.Blit(pingRT, pongRT, m_deferredBlurredNormalsMaterial, 1);
                m_renderBlurredNormals.Blit(pongRT, pingRT, m_deferredBlurredNormalsMaterial, 2);
                m_renderBlurredNormals.Blit(pingRT, outputRT, m_deferredBlurredNormalsMaterial, 3);

                // Cleanup.
                m_renderBlurredNormals.ReleaseTemporaryRT(outputRT);
                m_renderBlurredNormals.ReleaseTemporaryRT(pingRT);
                m_renderBlurredNormals.ReleaseTemporaryRT(pongRT);

                // Need depth texture for depth-aware upsample.
                m_camera.depthTextureMode |= DepthTextureMode.Depth;
                m_camera.AddCommandBuffer(c_blurNormalsEvent, m_renderBlurredNormals);
            }

            m_camera.AddCommandBuffer(c_copyTransmissionEvent, m_copyTransmission);
        }

        RefreshProperties();

#if UNITY_EDITOR
        EditorUtility.SetDirty(m_camera);
#endif
    }

    private void DestroyCommandBuffers() {
        if (m_copyTransmission != null) {
            m_camera.RemoveCommandBuffer(c_copyTransmissionEvent, m_copyTransmission);
        }

        if (m_renderBlurredNormals != null) {
            m_camera.RemoveCommandBuffer(c_blurNormalsEvent, m_renderBlurredNormals);
        }

        if (m_deferredTransmissionBlitMaterial != null) {
            DestroyImmediate(m_deferredTransmissionBlitMaterial);
        }

        if (m_deferredBlurredNormalsMaterial != null) {
            DestroyImmediate(m_deferredBlurredNormalsMaterial);
        }

        m_copyTransmission = null;
        m_renderBlurredNormals = null;
        m_deferredTransmissionBlitMaterial = null;
        m_deferredBlurredNormalsMaterial = null;
    }
}