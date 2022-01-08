//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// ChannelMixer.fx v0.2 made by murchalloo
// https://github.com/murchalloo/murchFX
// 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "Reshade.fxh"

namespace ChannelMixer {

    uniform bool BlackWhite <
	ui_label = "Black and White";
	> = false;
    uniform float3 RedM <
        ui_type = "drag";
        ui_min = -200.0; ui_max = 200.0;
        ui_step = 1.0;
        ui_label = "Red channel mix";
    > = float3(100.0, 0.0, 0.0);
    uniform float RedMult <
        ui_type = "drag";
        ui_min = -200.0; ui_max = 200.0;
        ui_step = 1.0;
        ui_label = "Red channel boost";
    > = 0.0;
    uniform float3 GreenM <
        ui_type = "drag";
        ui_min = -200.0; ui_max = 200.0;
        ui_step = 1.0;
        ui_label = "Green channel mix";
    > = float3(0.0, 100.0, 0.0);
    uniform float GreenMult <
        ui_type = "drag";
        ui_min = -200.0; ui_max = 200.0;
        ui_step = 1.0;
        ui_label = "Green channel boost";
    > = 0.0;
    uniform float3 BlueM <
        ui_type = "drag";
        ui_min = -200.0; ui_max = 200.0;
        ui_step = 1.0;
        ui_label = "Blue channel mix";
    > = float3(0.0, 0.0, 100.0);
    uniform float BlueMult <
        ui_type = "drag";
        ui_min = -200.0; ui_max = 200.0;
        ui_step = 1.0;
        ui_label = "Blue channel boost";
    > = 0.0;

    void channel_Mixer(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 output : SV_Target)
    {
        float4 backBuffer = tex2D(ReShade::BackBuffer, texcoord);
        float redChannel = (backBuffer.r * (RedM.x/100.0) + RedMult/500.0) + (backBuffer.g * (RedM.y/100.0) + RedMult/500.0) + (backBuffer.b * (RedM.z/100.0) + RedMult/500.0);
        float greenChannel = (backBuffer.r * (GreenM.x/100.0) + GreenMult/500.0) + (backBuffer.g * (GreenM.y/100.0) + GreenMult/500.0) + (backBuffer.b * (GreenM.z/100.0) + GreenMult/500.0);
        float blueChannel = (backBuffer.r * (BlueM.x/100.0) + BlueMult/500.0) + (backBuffer.g * (BlueM.y/100.0) + BlueMult/500.0) + (backBuffer.b * (BlueM.z/100.0) + BlueMult/500.0);
        float4 channelMixer;
        if (BlackWhite) {
            float bnwMix = (redChannel + greenChannel + blueChannel) / 3.0;
            channelMixer = float4(bnwMix,bnwMix,bnwMix,1.0);
        } else {
            channelMixer = float4(redChannel,greenChannel,blueChannel,1.0);
        }
        output = channelMixer;
    }

    technique ChannelMixer
    {
	    pass ChannelMixerPass { 
            VertexShader = PostProcessVS; 
            PixelShader = channel_Mixer; 
        }
    }
}
