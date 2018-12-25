// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Legacy Shaders/Decal" {
Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _DecalTex ("Decal (RGBA)", 2D) = "black" {}
	_DecalSizeAndPos1("Decal Size And Position (1)", Vector) = (1,1,0,0)
	_DecalOffset1("Decal Offset (1)", Vector) = (0,0,0,0)
	_DecalSizeAndPos2("Decal Size And Position (2)", Vector) = (1,1,0,0)
	_DecalOffset2("Decal Offset (2)", Vector) = (0,0,0,0)
	_DecalSizeAndPos3("Decal Size And Position (3)", Vector) = (1,1,0,0)
	_DecalOffset3("Decal Offset (3)", Vector) = (0,0,0,0)
	[KeywordEnum(Vert,Frag)]_DECAL_UV("How to calculate uv",Float)=0
}

SubShader{
		Pass {
			Tags{ "RenderType" = "Opaque" }
			CGPROGRAM
			#pragma shader_feature _DECAL_UV_VERT _DECAL_UV_FRAG
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DecalTex;
			float4 _DecalTex_ST;
			float4 _DecalSizeAndPos1;
			float4 _DecalOffset1;
			float4 _DecalSizeAndPos2;
			float4 _DecalOffset2;
			float4 _DecalSizeAndPos3;
			float4 _DecalOffset3;


			struct appdata
			{
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
			};
			struct v2f
			{
				float4 vertex:SV_Position;
				float2 uv:TEXCOORD0;
				#if _DECAL_UV_VERT
				float4 uv1:TEXCOORD1;
				float4 uv2:TEXCOORD2;
				float4 uv3:TEXCOORD3;
				#endif
			};

#define CAL_VERT_DECAL_UV(n) \
	{o.uv##n.zw=(v.uv-_DecalSizeAndPos##n.zw) / _DecalSizeAndPos##n / _DecalTex_ST.xy + float2(0.5, 0.5); \
	o.uv##n.xy=TRANSFORM_TEX(o.uv##n.zw, _DecalTex) + _DecalOffset##n.xy;}
#define CAL_FRAG_DECAL_RGB(n) \
	{half4 decal##n = tex2D(_DecalTex, i.uv##n); \
	c.rgb = lerp(c.rgb, decal##n.rgb, decal##n.a * step(0, i.uv##n.z) * step(0, i.uv##n.w) * step(i.uv##n.z, 1) * step(i.uv##n.w, 1));}
#define CAL_FRAG_DECAL_UI_RGB(n) \
	{float4 uv##n; \
	 uv##n.zw=(i.uv-_DecalSizeAndPos##n.zw) / _DecalSizeAndPos##n / _DecalTex_ST.xy + float2(0.5, 0.5); \
	 uv##n.xy=TRANSFORM_TEX(uv##n.zw, _DecalTex) + _DecalOffset##n.xy; \
	 half4 decal##n = tex2D(_DecalTex, uv##n); \
	 c.rgb = lerp(c.rgb, decal##n.rgb, decal##n.a * step(0, uv##n.z) * step(0, uv##n.w) * step(uv##n.z, 1) * step(uv##n.w, 1));}
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				#if _DECAL_UV_VERT
				CAL_VERT_DECAL_UV(1)
				CAL_VERT_DECAL_UV(2)
				CAL_VERT_DECAL_UV(3)
				#endif
				return o;
			}
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				#if _DECAL_UV_VERT
				CAL_FRAG_DECAL_RGB(1)
				CAL_FRAG_DECAL_RGB(2)
				CAL_FRAG_DECAL_RGB(3)
				#endif
				#if _DECAL_UV_FRAG
				CAL_FRAG_DECAL_UI_RGB(1)
				CAL_FRAG_DECAL_UI_RGB(2)
				CAL_FRAG_DECAL_UI_RGB(3)
				#endif
				c *= _Color;
				return c;
			}
			ENDCG
		}
	}
		Fallback "Legacy Shaders/Diffuse"
}
