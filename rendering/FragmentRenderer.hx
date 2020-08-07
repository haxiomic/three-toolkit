package rendering;

import mesh.ClipSpaceTriangle;
import three.OrthographicCamera;
import three.Scene;
import three.ShaderMaterial;
import three.Vector4;
import three.WebGLRenderTarget;
import three.WebGLRenderer;

@:nullSafety
class FragmentRenderer {

	final renderer: WebGLRenderer;
	static final rttScene = new Scene();
	static final rttCamera = new OrthographicCamera(-1, 1, 1, -1, 0, 1);
	static final rttMesh = {
		var mesh = new ClipSpaceTriangle(null);
		rttScene.add(mesh);
		mesh;
	};

	public function new(renderer: WebGLRenderer) {
		this.renderer = renderer;
	}

	var _oldViewport = new Vector4();
	public function render(
		target: Null<WebGLRenderTarget>,
		shader: ShaderMaterial,
		?clearColor: Int,
		?viewport: Vector4
	) {
		renderer.setRenderTarget(target);
		renderer.getViewport(_oldViewport);
		if (viewport != null) {
			renderer.setViewport(viewport.x, viewport.y, viewport.z, viewport.w);
		}
		rttMesh.material = shader;
		if (clearColor != null) {
			renderer.setClearColor(clearColor);
			renderer.clear(true, false, false);
		}
		renderer.render(rttScene, rttCamera);
		renderer.setViewport(_oldViewport.x, _oldViewport.y, _oldViewport.z, _oldViewport.w);
	}

}