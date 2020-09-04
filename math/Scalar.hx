package math;

import Math.*;

class Scalar {

	// GLSL style functions
	
	static public inline function mod(x: Float, m: Float) {
		return ( (x % m) + m ) % m;
	}

	static public inline function sign(x: Float) {
		return x >= 0 ? 1 : -1;
	}

	static public inline function fract(x: Float) {
		return abs(x % 1);
	}

	static public inline function mix(a: Float, b: Float, t: Float) {
		return a * (1.0  - t) + b * t;
	}

	static public inline function clamp(x: Float, min: Float, max: Float) {
		return x < min ? min : (x > max ? max : x);
	}

	static public inline function step(edge: Float, x: Float) {
		return x > edge ? 1.0 : 0.0;
	}

	static public inline function smoothstep(edge0: Float, edge1: Float, x: Float) {
		var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
		return t * t * (3.0 - 2.0 * t);
	}

	static public inline function int(v: Float): Int {
		return Std.int(v);
	}

	static public inline function float(v: Int): Float {
		return v;
	}

	static public inline function randomGaussian() {
		return sqrt(-2 * log(random())) * cos(2 * PI * random());
	}

	static public inline function randomGaussian2D() {
		// https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
		var u1 = random();
		var u2 = random();
		return {
			x: sqrt(-2 * log(u1)) * cos(2 * PI * u2),
			y: sqrt(-2 * log(u2)) * cos(2 * PI * u1)
		}
	}

}