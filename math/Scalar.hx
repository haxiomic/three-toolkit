package math;

class Scalar {
	
	static public inline function mod(x: Float, m: Float) {
		return ( (x % m) + m ) % m;
	}

	static public inline function sign(x: Float) {
		return x >= 0 ? 1 : -1;
	}

	static public inline function fract(x: Float) {
		return Math.abs(x % 1);
	}

	static public inline function lerp(a: Float, b: Float, t: Float) {
		return a * (1.0  - t) + b * t;
	}

	static public inline function clamp(x: Float, min: Float, max: Float) {
		return x < min ? min : (x > max ? max : x);
	}

	static public inline function smoothstep(edge0: Float, edge1: Float, x: Float) {
		var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
		return t * t * (3.0 - 2.0 * t);
	}

}