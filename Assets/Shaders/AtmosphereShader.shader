Shader "Custom/Atmosphere"
{
    Properties
    {
        _MainColor("Main Color", COLOR) = (1,1,1,1)
        _AtmosphereColor("Atmosphere Color", COLOR) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _AtmosphereRadius("AtmosphereRadius", Float) = 0.1
        _Step("Step", Float) = 0
        _Pow("Pow", Range(1,30)) = 1
        _Degrees("Degrees", float) = 180
        _Strength("Strength", Range(0,1)) = 1 

        _Height("Height", Range(-1,1)) = 0
        _Seed("Seed", Range(0,10000)) = 10
    }
    SubShader
    {  
        Pass
        {
            Tags { "RenderType"="Opaque" }
            LOD 100

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 _MainColor;

            float _Height;
            float _Seed;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float hash(float2 st)
            {   
                return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

        float noise(float2 p, float size)
        {
            float result = 0;

            p *= size;
            float2 i = floor(p + _Seed);
            float2 f = frac(p + _Seed / 739);
            float2 e = float2(0, 1);

            float z0 = hash((i + e.xx) % size);
            float z1 = hash((i + e.yx) % size);
            float z2 = hash((i + e.xy) % size);
            float z3 = hash((i + e.yy) % size);
            float2 u = smoothstep(0, 1, f);

            result = lerp(z0, z1, u.x) + (z2 - z0) * u.y * (1.0 - u.x) + (z3 - z1) * u.x * u.y;

            return result;
        }

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                float height = noise(v.texcoord, 5) * 0.75 + noise(v.texcoord, 30) * 0.125 + noise(v.texcoord, 50) * 0.125;
                o.color.r = height + _Height;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv) * _MainColor;

                float height = i.color.r;
            if (height < 0.45)
            {
                color.x = 0.10;
                color.y = 0.30;
                color.z = 0.50;
            }
            else if (height < 0.75)
            {
                color.x = 0.10;
                color.y = 0.60;
                color.z = 0.30;
            }
            else
            {
                color.x = 0.60;
                color.y = 0.30;
                color.z = 0.30;
            }

                return color;
            }
            ENDCG
        } 

        Pass
        {
            Tags { "RenderType"="Transparent" "Queue"="Transparent" }
            LOD 100
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 dotProduct: TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _AtmosphereColor;

            float _AtmosphereRadius;
            float _Step;
            int _Pow;
            float _Degrees;
            float _Strength;

            v2f vert (appdata_full v)
            {
                v2f o;
                float4 cameraLocalPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
                float4 viewDir  = v.vertex - cameraLocalPos;
                float dotProduct = dot(v.normal, normalize(viewDir));
                v.vertex.xyz *= (1 + _AtmosphereRadius);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.dotProduct.x = abs( dotProduct);//*dotProduct;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed alpha = _Strength * pow(abs(sin(i.dotProduct.x*radians(_Degrees)+ _Step)), _Pow);
                fixed4 color = _AtmosphereColor;
                color.w = alpha;
                return color;
            }
            ENDCG
        }
    }
}
