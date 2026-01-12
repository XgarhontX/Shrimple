#define RENDER_FINAL
#define RENDER_FRAG

#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in vec2 texcoord;

uniform sampler2D colortex0;

#ifdef EFFECT_FXAA_ENABLED
	uniform vec2 pixelSize;
#endif

#ifdef DISTANT_HORIZONS
	uniform float dhFarPlane;
#endif

#include "/lib/sampling/bayer.glsl"

#ifdef EFFECT_FXAA_ENABLED
	#include "/lib/effects/fxaa.glsl"
#endif

#ifndef IS_IRIS
	#include "/lib/utility/iris.glsl"
#endif

#define RENODX_WORKING_COLORSPACE RENODX_BT709
#include "/renodx.glsl"

void main() {
	#ifdef EFFECT_FXAA_ENABLED
		vec3 color = FXAA(texcoord);
		FXAA_IS_NOT_SUPPORTED;
	#else
		vec3 color = texelFetch(colortex0, ivec2(gl_FragCoord.xy), 0).rgb;
		#if RENODX_RCAS != 0
			color = RCAS(color, colortex0, ivec2(gl_FragCoord.xy), RENODX_RCAS / 100.f, RENODX_GAME_BRIGHTNESS / 80.f);
		#endif
	#endif

  color = sign(color) * LinearToRGB(abs(color), GAMMA_OUT);

    // color += (GetScreenBayerValue(ivec2(2,1)) - 0.5) / 255.0;

	#ifndef IS_IRIS
		drawWarning(color);
	#endif

	color.rgb = RenderIntermediatePass(color.rgb);

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
}
