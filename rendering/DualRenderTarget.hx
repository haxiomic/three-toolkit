package rendering;

import rendering.PostProcess.fragmentRenderer;
import three.Texture;
import three.Uniform;
import three.WebGLRenderTargetOptions;
import three.WebGLRenderTarget;

class DualRenderTarget {

	public final uniform: Uniform<Texture>;

	public var width(get, null): Int;
	public var height(get, null): Int;

	final options: WebGLRenderTargetOptions;

	var a: WebGLRenderTarget;
	var b: WebGLRenderTarget;

	public function new(width: Float, height: Float, ?options: WebGLRenderTargetOptions) {
		this.options = options;
		a = new WebGLRenderTarget(width, height, options);
		b = new WebGLRenderTarget(width, height, options);
		uniform = new Uniform(b.texture);
	}

	public function resize(newWidth: Int, newHeight: Int) {
		var aNew = new WebGLRenderTarget(newWidth, newHeight, options);
		var bNew = new WebGLRenderTarget(newWidth, newHeight, options);

		// copy content to new texture (following whatever filtering params the textures use)
		fragmentRenderer.render(aNew, shaders.Copy.get(a.texture));
		fragmentRenderer.render(bNew, shaders.Copy.get(b.texture));
		a.dispose();
		b.dispose();

		a = aNew;
		b = bNew;

		uniform.value = b.texture;
	}

	public inline function swap() afterRender();

	public function afterRender() {
		var t = a;
		a = b;
		b = t;
		uniform.value = b.texture;
	}

	public function getRenderTarget() {
		return a;
	}

	public function getTexture() {
		return b.texture;
	}

	inline function get_width() return Std.int(a.width);
	inline function get_height() return Std.int(a.height);

}