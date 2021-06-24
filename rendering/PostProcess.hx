package rendering;

import three.Texture;
import shaders.Blur1D;
import three.PixelFormat;
import three.MathUtils;
import rendering.FragmentRenderer;
import js.html.webgl.RenderingContext;
import three.TextureFilter;
import three.TextureDataType;
import three.WebGLRenderTarget;

private var _renderTargets = new Map<String, WebGLRenderTarget>();
function getRenderTarget(
	name: String,
	options: {
		powerOfTwoMode: PowerOfTwoMode,
		depthBuffer: Bool,
		width: Float,
		height: Float,
		type: TextureDataType,
		sampling: TextureFilter,
	}
) {
	var width: Int;
	var height: Int;
	switch options.powerOfTwoMode {
		case None:
			width = Math.round(options.width);
			height = Math.round(options.height);
		case Ceil:
			width = Std.int(MathUtils.ceilPowerOfTwo(options.width));
			height = Std.int(MathUtils.ceilPowerOfTwo(options.height));
		case Floor:
			width = Std.int(MathUtils.floorPowerOfTwo(options.width));
			height = Std.int(MathUtils.floorPowerOfTwo(options.height));
		case Nearest:
			width = Std.int(MathUtils.nearestPowerOfTwo(options.width));
			height = Std.int(MathUtils.nearestPowerOfTwo(options.height));
	}

	var target = _renderTargets.get(name);
	if (target == null) {
		target = new WebGLRenderTarget(width, height, {
			encoding: LinearEncoding,
			anisotropy: 0,
			generateMipmaps: false,
			depthTexture: null,
			stencilBuffer: false,
			depthBuffer: options.depthBuffer,
			type: options.type,
			format: PixelFormat.RGBAFormat,
			minFilter: options.sampling,
			magFilter: options.sampling,
		});
		_renderTargets.set(name, target);
	} else {
		target.texture.type = options.type;
		target.texture.format = RGBAFormat;
		target.texture.minFilter = options.sampling;
		target.texture.magFilter = options.sampling;
		target.depthBuffer = options.depthBuffer;
		if (
			target.width != width ||
			target.height != height
		) {
			target.setSize(width, height);
		}
	}
	return target;
}

function clearTargetCache() {
	for (k => target in _renderTargets) {
		target.dispose();
	}
	_renderTargets.clear();
}

var fragmentRenderer(get, null): FragmentRenderer = null;
private var _fragmentRenderer: Null<FragmentRenderer> = null;
private inline function get_fragmentRenderer() {
	if (_fragmentRenderer == null) {
		_fragmentRenderer = new FragmentRenderer(Main.renderer);
	}
	return _fragmentRenderer;
}

function resize(name: String, source: Texture, width: Float, height: Float, potMode: PowerOfTwoMode, outputSampling: TextureFilter) {
	var resampleTarget = getRenderTarget('$name.resample', {
		powerOfTwoMode: potMode,
		sampling: outputSampling,
		type: source.type,
		width: width,
		height: height,
		depthBuffer: false,
	});

	fragmentRenderer.render(resampleTarget, shaders.Copy.get(source));
	return resampleTarget;
}

inline function resample(name: String, source: WebGLRenderTarget, scale: Float, potMode: PowerOfTwoMode, outputSampling: TextureFilter) {
	return resize(name, source.texture, Math.round(source.width * scale), Math.round(source.height * scale), potMode, outputSampling);
}

function blur(ctx: RenderingContext, name: String, source: WebGLRenderTarget, kernel: Float, sigma: Float, downsampleIterations: Int) {
	var blurInput = source;

	for (i in 0...downsampleIterations) {
		blurInput = resample('$name.downsample.$i', blurInput, 0.5, None, LinearFilter);
	}

	var width = blurInput.width;
	var height = blurInput.height;

	var blurXTarget = getRenderTarget('$name.blurX', {
		powerOfTwoMode: None,
		sampling: LinearFilter,
		type: source.texture.type,
		width: width,
		height: height,
		depthBuffer: false,
	});
	var blurXYTarget = getRenderTarget('$name.blurXY', {
		powerOfTwoMode: None,
		sampling: LinearFilter,
		type: source.texture.type,
		width: width,
		height: height,
		depthBuffer: false,
	});

	var scaledKernel = kernel * blurInput.width / source.width;

	fragmentRenderer.render(blurXTarget, Blur1D.get(ctx, scaledKernel, sigma, 1.0, 0.0, blurInput.texture, blurInput.width, blurInput.height));
	fragmentRenderer.render(blurXYTarget, Blur1D.get(ctx, scaledKernel, sigma, 0.0, 1.0, blurXTarget.texture, blurXTarget.width, blurXTarget.height));

	return blurXYTarget;
}

enum abstract PowerOfTwoMode(Int) {
	final Nearest;
	final Floor;
	final Ceil;
	final None;
}