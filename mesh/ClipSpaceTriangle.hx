package mesh;

import three.Material;
import three.BufferAttribute;
import js.lib.Float32Array;
import three.BufferGeometry;
import three.Mesh;

class ClipSpaceTriangle extends Mesh<BufferGeometry, Material> {

	public function new(material: Null<Material>) {
		super(globalGeom, material);
		this.frustumCulled = false;
		this.castShadow = false;
		this.receiveShadow = false;
	}

	static final globalGeom: BufferGeometry = {
		var buffer = new BufferGeometry();
		var triangle = new Float32Array([
			-1, -1,
			 3, -1,
			-1,  3,
		]);
		buffer.setAttribute('position', new BufferAttribute(triangle, 2));

		buffer;
	};

}