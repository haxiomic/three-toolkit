package rendering;

import three.WebGLRenderTarget;
import three.WebGLRenderTargetOptions;

@:forward(get, exists, iterator, keyValueIterator)
abstract RenderTargetStore(Map<String, WebGLRenderTarget>) {

	public inline function new() {
		this = new Map();
	}
	
	/**
		Creates render target with specified options if one does not exist, or synchronizes options (including resizing) if one does

		Content is undefined
	**/
	public function acquire(uid: String, width: Float, height: Float, options: WebGLRenderTargetOptions, alwaysSyncOptions: Bool = false): rendering.WebGLRenderTarget {
		var target = this.get(uid);

		var needsNew = target == null;

		// here options may change at runtime so we check if the options are correct and create a new target if mismatching
		if (alwaysSyncOptions && !needsNew) {
			needsNew = (
				options.depthBuffer != target.depthBuffer ||
				options.stencilBuffer != target.stencilBuffer ||
				options.depthTexture != target.depthTexture
			) || (
				(options.wrapS != null && target.texture.wrapS != options.wrapS) ||
				(options.wrapT != null && target.texture.wrapT != options.wrapT) ||
				(options.magFilter != null && target.texture.magFilter != options.magFilter) ||
				(options.minFilter != null && target.texture.minFilter != options.minFilter) ||
				(options.format != null && target.texture.format != options.format) ||
				(options.type != null && target.texture.type != options.type) ||
				(options.anisotropy != null && target.texture.anisotropy != options.anisotropy)
			);
		}

		if (needsNew) {
			if (target != null) {
				target.dispose();
			}
			target = new WebGLRenderTarget(width, height, options);			
			this.set(uid, target);
		} else {
			// synchronize props
			target.texture.generateMipmaps = options.generateMipmaps;
			target.texture.encoding = options.encoding;

			var needsResize = width != target.width || height != target.height;
			if (needsResize) {
				target.setSize(width, height);
			}
		}

		return target;
	}

	public function clearAndDispose() {
		for (target in this) {
			target.dispose();
		}
		this.clear();
	}

}