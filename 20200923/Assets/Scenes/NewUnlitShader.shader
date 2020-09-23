Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _AmbientRate("Ambient Rate",Range(0,1)) = 0.2
        _SpecularColor("Specular Color",Color) = (0.5,0.5,0.5,1.0)
        _SpecularPower("Specular Power",Range(0,200)) = 80
    }
    SubShader
    {
        Tags {
            "RenderType" = "Opaque"
            "LightMode" = "ForwardBase"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
            float3 normal:TEXCOORD1;
            float3 viewDir:TEXCOORD2;
            UNITY_FOG_COORDS(1)
        };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform float _AmbientRate;
            uniform float _SpecularPower;
            uniform float3 _SpecularColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                float3 N = normalize(i.normal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 V = normalize(i.viewDir);

                float4 albedo = tex2D(_MainTex, i.uv);
                float3 ambient = _LightColor0.xyz * albedo.xyz;
                float3 NL = dot(N, L);
                float3 diffuse = _LightColor0.xyz * albedo.xyz * max(0.0, NL);
                float3 lambert = _AmbientRate * ambient + (1.0 - _AmbientRate) * diffuse;

                float3 H = normalize(V + L);
                float3 specular = _LightColor0.xyz * _SpecularColor * pow(max(0.0, dot(H, N)), _SpecularPower);

                float4 col = float4(lambert + specular, 1.0);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
