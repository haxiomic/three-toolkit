package material;

import three.Texture;
import Structure.extendAny;
import three.Color;
import three.MeshPhysicalMaterialParameters;
import three.NormalMapTypes;
import three.ShaderMaterial;
import three.ShaderMaterialParameters;
import three.Vector2;

class CustomPhysicalMaterial extends ShaderMaterial {

	@:keep public var color: Color;
	@:keep public var roughness: Float;
	@:keep public var metalness: Float;

	@:keep public var map: Null<Texture>;

	@:keep public var lightMap: Null<Texture>;
	@:keep public var lightMapIntensity: Float;

	@:keep public var aoMap: Null<Texture> ;
	@:keep public var aoMapIntensity: Float;

	@:keep public var emissive: Color;
	@:keep public var emissiveIntensity: Float;
	@:keep public var emissiveMap: Null<Texture>;

	@:keep public var bumpMap: Null<Texture>;
	@:keep public var bumpScale: Float;

	@:keep public var normalMa: Null<Texture>;
	@:keep public var normalMapType: NormalMapTypes;
	@:keep public var normalScale: Vector2;

	@:keep public var displacementMap: Null<Texture>;
	@:keep public var displacementScale: Float;
	@:keep public var displacementBias: Float;

	@:keep public var roughnessMap: Null<Texture>;

	@:keep public var metalnessMap: Null<Texture>;

	@:keep public var alphaMap: Null<Texture>;

	@:keep public var envMap: Null<Texture>;
	@:keep public var envMapIntensity: Float;

	@:keep public var refractionRatio: Float;

	@:keep public var wireframeLinecap: String;
	@:keep public var wireframeLinejoin: String;

	@:keep public var vertexTangents: Bool;

	@:keep public final isMeshStandardMaterial: Bool;

	// MeshPhysicalMaterial
	@:keep public var clearcoat: Float;
	@:keep public var clearcoatMap: Null<Texture>;
	@:keep public var clearcoatRoughness: Float;
	@:keep public var clearcoatRoughnessMap: Null<Texture>;
	@:keep public var clearcoatNormalScale: Vector2;
	@:keep public var clearcoatNormalMap: Null<Texture>;

	@:keep public var reflectivity: Float;

	@:keep public var sheen: Null<Float>;

	@:keep public var transparency: Float;

	@:keep public var transmission: Float;
	@:keep public var ior: Float;

	@:keep public final isMeshPhysicalMaterial: Bool;


	public function new(
		additionalUniforms: haxe.DynamicAccess<three.Uniform<Any>>,
		parameters: ShaderMaterialParameters & MeshPhysicalMaterialParameters & {
			?transparency: Float, // missing from type definitions
			?defaultAttributeValues: haxe.DynamicAccess<Array<Float>>, // missing from type definitions
		}
	) {
		super(extendAny({
			defines: {
				'STANDARD': '',
				'PHYSICAL': '',
			},
			uniforms: extendAny(Three.ShaderLib.physical.uniforms, additionalUniforms),
			vertexShader: Three.ShaderLib.physical.vertexShader,
			fragmentShader: Three.ShaderLib.physical.fragmentShader,
			fog: true,			
		}, parameters));

		this.color = new Color( 0xffffff ); // diffuse
		this.roughness = 1.0;
		this.metalness = 0.0;
		this.map = null;
		this.lightMap = null;
		this.lightMapIntensity = 1.0;
		this.aoMap = null;
		this.aoMapIntensity = 1.0;
		this.emissive = new Color( 0x000000 );
		this.emissiveIntensity = 1.0;
		this.emissiveMap = null;
		this.bumpMap = null;
		this.bumpScale = 1;
		this.normalMa = null;
		this.normalMapType = TangentSpaceNormalMap;
		this.normalScale = new Vector2( 1, 1 );
		this.displacementMap = null;
		this.displacementScale = 1;
		this.displacementBias = 0;
		this.roughnessMap = null;
		this.metalnessMap = null;
		this.alphaMap = null;
		this.envMap = null;
		this.envMapIntensity = 1.0;
		this.refractionRatio = 0.98;
		this.wireframeLinecap = 'round';
		this.wireframeLinejoin = 'round';
		this.vertexTangents = false;
		this.isMeshStandardMaterial = true;
		this.clearcoat = 0.0;
		this.clearcoatMap = null;
		this.clearcoatRoughness = 0.0;
		this.clearcoatRoughnessMap = null;
		this.clearcoatNormalScale = new Vector2( 1, 1 );
		this.clearcoatNormalMap = null;
		this.reflectivity = 0.5; // maps to F0 = 0.04
		this.sheen = null; // null will disable sheen bsdf
		this.transparency = 0.0;
		this.transmission = 0.;
		this.ior = 1.3;
		this.isMeshPhysicalMaterial = true;
	}

}