//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// DoubleExposure.fx v0.1 made by murchalloo
// https://github.com/murchalloo/murchFX
// 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "Reshade.fxh"

namespace DoubleExposure {

    uniform bool FirstExposure <
        ui_tooltip = "Click to capture first image.";
        ui_label = "Grab First Exposure";
    > = false;
    uniform bool SecondExposure <
        ui_tooltip = "Click to capture second image.";
        ui_label = "Grab Second Exposure";
    > = false;
    uniform float Weight <
        ui_type = "slider";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.01;
        ui_tooltip = "Weight of first exposure.";
        ui_label = "Weight ratio";
    > = 0.5;
    uniform float Gamma <
        ui_type = "slider";
        ui_min = 0.01; ui_max = 4.44;
        ui_step = 0.01;
        ui_tooltip = "The gamma correction value for blending between exposures.";
        ui_label = "Gamma curve blending";
    > = 1;

    texture texDoubleExposureFirst{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; };
    texture texDoubleExposureSecond{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; };
    texture texSDoubleExposureFirst{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; };
    texture texSDoubleExposureSecond{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; };

    sampler2D samplerDoubleExposureFirst{ Texture = texDoubleExposureFirst; };
    sampler2D samplerDoubleExposureSecond{ Texture = texDoubleExposureSecond; };
    sampler2D samplerSDoubleExposureFirst{ Texture = texSDoubleExposureFirst; };
    sampler2D samplerSDoubleExposureSecond{ Texture = texSDoubleExposureSecond; };

    void first_Exposure(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 output : SV_Target)
    {
        float4 backBuffer = tex2D(ReShade::BackBuffer, texcoord);
        if (FirstExposure)
        {
            backBuffer = tex2D(samplerSDoubleExposureFirst, texcoord);
        }
        output = backBuffer;
    }

    void second_Exposure(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 output : SV_Target)
    {
        float4 backBuffer = tex2D(ReShade::BackBuffer, texcoord);
        if (SecondExposure)
        {
            backBuffer = tex2D(samplerSDoubleExposureSecond, texcoord);
        }
        output = backBuffer;
    }

    void double_Exposure(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 output : SV_Target)
    {
        float4 exposureFirst = pow(abs(tex2D(samplerSDoubleExposureFirst, texcoord)), Gamma);
        float4 exposureSecond = pow(abs(tex2D(samplerSDoubleExposureSecond, texcoord)), Gamma);

        float4 doubleExposure = pow(abs(((exposureFirst * Weight) + (exposureSecond * (1.0 - Weight)))), 1.0 / Gamma);

        output = doubleExposure;
    }

    void store_Exposures(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 output0 : SV_Target0, out float4 output1 : SV_Target1)
    {
        output0 = tex2D(samplerDoubleExposureFirst,texcoord);
        output1 = tex2D(samplerDoubleExposureSecond,texcoord);
    }

    technique DoubleExposure
    {
        pass GrabFirstExposurePass { 
            VertexShader = PostProcessVS; 
            PixelShader = first_Exposure;
            RenderTarget0 = texDoubleExposureFirst;
        }
        pass GrabSecondExposurePass { 
            VertexShader = PostProcessVS; 
            PixelShader = second_Exposure; 
            RenderTarget = texDoubleExposureSecond;
        }
		pass DoubleExposurePass { 
            VertexShader = PostProcessVS; 
            PixelShader = double_Exposure; 
        }
        pass store_Exposures {
            VertexShader = PostProcessVS;
            PixelShader = store_Exposures;
            RenderTarget0 = texSDoubleExposureFirst;
            RenderTarget1 = texSDoubleExposureSecond;
        }
    }
}