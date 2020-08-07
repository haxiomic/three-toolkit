package shaders;

import three.RawShaderMaterial;
import three.Texture;
import three.Uniform;

class BloomBlend extends RawShaderMaterial {

	static public inline function get(texture: Texture, alpha: Float, exponent: Float) {
		instance.uTexture.value = texture;
		instance.uBoomAlpha.value = alpha;
		instance.uBoomExponent.value = exponent;
		return instance;
	}
	static final instance = new BloomBlend();

	public final uTexture = new Uniform(cast null);
	public final uBoomAlpha = new Uniform(0.1);
	public final uBoomExponent = new Uniform(1.);

	public function new() {
		super({
			uniforms: {
				uTexture: uTexture,
				uBoomAlpha: uBoomAlpha,
				uBoomExponent: uBoomExponent, 
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
				uniform float uBoomAlpha;
				uniform float uBoomExponent;

				varying vec2 vUv;

				void main() {
					gl_FragColor = texture2D(uTexture, vUv);
					gl_FragColor.rgb = pow(gl_FragColor.rgb, vec3(uBoomExponent));
					gl_FragColor.a *= uBoomAlpha;
				}
			',
			side: DoubleSide,
			blending: AdditiveBlending,
		});
	}

}