package animator;

import Math.*;

/**
	Visualization of parameters
	https://www.desmos.com/calculator/fayu8nu1md
**/
class Spring {

	public var value: Float;
	public var target: Float;
	public var velocity: Float;
	public var strength: Float;
	public var damping: Float;
	public var onUpdate: Null<(value: Float, velocity: Float) -> Void>;
	public var minEnergyThreshold = 1e-5;
	
	public function new(
		initialValue: Float,
		?target: Float,
		strength: Float = 80,
		damping: Float = 18,
		velocity: Float = 0.0,
		?onUpdate: (value: Float, velocity: Float) -> Void
	) {
		this.value = initialValue;
		this.target = target == null ? initialValue : target;
		this.strength = strength;
		this.damping = damping;
		this.velocity = velocity;
		this.onUpdate = onUpdate;
	}

	public function step(dt_s: Float) {
		// analytic integration (unconditionally stable)
		// visualization: https://www.desmos.com/calculator/c2iug0kerh
		// references:
		// https://mathworld.wolfram.com/OverdampedSimpleHarmonicMotion.html
		// https://mathworld.wolfram.com/CriticallyDampedSimpleHarmonicMotion.html
		// https://mathworld.wolfram.com/UnderdampedSimpleHarmonicMotion.html

		var t = dt_s;
		var V0: Float = this.velocity;
		var X0: Float = this.value - this.target;

		if ((X0 == 0 && V0 == 0) || t == 0) return; // nothing will change

		var k = this.strength;
		var b = this.damping; // β in wolfram reference

		var totalEnergy =
			0.5 * V0 * V0 +    // kinetic energy
			0.5 * k * X0 * X0; // potential energy

		if (totalEnergy < minEnergyThreshold) {
			this.velocity = 0;
			this.value = this.target;
		} else {
			var critical = k * 4 - b * b;

			if (critical > 0) {
				// under damped
				var q = 0.5 * sqrt(critical); // γ

				var A = X0;
				var B = ((b * X0) * 0.5 + V0) / q;

				var m = exp(-b * 0.5 * t);
				var c = cos(q * t);
				var s = sin(q * t);

				var x1 = m * (A*c + B*s);
				var v1 = m * (
					( B*q - 0.5*A*b) * c +
					(-A*q - 0.5*b*B) * s
				);

				this.velocity = v1;
				this.value = x1 + this.target;
			} else if (critical < 0) {
				// over damped
				var u = 0.5 * sqrt(-critical);
				var p = -0.5 * b + u;
				var n = -0.5 * b - u;
				var B = -(n*X0 - V0)/(2*u);
				var A = X0 - B;

				var ep = exp(p * t);
				var en = exp(n * t);

				var x1 = A * en + B * ep;
				var v1 = A * n * en + B * p * ep;

				this.velocity = v1;
				this.value = x1 + this.target;
			} else {
				// critically damped
				var w = sqrt(k); // ω

				var A = X0;
				var B = V0 + w * X0;
				var e = exp(-w * t);

				var x1 = (A + B * t) * e;
				var v1 = (B - w * (A + B * t)) * e;

				this.velocity = v1;
				this.value = x1 + this.target;
			}
		}

		if (onUpdate != null) onUpdate(value, velocity);
	}

	public function forceCompletion(?v: Float) {
		if (v != null) {
			target = v;
		}
		value = target;
		velocity = 0;
		if (onUpdate != null) onUpdate(value, velocity);
	}

}