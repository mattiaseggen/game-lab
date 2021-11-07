Shader "Custom/TextureShader"
{
    Properties
    {
        _SlopeTex ("Slope Texture ", 2D)  = "white" {}
        _BottomTex ("Bottom Texture ", 2D)  = "white" {}
        _MiddleTex ("Middle Texture ", 2D)  = "white" {}
        _TopTex ("Top Texture ", 2D)  = "white" {}
        [NoScaleOffset] _BumpMapSlope("Normal Map Slope", 2D) = "bump" {}
        [NoScaleOffset] _BumpMapBottom("Normal Map Bottom", 2D) = "bump" {}
        [NoScaleOffset] _BumpMapMiddle("Normal Map Middle", 2D) = "bump" {}
        [NoScaleOffset] _BumpMapTop("Normal Map Top", 2D) = "bump" {}
        _Glossiness("Smoothness", Range(0, 1)) = 0.5
        [Gamma] _Metallic("Metallic", Range(0, 1)) = 0
		_TextureScale ("Texture Scale",float) = 1
		_TriplanarBlendSharpness ("Blend Sharpness",float) = 1
        _BlendSize ("Blend size", float) = 0.05
        _SlopeBlendSize ("Slope Blend size", Range(0,0.3)) = 0.1
        [HideInInspector]_MaxHeight ("Highest", float) = 0
        [HideInInspector]_MinHeight ("Lowest", float) = 0
        _UpperLimit ("Upper limit", Range(0.3, 1)) = 0.5
        _LowerLimit ("Lower limit", Range(0, 0.3)) = 0.03
        _SlopeLimit ("Slope limit", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        #pragma target 3.0

        sampler2D _SlopeTex;
        sampler2D _BottomTex;
        sampler2D _MiddleTex;
        sampler2D _TopTex;
        sampler2D _BumpMapSlope;
        sampler2D _BumpMapBottom;
        sampler2D _BumpMapMiddle;
        sampler2D _BumpMapTop;
        fixed4 _Color;

        float _TextureScale;
        float _TriplanarBlendSharpness;
        float _BlendSize;
        float _SlopeBlendSize;
        float _MinHeight;
        float _MaxHeight;
        float _LowerLimit;
        float _UpperLimit;
        float _SlopeLimit;

        half _Glossiness;
        half _Metallic;

        half3 blend_rnm(half3 n1, half3 n2)
        {
            n1.z += 1;
            n2.xy = -n2.xy;

            return n1 * dot(n1, n2) / n1.z - n2;
        }

        struct Input
        {
            float3 worldPos;
            float3 worldNormal;
            INTERNAL_DATA
        };

        float3 WorldToTangentNormalVector(Input IN, float3 normal) {
            float3 t2w0 = WorldNormalVector(IN, float3(1,0,0));
            float3 t2w1 = WorldNormalVector(IN, float3(0,1,0));
            float3 t2w2 = WorldNormalVector(IN, float3(0,0,1));
            float3x3 t2w = float3x3(t2w0, t2w1, t2w2);
            return normalize(mul(t2w, normal));
        }

        	void surf (Input IN, inout SurfaceOutputStandard o) 
		{
            IN.worldNormal = WorldNormalVector(IN, float3(0,0,1));

            // calculate triplanar blend
            half3 triblend = saturate(pow(IN.worldNormal, 4));
            triblend /= max(dot(triblend, half3(1,1,1)), 0.0001);

			half2 uvX = IN.worldPos.zy / _TextureScale;
			half2 uvY = IN.worldPos.xz / _TextureScale;
			half2 uvZ = IN.worldPos.xy / _TextureScale;
             
           // offset UVs to prevent obvious mirroring
        #if defined(TRIPLANAR_UV_OFFSET)
            uvY += 0.33;
            uvZ += 0.67;
        #endif

            half3 axisSign = IN.worldNormal < 0 ? -1 : 1;
            
            // flip UVs horizontally to correct for back side projection
        #if defined(TRIPLANAR_CORRECT_PROJECTED_U)
            uvX.x *= axisSign.x;
            uvY.x *= axisSign.y;
            uvZ.x *= -axisSign.z;
        #endif

            half3 colY;
		    half3 colX;
		    half3 colZ;

            half3 tnormalX;
            half3 tnormalY;
            half3 tnormalZ;

            sampler2D blendTexture;

            //Normalise height of current vertex position
            float normHeight = (IN.worldPos.y - _MinHeight) / (_MaxHeight - _MinHeight);
            float blendValue;
            float slope = 1.0f - IN.worldNormal.y;

            if (normHeight < _LowerLimit)
            {
                colX = tex2D (_BottomTex, uvX);
                colY = tex2D (_BottomTex, uvY);
                colZ = tex2D (_BottomTex, uvZ);
                tnormalY = UnpackNormal(tex2D(_BumpMapBottom, uvY));
                tnormalX = UnpackNormal(tex2D(_BumpMapBottom, uvX));
                tnormalZ = UnpackNormal(tex2D(_BumpMapBottom, uvZ));
                blendTexture = _BottomTex;
            }
            else if (normHeight < _LowerLimit + _BlendSize)
            {
                blendValue = (normHeight - _LowerLimit) / _BlendSize;
                colX = lerp (tex2D (_BottomTex, uvX), tex2D (_MiddleTex, uvX), blendValue);
                colY = lerp (tex2D (_BottomTex, uvY), tex2D (_MiddleTex, uvY), blendValue);
                colZ = lerp (tex2D (_BottomTex, uvZ), tex2D (_MiddleTex, uvZ), blendValue);
                tnormalX = UnpackNormal(lerp(tex2D(_BumpMapBottom, uvX), tex2D(_BumpMapMiddle, uvX), blendValue));
                tnormalY = UnpackNormal(lerp(tex2D(_BumpMapBottom, uvY), tex2D(_BumpMapMiddle, uvY), blendValue));
                tnormalZ = UnpackNormal(lerp(tex2D(_BumpMapBottom, uvZ), tex2D(_BumpMapMiddle, uvZ), blendValue));

            }
            else if (normHeight < _UpperLimit)
            {
                colX = tex2D (_MiddleTex, uvX);
                colY = tex2D (_MiddleTex, uvY);
                colZ = tex2D (_MiddleTex, uvZ);
                tnormalY = UnpackNormal(tex2D(_BumpMapMiddle, uvY));
                tnormalX = UnpackNormal(tex2D(_BumpMapMiddle, uvX));
                tnormalZ = UnpackNormal(tex2D(_BumpMapMiddle, uvZ));
            }
            else if (normHeight < _UpperLimit + _BlendSize)
            {
                blendValue = (normHeight - _UpperLimit) / _BlendSize;
                colX = lerp (tex2D (_MiddleTex, uvX), tex2D (_TopTex, uvX), blendValue);
                colY = lerp (tex2D (_MiddleTex, uvY), tex2D (_TopTex, uvY), blendValue);
                colZ = lerp (tex2D (_MiddleTex, uvZ), tex2D (_TopTex, uvZ), blendValue);
                tnormalX = UnpackNormal(lerp(tex2D(_BumpMapMiddle, uvX), tex2D(_BumpMapTop, uvX), blendValue));
                tnormalY = UnpackNormal(lerp(tex2D(_BumpMapMiddle, uvY), tex2D(_BumpMapTop, uvY), blendValue));
                tnormalZ = UnpackNormal(lerp(tex2D(_BumpMapMiddle, uvZ), tex2D(_BumpMapTop, uvZ), blendValue));
            }
            else
            {
                colX = tex2D (_TopTex, uvX);
                colY = tex2D (_TopTex, uvY);
                colZ = tex2D (_TopTex, uvZ);
                tnormalY = UnpackNormal(tex2D(_BumpMapTop, uvY));
                tnormalX = UnpackNormal(tex2D(_BumpMapTop, uvX));
                tnormalZ = UnpackNormal(tex2D(_BumpMapTop, uvZ));
            }

            float slopeBlend = smoothstep(_SlopeLimit - _SlopeBlendSize, _SlopeLimit, slope);

            if (slope > _SlopeLimit)
            {
                colX = tex2D (_SlopeTex, uvX);
                colY = tex2D (_SlopeTex, uvY);
                colZ = tex2D (_SlopeTex, uvZ);
                tnormalY = UnpackNormal(tex2D(_BumpMapSlope, uvY));
                tnormalX = UnpackNormal(tex2D(_BumpMapSlope, uvX));
                tnormalZ = UnpackNormal(tex2D(_BumpMapSlope, uvZ));
            }

            if (slope < _SlopeLimit && slope > _SlopeLimit - _SlopeBlendSize)
            {        
                colX = lerp (colX, tex2D (_SlopeTex, uvX), slopeBlend);
                colY = lerp (colY, tex2D (_SlopeTex, uvY), slopeBlend);
                colZ = lerp (colZ, tex2D (_SlopeTex, uvZ), slopeBlend);
                tnormalX = UnpackNormal(lerp(tex2D(_BumpMapMiddle, uvX), tex2D(_BumpMapSlope, uvX), slopeBlend));
                tnormalY = UnpackNormal(lerp(tex2D(_BumpMapMiddle, uvY), tex2D(_BumpMapSlope, uvY), slopeBlend));
                tnormalZ = UnpackNormal(lerp(tex2D(_BumpMapMiddle, uvZ), tex2D(_BumpMapSlope, uvZ), slopeBlend));
            }

            // flip normal maps' x axis to account for flipped UVs
        #if defined(TRIPLANAR_CORRECT_PROJECTED_U)
            tnormalX.x *= axisSign.x;
            tnormalY.x *= axisSign.y;
            tnormalZ.x *= -axisSign.z;
        #endif

            half3 absVertNormal = abs(IN.worldNormal);
            
            // swizzle world normals to match tangent space and apply reoriented normal mapping blend
            tnormalX = blend_rnm(half3(IN.worldNormal.zy, absVertNormal.x), tnormalX);
            tnormalY = blend_rnm(half3(IN.worldNormal.xz, absVertNormal.y), tnormalY);
            tnormalZ = blend_rnm(half3(IN.worldNormal.xy, absVertNormal.z), tnormalZ);
            
            // apply world space sign to tangent space Z
            tnormalX.z *= axisSign.x;
            tnormalY.z *= axisSign.y;
            tnormalZ.z *= axisSign.z;

            // sizzle tangent normals to match world normal and blend together
            half3 worldNormal = normalize(
                tnormalX.zyx * triblend.x +
                tnormalY.xzy * triblend.y +
                tnormalZ.xyz * triblend.z
                );

            // Get the absolute value of the world normal.
			// Put the blend weights to the power of BlendSharpness, the higher the value, 
            // the sharper the transition between the planar maps will be.
			half3 blendWeights = pow (abs(IN.worldNormal), _TriplanarBlendSharpness);
			// Divide our blend mask by the sum of it's components, this will make x+y+z=1
			blendWeights = blendWeights / (blendWeights.x + blendWeights.y + blendWeights.z);
			// Finally, blend together all three samples based on the blend mask.

            o.Albedo = colX * blendWeights.x + colY * blendWeights.y + colZ * blendWeights.z;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Normal = WorldToTangentNormalVector(IN, worldNormal);
		}
		ENDCG
    }
    FallBack "Diffuse"
}
