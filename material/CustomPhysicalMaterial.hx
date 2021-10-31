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

	#if (three >= "0.133.0")
	@:deprecated("vertex tangents have been removed")
	#end
	@:keep public var vertexTangents: Bool;

	@:keep public final isMeshStandardMaterial: Bool;

	// MeshPhysicalMaterial
	@:keep public var clearcoat(default, set): Float;
	@:keep public var clearcoatMap: Null<Texture>;
	@:keep public var clearcoatRoughness: Float;
	@:keep public var clearcoatRoughnessMap: Null<Texture>;
	@:keep public var clearcoatNormalScale: Vector2;
	@:keep public var clearcoatNormalMap: Null<Texture>;

	@:isVar
	@:keep public var reflectivity (get, set): Float;

	@:keep public var sheen (default, set): Null<Float>;
	@:keep public var sheenTint: Color;
	@:keep public var sheenRoughness: Float;

	@:keep public var transparency: Float;

	@:keep public var transmission(default, set): Float;
	@:keep public var ior: Float;

	@:keep public var transmissionMap: Null<Texture>;
	@:keep public var thickness: Float;
	@:keep public var thicknessMap: Null<Texture>;
	@:keep public var attenuationDistance: Float;
	@:keep public var attenuationTint: Color;

	@:keep public var specularIntensity : Float;
	@:keep public var specularTint : Color;
	@:keep public var specularIntensityMap : Null<Texture>;
	@:keep public var specularTintMap : Null<Texture>;

	@:keep public final isMeshPhysicalMaterial: Bool;

	public function new(
		?additionalUniforms: haxe.DynamicAccess<three.Uniform<Any>>,
		?parameters: ShaderMaterialParameters & MeshPhysicalMaterialParameters & {
			?transparency: Float, // missing from type definitions
			?defaultAttributeValues: haxe.DynamicAccess<Array<Float>>, // missing from type definitions
		}
	) {
		super(extendAny({
			defines: {
				'STANDARD': '',
				'PHYSICAL': '',
			},
			uniforms: extendAny(Three.ShaderLib.physical.uniforms, additionalUniforms != null ? additionalUniforms : {}),
			vertexShader: Three.ShaderLib.physical.vertexShader,
			fragmentShader: Three.ShaderLib.physical.fragmentShader,
			fog: true,
		}, parameters != null ? parameters : {}));

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
		#if (three < "0.133.0")
		this.vertexTangents = false;
		#end
		this.isMeshStandardMaterial = true;
		this.clearcoat = 0.0;
		this.clearcoatMap = null;
		this.clearcoatRoughness = 0.0;
		this.clearcoatRoughnessMap = null;
		this.clearcoatNormalScale = new Vector2( 1, 1 );
		this.clearcoatNormalMap = null;
		// this.reflectivity = 0.5; // maps to F0 = 0.04
		this.sheen = 0.0; // null will disable sheen bsdf
		this.sheenTint = new Color(0x0);
		this.sheenRoughness = 1.0;
		this.transparency = 0.0;
		this.transmission = 0.;
		this.ior = 1.5;

		this.transmissionMap = null;

		this.thickness = 0.01;
		this.thicknessMap = null;
		this.attenuationDistance = 0.0;
		this.attenuationTint = new Color( 1, 1, 1 );

		this.specularIntensity = 1.0;
		this.specularTint = new Color(1, 1, 1);
		this.specularIntensityMap = null;
		this.specularTintMap = null;
		
		this.isMeshPhysicalMaterial = true;

		if (parameters != null) {
			this.setValues(parameters);
		} 
	}

	inline function set_sheen(v: Float) {
		if ((this.sheen > 0) != (v > 0)) this.version++;
		return this.sheen = v;
	}

	inline function set_clearcoat(v: Float) {
		if ((this.clearcoat > 0) != (v > 0)) this.version++;
		return this.clearcoat = v;
	}

	inline function set_transmission(v: Float) {
		if ((this.transmission > 0) != (v > 0)) this.version++;
		return this.transmission = v;
	}
	
	inline function get_reflectivity() {
		return clamp(2.5 * ( this.ior - 1 ) / ( this.ior + 1 ), 0, 1);
	}
	inline function set_reflectivity(v: Float) {
		this.reflectivity = v;
		return this.ior = ( 1 + 0.4 * v ) / ( 1 - 0.4 * v );
	}

	private inline function clamp(v: Float, min: Float, max: Float) {
		return v < min ? min : (v > max ? max : v);
	}

}