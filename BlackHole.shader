Shader "BlackHole" {
	
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_dist("Black & White blend", Range(0, 1)) = 0
	}

	SubShader{
	Pass{
		CGPROGRAM
		#pragma vertex vert_img
		#pragma fragment frag

		#include "UnityCG.cginc"

		uniform sampler2D _MainTex;
		uniform float _dist;
		uniform float2 screenPos;
		uniform float IOR;
		uniform float black_r1;
		uniform float black_r2;
		uniform float rad;


		float4 frag(v2f_img i) : COLOR
		{
			float4 c;

			float aspect = _ScreenParams.x / _ScreenParams.y;
			float2 balanced = i.uv - screenPos;
			balanced.x *= aspect;
			float distance = length(balanced);
			float2 balanced_n = balanced / distance;
		
			
			if (distance < black_r1)
			{
				c = float4(0, 0, 0, 0); // absolutely black
			}
			else
			{
				float2 pos = i.uv;
				pos.x = pos.x * _ScreenParams.x;
				pos.y = pos.y * _ScreenParams.y;
				float scaled = distance * _dist / rad;
				float3 rayDirection = float3(0, 0, 1);
				float3 surfaceNormal = normalize(float3(balanced_n, scaled * scaled));
				float3 newBeam = refract(rayDirection, surfaceNormal, IOR);
				float2 offset = float2(newBeam.x, newBeam.y) * 200;
				
				// radial
				//float2 offsetR;
				//float t = 0.035 / distance;
				//offsetR.x = offset.x * cos(t) - offset.y * sin(t);
				//offsetR.y = offset.x * sin(t) + offset.y * cos(t);

				float2 newPos = pos +  offset;
				c = tex2D(_MainTex, newPos / _ScreenParams);
				c *= length(newBeam);
				c.a = 1.0f;

				// blend between two circles
				if (black_r1 < distance && distance < black_r2)
				{
					c = c * (distance - black_r1) / (black_r2 - black_r1);
				}
			}

			return c;
		}
		ENDCG
	}
	}
}