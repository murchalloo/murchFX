# murchFX
Here will be stored my shaders for Reshade. They are mainly desighed for using in virtual photography.

## DoubleExposure.fx
My first shader is made for, obviously, getting double exposures. There is a few types of blending sliders like Weight (how much first exposure affects the second one from 0 to 1) and Gamma (gamma curve affecting both first and second exposures to get a better blending between brighter areas of it). I hope someone find it useful.

## ChannelMixer.fx
Simple channel mixer shader from mixing or swapping image channels, could be useful to get different black and white images.

## DepthToAddon.fx
Shader for creating depth texture to use in [Frame Capture](https://github.com/murchalloo/reshade-addons/tree/main/99-frame_capture).
There is additional parameter for SRGB conversion [#define SRGB_CONVERTION] it can get more precision at far objects, but ruins the foreground, so it's 0 by default.
There is also additional parameter in the shader for exporting raw depth [#define EXPORT_NON_LINEARIZED] which is 0 by default, but if you want more precision (see image below for comparison), set it to 1.
![Comparison](https://github.com/murchalloo/image_host/raw/main/precision_comp.png?raw=true)
