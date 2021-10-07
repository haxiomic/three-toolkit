package tool;

import three.BufferGeometry;
import three.Material;
import three.Mesh;

#if (three <= "0.133.0")
private typedef Object3D = three.Object3D<three.Event>;
#end

class Object3DTools {

	/**
		Recursive iteration of child objects
	**/
	static public function iterate(obj: Object3D, cb: Object3D -> Void) {
		cb(obj);
		for (child in obj.children) {
			cb(child);
			iterate(child, cb);
		}
	}

	/**
		Recursive iteration of child meshes
	**/
	static public function iterateMeshes(obj: Object3D, cb: Mesh<BufferGeometry, Material> -> Void) {
		if (Std.is(obj, Mesh)) cb(cast obj);
		for (child in obj.children) {
			if (Std.is(child, Mesh)) cb(cast child);
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

}