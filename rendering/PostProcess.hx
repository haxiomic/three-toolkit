package rendering;

import js.html.webgl.RenderingContext;
import shaders.Blur1D;
import three.MathUtils;
import three.RawShaderMaterial;
import three.Texture;
import three.Uniform;
import three.Vector4;
import three.WebGLRenderer;

class PostProcess {

	final renderer: WebGLRenderer;
	final fragmentRenderer: FragmentRenderer;
	final renderTargetStore: RenderTargetStore;
	final copyShader = new CopyShader();
	final gl: RenderingContext;

	public function new(renderer: WebGLRenderer) {
		this.renderer = renderer;
		this.gl = renderer.getContext();
		this.fragmentRenderer = new FragmentRenderer(renderer);
		this.renderTargetStore = new RenderTargetStore();
	}

	public function dispose() {
		this.renderTargetStore.clearAndDispose();
	}

	var _blit_viewport = new Vector4();
	public function blit(source: Texture, target: Null<WebGLRenderTarget>) {
 		this.copyShader.setParams(source);
		var viewport = if (target != null) {
			target.viewport;
		} else {
			// drawing to canvas
			_blit_viewport.set(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
		}
 		this.fragmentRenderer.render(target, this.copyShader, 0x000000, viewport);
	}

	public function resize(uid: String, source: Texture, width: Float, height: Float): rendering.Texture {
		var options = {
			wrapS: source.wrapS,
			wrapT: source.wrapT,
			magFilter: source.magFilter,
			minFilter: source.minFilter,
			format: source.format,
			type: source.type,
			anisotropy: source.anisotropy,
			generateMipmaps: source.generateMipmaps,
			encoding: source.encoding,
			depthBuffer: false,
			stencilBuffer: false,
			depthTexture: null,
		};

		var target = this.renderTargetStore.acquire('resize.$uid', width, height, options);

		// hopefully the gc will eventually get the gpu framebuffer structure

		copyShader.setParams(source);
		fragmentRenderer.render(target, copyShader);
	
		return target.texture;
	}
	
	public function iterativeDownsample(uid: String, source: rendering.Texture, iterations: Int, floorPowerOfTwo: Bool = true) {
		for (i in 0...iterations) {
			var w: Int;
			var h: Int;
			if (floorPowerOfTwo) {
				w = Std.int(MathUtils.floorPowerOfTwo(source.width * 0.5));
				h = Std.int(MathUtils.floorPowerOfTwo(source.height * 0.5));
			} else {
				w = Math.ceil(source.width * 0.5);
				h = Math.ceil(source.height * 0.5);
			}
			source = resize('downsample.$i.$uid', source, w, h);
			if (w <= 1 && h <= 1) break;
		}
		return source;
	}

	/**
		Requires linear filtering on the source texture
	**/
	public function blur(uid: String, source: rendering.Texture, kernel: Float, sigma = 0.5, downsampleIterations: Int = 0) {
		if (kernel == 0) {
			return source;
		}

		var blurInput = source;

		for (i in 0...downsampleIterations) {
			var w = Std.int(MathUtils.floorPowerOfTwo(blurInput.width * 0.5));
			var h = Std.int(MathUtils.floorPowerOfTwo(blurInput.height * 0.5));
			blurInput = resize('blur.$i.$uid', blurInput, w, h);
			if (w <= 1 && h <= 1) break;
		}

		var width = blurInput.width;
		var height = blurInput.height;

		var targetOptions = {
			wrapS: source.wrapS,
			wrapT: source.wrapT,
			encoding: source.encoding,
			generateMipmaps: source.generateMipmaps,
			anisotropy: source.anisotropy,
			type: source.type,
			format: source.format,
			minFilter: source.minFilter,
			magFilter: source.magFilter,
		};

		var blurXTarget = renderTargetStore.acquire('blurX.$uid', width, height, targetOptions);
		var blurXYTarget = renderTargetStore.acquire('blurXY.$uid', width, height, targetOptions);

		var scaledKernel = kernel * blurInput.width;
		
		fragmentRenderer.render(blurXTarget, Blur1D.get(gl, scaledKernel, sigma, 1., 0., blurInput, blurInput.width, blurInput.height));
		fragmentRenderer.render(blurXYTarget, Blur1D.get(gl, scaledKernel, sigma, 0., 1., blurXTarget.texture, blurXTarget.width, blurXTarget.height));
		
		return blurXYTarget.texture;
	}
	
}

class CopyShader extends RawShaderMaterial {

	final uTexture = new Uniform(null);

	public function new() {
		super({
			uniforms: {
				uTexture: uTexture,
			},
			vertexShader: '
				attribute vec2 position;
				varying vec2 vUv;
				void main() {
					vUv = position * 0.5 + 0.5;
					gl_Position = vec4(position, 0., 1.);
				}
			',
			fragmentShader: '
				precision highp float;
				uniform sampler2D uTexture;
				varying vec2 vUv;
				void main() {
					gl_FragColor = texture2D(uTexture, vUv);
				}
			',
			side: DoubleSide,
			depthWrite: false,
			depthTest: false,
			fog: false,
			lights: false,
			toneMapped: false,
			blending: NoBlending,
		});
	}

	public function setParams(texture: Texture) {
		uTexture.value = texture;
	}

}