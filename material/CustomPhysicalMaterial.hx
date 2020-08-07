package material;

import three.MeshPhysicalMaterialParameters;
import tool.StructureTools;
import three.NormalMapTypes;
import three.Vector2;
import three.Color;
import three.MeshStandardMaterialParameters;
import three.ShaderMaterialParameters;
import three.ShaderMaterial;

class CustomPhysicalMaterial extends ShaderMaterial {

	@:keep public var color = new Color( 0xffffff ); // diffuse
	@:keep public var roughness = 1.0;
	@:keep public var metalness = 0.0;

	@:keep public var map = null;

	@:keep public var lightMap = null;
	@:keep public var lightMapIntensity = 1.0;

	@:keep public var aoMap = null;
	@:keep public var aoMapIntensity = 1.0;

	@:keep public var emissive = new Color( 0x000000 );
	@:keep public var emissiveIntensity = 1.0;
	@:keep public var emissiveMap = null;

	@:keep public var bumpMap = null;
	@:keep public var bumpScale = 1;

	@:keep public var normalMap = null;
	@:keep public var normalMapType: NormalMapTypes = TangentSpaceNormalMap;
	@:keep public var normalScale = new Vector2( 1, 1 );

	@:keep public var displacementMap = null;
	@:keep public var displacementScale = 1;
	@:keep public var displacementBias = 0;

	@:keep public var roughnessMap = null;

	@:keep public var metalnessMap = null;

	@:keep public var alphaMap = null;

	@:keep public var envMap = null;
	@:keep public var envMapIntensity = 1.0;

	@:keep public var refractionRatio = 0.98;

	@:keep public var wireframeLinecap = 'round';
	@:keep public var wireframeLinejoin = 'round';

	@:keep public var vertexTangents = false;

	@:keep public final isMeshStandardMaterial = true;

	// MeshPhysicalMaterial
	@:keep public var clearcoat = 0.0;
	@:keep public var clearcoatMap = null;
	@:keep public var clearcoatRoughness = 0.0;
	@:keep public var clearcoatRoughnessMap = null;
	@:keep public var clearcoatNormalScale = new Vector2( 1, 1 );
	@:keep public var clearcoatNormalMap = null;

	@:keep public var reflectivity = 0.5; // maps to F0 = 0.04

	@:keep public var sheen = null; // null will disable sheen bsdf

	@:keep public var transparency = 0.0;

	@:keep public final isMeshPhysicalMaterial = true;

	public function new(
		additionalUniforms: haxe.DynamicAccess<three.Uniform<Any>>,
		parameters: ShaderMaterialParameters & MeshPhysicalMaterialParameters & {
			?transparency: Float, // missing from type definitions
			?defaultAttributeValues: haxe.DynamicAccess<Array<Float>>, // missing from type definitions
		}
	) {
		super(StructureTools.extend({
			defines: {
				'STANDARD': '',
				'PHYSICAL': '',
			},
			uniforms: StructureTools.extend(Three.ShaderLib.physical.uniforms, additionalUniforms),
			vertexShader: Three.ShaderLib.physical.vertexShader,
			fragmentShader: Three.ShaderLib.physical.fragmentShader,
			fog: true,			
		}, parameters));
	}

}