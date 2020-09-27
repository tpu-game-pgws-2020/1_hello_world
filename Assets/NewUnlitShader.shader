Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AmbientRate("ambient Rate",Range(0,1))=0.2
        _SpecularColor("specular Color",Color)=(0.5,0.5,0.5,1.0)
        _SpecularPower("specular Power",Range(0,200))=80

    }
    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "LightMode"="ForwardBase"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog// 霧が効くようにする

            #include "UnityCG.cginc"
            #include "Lighting.cginc"// 光源の情報を取り込む

            struct appdata
            {
                float4 vertex : POSITION;// 位置
                float2 uv : TEXCOORD0;// テクスチャ位置
                float3 normal:NORMAL;// 法線
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal:TEXCOORD1;
                float3 viewDir:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform float _AmbientRate;
            uniform float _SpecularPower;
            uniform float _SpecularColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal=UnityObjectToWorldNormal(v.normal);
                o.viewDir=WorldSpaceViewDir(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //正当化された方向の取得
                float3 N=normalize(i.normal);
                float3 L=normalize(_WorldSpaceLightPos0.xyz);
                float3 V=normalize(i.viewDir);

                //拡散反射光+環境光
                float4 albedo=tex2D(_MainTex,i.uv);
                float3 ambient=_LightColor0.xyz*albedo.xyz;
                float3 NL=dot(N,L);
                float3 diffuse=_LightColor0.xyz*albedo.xyz*max(0.0,NL);
                float3 lambert=_AmbientRate*ambient+(1.0-_AmbientRate) * diffuse;

                //鏡面反射光 (Blinn-Phong)
                float3 H=normalize(V+L);
                float3 specular=_LightColor0.xyz*_SpecularColor*pow(max(0.0,dot(H,N)),_SpecularPower);

                //統合
                float4 col=float4(lambert+specular,1.0);
                UNITY_APPLY_FOG(i.fogCoord,col);//霧

                return col;
            }
            ENDCG
        }
    }
}
