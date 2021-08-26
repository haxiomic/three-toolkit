package tool;

import js.lib.Float32Array;

class CpuTextureSampler {

	final width: Int;
	final height: Int;
	final pixels: Float32Array;

	public function new(tightlyPackedPixels: Float32Array, width: Int, height: Int) {
		this.pixels = tightlyPackedPixels;
		this.width = width;
		this.height = height;
	}

	public function sampleLinear(uvX: Float, uvY: Float) {
		// repeat wrapping
		var x = uvX * width + 0.5;
		var y = uvY * height + 0.5;
		var i = Math.floor(x);
		var j = Math.floor(y);

		var fx = mod(x, 1.);
		var fy = mod(y, 1.);

		var tl = getPixel(i - 1, j);
		var tr = getPixel(i, j);
		var bl = getPixel(i - 1, j - 1);
		var br = getPixel(i, j - 1);

		var topRow = tl * (1.0 - fx) + tr * fx;
		var bottomRow = bl * (1.0 - fx) + br * fx;
		var bilerp = bottomRow * (1.0 - fy) + topRow * fy;

		return bilerp;
	}

	public function sampleNearest(uvX: Float, uvY: Float) {
		// repeat wrapping
		var i = Math.floor(uvX * width);
		var j = Math.floor(uvY * height);
		return getPixel(i, j);
	}

	public function getPixel(i: Int, j: Int) {
		// repeat wrapping
		i = Std.int(mod(i, width));
		j = Std.int(mod(j, height));
		return pixels[j * width + i];
	}

	inline function mod(n: Float, m: Float) {
		return ((n % m) + m) % m;
	}

}