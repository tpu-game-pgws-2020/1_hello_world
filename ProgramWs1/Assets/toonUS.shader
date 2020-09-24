Shader "Unlit/toonUS"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_RampTex("Ramp", 2D) = "white"{}
		_Color("Color", Color) = (1,1,1,1)
		_AmbientRate("AmbientRate", Range(0,1)) = 0.2
	}
		SubShader
		{
			Tags {
				"RenderType" = "Opaque"
				"LightMode" = "ForwardBase"
			}
			LOD 200

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
					float3 normal : NORMAL;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					float4 vertex : SV_POSITION;
					float3 normal : TEXCOORD1;
					float3 viewDir: TEXCOORD2;
				};

				sampler2D _MainTex;
				sampler2D _RampTex;
				float4 _MainTex_ST;
				uniform float _AmbientRate;
				fixed4 _Color;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.normal = UnityObjectToWorldNormal(v.vertex);
					o.viewDir = WorldSpaceViewDir(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float3 N = normalize(i.normal);
					float3 L = normalize(_WorldSpaceLightPos0.xyz);

					float4 albedo = tex2D(_MainTex, i.uv) * _Color;
					half NL = dot(N, L) * 0.5 + 0.5;

					float4 col;
					col.rgb = albedo.rgb * _LightColor0.rgb * tex2D(_RampTex, fixed2(NL, 1.0)).rgb;
					col.a = 0;
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG
			}
		}
}
