/**
 * Curl Noise 4D
 * 
 * Allows for time-varying 3D curl noise field
 * 
 * Based on Robert Bridson's 2007 paper
 * https://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph2007-curlnoise.pdf
 * 
 * Implementation: @haxiomic
 * GLSL version: https://gist.github.com/haxiomic/7453f867b396eee1af599633e03816b3
**/
package noise;

import VectorMath;
import noise.Snoise;

private final dx = vec4(0);
private final dy = vec4(0);
private final dz = vec4(0);
private final u2 = vec4(0.);
inline function curlSnoisePotential(u: Vec4, outGx: Vec3, outGy: Vec3, outGz: Vec3) {
	// generate 3 random values from p, t as a field vector
	// along with analytic gradients
	var field = vec3(
		snoise(u, dx),
		snoise(u2.copyFrom(u + vec4(38.231, -29.321, 12.314, -11.033)), dy),
		snoise(u2.copyFrom(u + vec4(-238.231, -123.321, 130.314, -111.999)), dz)
	);
	outGx.copyFrom(dx.xyz);
	outGy.copyFrom(dy.xyz);
	outGz.copyFrom(dz.xyz);
	return field;
}

inline function potentialGradients(u: Vec4, outGx: Vec3, outGy: Vec3, outGz: Vec3) {
	outGx.set(0, 0, 0);
	outGy.set(0, 0, 0);
	outGz.set(0, 0, 0);

	var dx = vec3(0), dy = vec3(0), dz = vec3(0);

	curlSnoisePotential(u, dx, dy, dz);
	outGx += dx; outGy += dy; outGz += dz;

	// here you could add other potentials for the fluid to interact with
	// gx, gy, gz are the potential-field gradients, you can combine them additively
	// see Bridson's curl noise paper for more details
}

private final gx = vec3(0.);
private final gy = vec3(0.);
private final gz = vec3(0.);
private final pt = vec4(0.);
function curlNoise(p: Vec3, t: Float): Vec3 {
	pt.copyFrom(vec4(p, t));
	potentialGradients(pt, gx, gy, gz);
	return vec3(
		gz.y - gy.z,
		gx.z - gz.x,
		gy.x - gx.y
	);
}