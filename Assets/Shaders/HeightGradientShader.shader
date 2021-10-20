Shader "Custom/HeightGradientShader"
{
    Properties
    {
       [PerRendererData] _MainTex ("Main Texture", 2D) = "white" {}
        _ColorBot ("Bottom Color", Color) = (1,1,1,1)
        _ColorMid ("Middle Color", Color) = (1,1,1,1)
        _ColorTop ("Top Color", Color) = (1,1,1,1)
        _Median ("Median", Range(0.001, 0.999)) = 0.5
        _MinHeight ("Lowest", float) = 0
        _MaxHeight ("Highest", float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        fixed4 _ColorBot; 
        fixed4 _ColorMid;
        fixed4 _ColorTop;
        float _Median;
        float _MinHeight;
        float _MaxHeight;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        UNITY_INSTANCING_BUFFER_START(Props)

        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float dist = (IN.worldPos.y - _MinHeight) / (_MaxHeight - _MinHeight);
    
            fixed4 c = lerp(_ColorBot, _ColorMid, dist / _Median) * step(dist, _Median);
            c += lerp(_ColorMid, _ColorTop, (dist - _Median) / (1 - _Median)) * step(_Median, dist);

            o.Albedo = c.rgb;
            
        }
        ENDCG
    }
    FallBack "Diffuse"
}
