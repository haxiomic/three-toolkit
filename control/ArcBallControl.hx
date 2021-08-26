package control;

import Structure.extend;
import animator.Spring;
import app.EventResponse;
import js.Browser;
import js.html.Element;
import js.html.MouseEvent;
import js.html.WheelEvent;
import math.Quat;

/**
	Soft arc ball camera

	Maintains natural drag direction when flipped upside-down (like blender viewport)

	strength / damping parameters
	https://www.desmos.com/calculator/fayu8nu1md
**/
@:nullSafety
class ArcBallControl {

	static final defaults = {
		strength: 700,
		damping: 100,
		dragSpeed: 6,
		angleAroundY: 0,
		angleAroundXZ: 0,
		radius: 1,
		zoomSpeed: 1,
	}

	// arc ball smoothing
	public var dragSpeed: Float;
	public var zoomSpeed: Float;

	public var strength(get, set): Float;
	inline function get_strength() return angleAroundY.strength;
	inline function set_strength(v: Float) return {
		angleAroundY.strength = v;
		angleAroundXZ.strength = v;
		radius.strength = v;
		return v;
	}

	public var damping(get, set): Float;
	inline function get_damping() return angleAroundY.damping;
	inline function set_damping(v: Float) return {
		angleAroundY.damping = v;
		angleAroundXZ.damping = v;
		radius.damping = v;
		return v;
	}

	// orientation (via Springs)
	// where angle is 0 at (x=0,z=1) and 90° at (x=1,z=0)
	public final angleAroundY = new Spring(0.);
	public final angleAroundXZ = new Spring(0.);
	public final radius = new Spring(1.);

	public final position = new Vec3(0., 0., 0.);
	public final orientation = new Quat(0, 0, 0, 1);

	public function new(
		options: {
			?interactionSurface: Element,
			?interactionEventsManager: app.InteractionEventsManager,
			?angleAroundY: Float,
			?angleAroundXZ: Float,
			?radius: Float,
			?strength: Float,
			?damping: Float,
			?dragSpeed: Float,
			?zoomSpeed: Float,
		}
	) {

		var options = extend(defaults, options);
		
		this.dragSpeed = options.dragSpeed;
		this.zoomSpeed = options.zoomSpeed;
		this.strength = options.strength;
		this.damping = options.damping;
		this.angleAroundY.forceCompletion(options.angleAroundY);
		this.angleAroundXZ.forceCompletion(options.angleAroundXZ);
		this.radius.forceCompletion(options.radius);

		var interactionSurface = options.interactionSurface;
		var interactionEventsManager = options.interactionEventsManager;

		if (interactionEventsManager != null) {

			interactionEventsManager.onPointerDown((e) -> onPointerDown(new Vec2(e.x, e.y)));
			interactionEventsManager.onPointerMove((e) -> {
				onPointerMove(new Vec2(e.x, e.y), new Vec2(e.viewWidth, e.viewHeight));
			});
			interactionEventsManager.onPointerUp((e) -> onPointerUp(new Vec2(e.x, e.y)));
			interactionEventsManager.onWheel((e) -> {
				radius.target += e.deltaY * zoomSpeed / 1000;
				radius.target = Math.max(radius.target, 0);
				return PreventFurtherHandling;
			});
			
		} else if (interactionSurface != null) {
			interactionSurface.addEventListener('mousedown', (e: MouseEvent) -> {
				if (onPointerDown(new Vec2(e.clientX, e.clientY)) == PreventFurtherHandling) {
					e.preventDefault();
				}
			});
			interactionSurface.addEventListener('contextmenu', (e: MouseEvent) -> {
				if (onPointerUp(new Vec2(e.clientX, e.clientY)) == PreventFurtherHandling) {
					e.preventDefault();
				}
			});
			Browser.window.addEventListener('mousemove', (e: MouseEvent) -> {
				if (onPointerMove(new Vec2(e.clientX, e.clientY), new Vec2(interactionSurface.clientWidth, interactionSurface.clientHeight)) == PreventFurtherHandling) {
					e.preventDefault();
				}
			});
			Browser.window.addEventListener('mouseup', (e: MouseEvent) -> {
				if (onPointerUp(new Vec2(e.clientX, e.clientY)) == PreventFurtherHandling) {
					e.preventDefault();
				}
			});
			interactionSurface.addEventListener('wheel', (e: WheelEvent) -> {
				radius.target += e.deltaY * zoomSpeed / 1000;

				radius.target = Math.max(radius.target, 0);

				e.preventDefault();
			}, {passive: false});
		}
	}

	public inline function step(dt_s: Float) {
		angleAroundY.step(dt_s);
		angleAroundXZ.step(dt_s);
		radius.step(dt_s);
		
		// spherical polar
		position.x = radius.value * Math.sin(angleAroundY.value) * Math.cos(angleAroundXZ.value);
		position.z = radius.value * Math.cos(angleAroundY.value) * Math.cos(angleAroundXZ.value);
		position.y = radius.value * Math.sin(angleAroundXZ.value);

		// look at (0, 0, 0)
		var aY = Quat.fromAxisAngle(new Vec3(0, 1, 0), angleAroundY.value);
		var aXZ = Quat.fromAxisAngle(new Vec3(1, 0, 0), -angleAroundXZ.value);
		orientation.copyFrom(aY * aXZ);
	}

	public function applyToCamera(camera: {
		final position: {x: Float, y: Float, z: Float};
		final quaternion: {x: Float, y: Float, z: Float, w: Float};
	}) {
		var p = position;
		var q = orientation;
		camera.position.x = p.x;
		camera.position.y = p.y;
		camera.position.z = p.z;
		camera.quaternion.x = q.x;
		camera.quaternion.y = q.y;
		camera.quaternion.z = q.z;
		camera.quaternion.w = q.w;
	}

	var _onDown_angleAroundY: Float = 0;
	var _onDown_angleAroundXZ: Float = 0;
	var _onDown_clientXY = new Vec2(0, 0);
	var _isPointerDown = false;
	public inline function onPointerDown(clientXY: Vec2): EventResponse {
		_isPointerDown = true;
		_onDown_angleAroundY = angleAroundY.target;
		_onDown_angleAroundXZ = angleAroundXZ.target;
		_onDown_clientXY.copyFrom(clientXY);
		return AllowFurtherHandling;
	}

	public inline function onPointerMove(clientXY: Vec2, surfaceSize: Vec2): EventResponse {
		if (_isPointerDown) {
			// normalize coordinates so dragSpeed is independent of screen size
			var aspect = surfaceSize.x / surfaceSize.y;
			var normXY = clientXY / surfaceSize;
			var normOnDownXY = _onDown_clientXY / surfaceSize;
			var screenSpaceDelta = normXY - normOnDownXY;

			angleAroundXZ.target = _onDown_angleAroundXZ + screenSpaceDelta.y * dragSpeed;

			// flip y-axis rotation direction if we're upside-down
			// fade to 0 in and out of the flip for a smoother transition
			var up = orientation.transform(new Vec3(0, 1, 0));
			var flip = up.y >= 0 ? 1 : -1;
			var fadeMultiplier = (1.0 - Math.pow(Math.abs(up.y) + 1, -4));

			angleAroundY.target = _onDown_angleAroundY - fadeMultiplier * flip * screenSpaceDelta.x * dragSpeed * aspect;

			return PreventFurtherHandling;
		} else {
			return AllowFurtherHandling;
		}
	}

	public inline function onPointerUp(clientXY: Vec2): EventResponse {
		_isPointerDown = false;
		return AllowFurtherHandling;
	}

}