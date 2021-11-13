package rendering;

import objects.ClipSpaceTriangle;
import three.RawShaderMaterial;
import three.Uniform;

class Background2D extends ClipSpaceTriangle<Background2DMaterial> {

	public var texture(get, set): three.Texture;

	public function new(?texture: three.Texture) {
		super(new Background2DMaterial());
		
		geometry.deleteAttribute('normal');
		geometry.deleteAttribute('uv');

		this.name = 'Background2D';
		this.frustumCulled = false;
		this.castShadow = false;
		this.receiveShadow = false;
		this.matrixAutoUpdate = false;
		this.renderOrder = Math.NEGATIVE_INFINITY; // render last to take advantage of depth culling

		this.material.uTexture.value = texture;

		trace(this);
	}
	
	inline function get_texture() return this.material.uTexture.value;
	inline function set_texture(v) return this.material.uTexture.value = v;

}

class Background2DMaterial extends RawShaderMaterial {

	public final uTexture: Uniform<three.Texture>;

	public function new() {
		var uTexture = new Uniform<three.Texture>(null);
		super({
			uniforms: {
				uTexture: uTexture,
			},
			vertexShader: '
				precision mediump float;
				attribute vec3 position;
				varying vec2 vUv;
				void main() {
					vUv = position.xy * 0.5 + 0.5;
					gl_Position = vec4(position.xy, 0., 1.);
				}
			',
			fragmentShader: '
				precision mediump float;
				varying vec2 vUv;
				void main() {
					gl_FragColor = vec4(vUv, 0., 1.);
				}
			',
			side: DoubleSide,
			depthWrite: false,
			depthTest: true,
			blending: NoBlending,
		});
		this.uTexture = uTexture;
	}

}