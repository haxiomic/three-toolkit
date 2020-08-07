package math;

class Scalar {
	
	static public inline function mod(x: Float, m: Float) {
		return ( (x % m) + m ) % m;
	}

	static public inline function sign(x: Float) {
		return x >= 0 ? 1 : -1;
	}

}