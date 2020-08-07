package rendering;

import three.Texture;
import three.Uniform;
import three.WebGLRenderTargetOptions;
import three.WebGLRenderTarget;

class DualRenderTarget {

	public final uniform: Uniform<Texture>;

	public var width(get, null): Int;
	public var height(get, null): Int;

	var a: WebGLRenderTarget;
	var b: WebGLRenderTarget;

	public function new(width: Float, height: Float, ?options: WebGLRenderTargetOptions) {
		a = new WebGLRenderTarget(width, height, options);
		b = new WebGLRenderTarget(width, height, options);
		uniform = new Uniform(b.texture);
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