package tool;

import three.Matrix4;
import three.BufferGeometry;
import three.Material;
import three.Mesh;
import VectorMath;

#if (three >= "0.133.0")
private typedef Object3D = three.Object3D<three.Event>;
#end

class Object3DTools {

	/**
		Recursive iteration of child objects
	**/
	static public function iterate(obj: Object3D, cb: Object3D -> Void) {
		cb(obj);
		for (child in obj.children) {
			iterate(child, cb);
		}
	}

	/**
		Recursive iteration of child meshes
	**/
	static public function iterateMeshes(obj: Object3D, cb: Mesh<BufferGeometry, Material> -> Void) {
		if (Std.is(obj, Mesh)) cb(cast obj);
		for (child in obj.children) {
			iterateMeshes(child, cb);
		}
	}

	static public function forEachDescendant(obj: Object3D, cb: Object3D -> Void) {
		for (child in obj.children) {
			cb(child);
			forEachDescendant(child, cb);
		}
	}

	static public function forEachDescendantMesh(obj: Object3D, cb: Mesh<BufferGeometry, Material> -> Void) {
		for (child in obj.children) {
			if (Std.is(child, Mesh)) cb(cast child);
			forEachDescendantMesh(child, cb);
		}
	}

	static public function findDescendant(obj: Object3D, test: Object3D -> Bool): Null<Object3D> {
		for (child in obj.children) {
			if (test(child)) {
				return child;
			}
		}
		for (child in obj.children) {
			var m = findDescendant(child, test);
			if (m != null) {
				return m;
			}
		}
		return null;
	}

	static public function filterDescendants(obj: Object3D, test: Object3D -> Bool): Array<Object3D> {
		var result = new Array<Object3D>();
		for (child in obj.children) {
			if (test(child)) {
				result.push(child);
			}
		}
		for (child in obj.children) {
			var a = filterDescendants(child, test);
			result = result.concat(a);
		}
		return result;
	}

	static public function getAllMaterials(obj: Object3D) {
		var materials = new Array();
		iterateMeshes(obj, mesh -> {
			if (mesh.material != null && materials.indexOf(mesh.material) == -1) {
				materials.push(mesh.material);
			}
		});
		return materials;
	}

	static public function getMaterialByName(obj: Object3D, name: String): Null<Material> {
		if ((obj: Dynamic).material != null && (obj: Dynamic).material.name == name) {
			return (obj: Dynamic).material;
		}
		for (child in obj.children) {
			var m = getMaterialByName(child, name);
			if (m != null) {
				return m;
			}
		}
		return null;
	}

	/**
	 * Replaces materials with a given name recursively within an object
	 * @param within 
	 * @param searchMaterialName 
	 * @param replacement 
	 * @return number of replacements that occurred Int
	 */
	static public function replaceMaterial(obj: Object3D, searchMaterialName: String, replacement: Material): Int {
		var replacements = 0;
		if ((obj: Dynamic).material != null && (obj: Dynamic).material.name == searchMaterialName) {
			(obj: Dynamic).material = replacement;
			replacements += 1;
		}
		for (child in obj.children) {
			replacements += replaceMaterial(child, searchMaterialName, replacement);
		}
		return replacements;
	}

	static var setRotationFromBasis_tmpMatrix4 = new Matrix4();
	static public inline function setRotationFromBasis(obj: Object3D, basis: { x: Vec3, y: Vec3, z: Vec3 }) {
		var rotationMatrix = mat4(
			vec4(basis.x, 0.0),
			vec4(basis.y, 0.0),
			vec4(basis.z, 0.0),
			vec4(0.0, 0.0, 0.0, 1.0)
		);
		rotationMatrix.copyIntoArray(setRotationFromBasis_tmpMatrix4.elements, 0);
		obj.setRotationFromMatrix(setRotationFromBasis_tmpMatrix4);
	}

}