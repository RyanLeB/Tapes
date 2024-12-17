Shader "Custom/VHS_Effect"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" { }
        _NoiseTex ("Noise Texture", 2D) = "white" { }
        _ScanlineIntensity ("Scanline Intensity", Range(0, 1)) = 0.1
        _FlickerIntensity ("Flicker Intensity", Range(0, 1)) = 0.05
        _RGBShift ("RGB Shift", Range(0, 0.1)) = 0.05
        _NoiseSpeed ("Noise Speed", Range(0, 5)) = 1.0
        _FlickerSpeed ("Flicker Speed", Range(0, 5)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;  // Vertex position
                float2 uv : TEXCOORD0;     // Texture coordinates
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // Shader parameters
            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float _ScanlineIntensity;
            float _FlickerIntensity;
            float _RGBShift;
            float _NoiseSpeed;
            float _FlickerSpeed;

            // Vertex shader
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Transform to clip space
                o.uv = v.uv;
                return o;
            }

            // Fragment shader
            float4 frag(v2f i) : SV_Target
            {
                // Moving noise (simulated static)
                float noise = tex2D(_NoiseTex, i.uv * 5.0 + float2(sin(_Time.y * _NoiseSpeed), cos(_Time.y * _NoiseSpeed))) * 0.2;

                // Flickering effect (using a sine wave)
                float flicker = sin(_Time.y * _FlickerSpeed) * _FlickerIntensity;

                // Apply scanlines (based on UVs and time for flickering)
                float scanline = sin(i.uv.y * 200.0 + _Time.y * 5.0) * _ScanlineIntensity;

                // RGB channel shift (simulating color separation)
                float2 rgbShift = float2(_RGBShift * sin(_Time.y * 0.1), _RGBShift * cos(_Time.y * 0.1));
                float4 texColor = tex2D(_MainTex, i.uv + rgbShift);

                // Add static noise and scanline effects
                texColor.rgb += noise + scanline + flicker;

                return texColor;
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
