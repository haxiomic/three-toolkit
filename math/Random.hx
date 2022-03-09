package math;

import Math.random;
import Math.PI;
import VectorMath;

class Random {

	static public inline function randomPointOnSphere(): Vec3 {
		var u = Math.random();
		var v = Math.random();
		var s = Math.random();
		var theta = 2 * Math.PI * u;
		var phi = acos(2 * v - 1);
		return vec3(
			cos(theta) * sin(phi),
			sin(theta) * sin(phi),
			cos(phi)
		);
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