//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// DepthToAddon.fx v1.0 made by murchalloo
// https://github.com/murchalloo/murchFX
// 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "ReShade.fxh"

namespace DepthToAddon {
	
	texture DepthToAddonTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; };

	float GetLinearizedDepth(float2 texcoord)
	{
		if (RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN) // RESHADE_DEPTH_INPUT_IS_UPSIDE_DOWN
			texcoord.y = 1.0 - texcoord.y;

		texcoord.x /= RESHADE_DEPTH_INPUT_X_SCALE;
		texcoord.y /= RESHADE_DEPTH_INPUT_Y_SCALE;
		texcoord.x -= RESHADE_DEPTH_INPUT_X_PIXEL_OFFSET * RESHADE_DEPTH_INPUT_X_PIXEL_OFFSET;
		texcoord.y += RESHADE_DEPTH_INPUT_Y_PIXEL_OFFSET * BUFFER_RCP_HEIGHT;

		float depth = tex2Dlod(ReShade::DepthBuffer, float4(texcoord, 0, 0)).x;

		const float C = 0.01;
		if (RESHADE_DEPTH_INPUT_IS_LOGARITHMIC)
			depth = (exp(depth * log(C + 1.0)) - 1.0) / C;

		if (RESHADE_DEPTH_INPUT_IS_REVERSED)
			depth = 1.0 - depth;

		const float N = 1.0;
		depth /= RESHADE_DEPTH_LINEARIZATION_FAR_PLANE - depth * (RESHADE_DEPTH_LINEARIZATION_FAR_PLANE - N);

		return depth;
	}

	float3 GetScreenSpaceNormal(float2 texcoord)
	{
		float3 offset = float3(BUFFER_PIXEL_SIZE, 0.0);
		float2 posCenter = texcoord.xy;
		float2 posNorth  = posCenter - offset.zy;
		float2 posEast   = posCenter + offset.xz;

		float3 vertCenter = float3(posCenter - 0.5, 1) * ReShade::GetLinearizedDepth(posCenter);
		float3 vertNorth  = float3(posNorth - 0.5,  1) * ReShade::GetLinearizedDepth(posNorth);
		float3 vertEast   = float3(posEast - 0.5,   1) * ReShade::GetLinearizedDepth(posEast);

		return normalize(cross(vertCenter - vertNorth, vertCenter - vertEast)) * 0.5 + 0.5;
	}

	void PS_DepthToAddon(in float4 position : SV_Position, in float2 texcoord : TEXCOORD, out float4 color : SV_Target)
	{
		float depth = GetLinearizedDepth(texcoord).x;
		//float3 normal = GetScreenSpaceNormal(texcoord);
		color = depth.xxx;
	}

	technique DepthToAddon
	{
		pass
		{
			VertexShader = PostProcessVS;
			PixelShader = PS_DepthToAddon;
			RenderTarget = DepthToAddonTex;
		}
	}
}
