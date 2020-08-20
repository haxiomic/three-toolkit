package app;

import app.event.PointerEvent;
import js.Browser.*;
import js.html.CanvasElement;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import js.html.TouchEvent;
import js.html.WheelEvent;

class AppEventHost {
	
	public final appInstance: AppEventInterface;
	public final canvas: CanvasElement;

	public function new(appInstance: AppEventInterface, canvas: CanvasElement) {
		// automatically create a canvas element with reasonable defaults
		this.appInstance = appInstance;
		this.canvas = canvas;

		if (canvas.tabIndex == null) {
			// make the canvas focusable
			// this enables us to determine if our canvas has focus when receiving key events
			canvas.tabIndex = 1;
		}

		// disable default touch actions, this helps disable view dragging on touch devices
		canvas.style.touchAction = 'none';
		canvas.setAttribute('touch-action', 'none');
		// prevent native touch-scroll
		function cancelEvent(e) {
			e.preventDefault();
			e.stopPropagation();
		}
		canvas.addEventListener('gesturestart', cancelEvent, false);
		canvas.addEventListener('gesturechange', cancelEvent, false);
		// canvas.addEventListener('scroll', cancelEvent); need to experiment

		// attach interaction event listeners
		addPointerEventListeners();
		addWheelEventListeners();
		addKeyboardEventListeners();
		addLifeCycleEventListeners();
		addResizeEventListeners();

		// startup life-cycle event
		onVisibilityChange();
	}

	var canvasClientWidth: Null<Int> = null;
	var canvasClientHeight: Null<Int> = null;
	inline function onResize() {
		if (canvasClientWidth != canvas.clientWidth || canvasClientHeight != canvas.clientHeight) {
			canvasClientWidth = canvas.clientWidth;
			canvasClientHeight = canvas.clientHeight;
			appInstance.onResize(canvas.clientWidth, canvas.clientHeight);
		}
	}

	var haxeAppActivated = false;
	function onVisibilityChange() {
		switch (document.visibilityState) {
			case VISIBLE: if (!haxeAppActivated) {
				appInstance.onActivate();
				haxeAppActivated = true;
			}
			case HIDDEN: if (haxeAppActivated) {
				appInstance.onDeactivate();
				haxeAppActivated = false;
			}
		}
	}

	function addPointerEventListeners() {
		// Pointer Input
		function executePointerMethodFromMouseEvent(mouseEvent: MouseEvent, pointerMethod: (PointerEvent) -> Bool) {
			// trackpad force
			// var force = mouseEvent.force || mouseEvent.webkitForce;
			var force: Float = if (js.Syntax.field(mouseEvent, 'force') != null) {
				js.Syntax.field(mouseEvent, 'force');
			} else if (js.Syntax.field(mouseEvent, 'webkitForce') != null) {
				js.Syntax.field(mouseEvent, 'webkitForce');
			} else {
				0.5;
			}

			// force ranges from 1 (WEBKIT_FORCE_AT_MOUSE_DOWN) to >2 when using a force-press
			// convert force to a 0 - 1 range
			var pressure = Math.max((force - 1), 0);

			if (pointerMethod({
				pointerId: 1,
				pointerType: 'mouse',
				isPrimary: true,
				button: mouseEvent.button,
				buttons: mouseEvent.buttons,
				x: mouseEvent.clientX,
				y: mouseEvent.clientY,
				width: 1,
				height: 1,
				pressure: pressure,
				tangentialPressure: 0,
				tiltX: 0,
				tiltY: 0,
				twist: 0,
			})) {
				mouseEvent.preventDefault();
			}
		}

		// Map<type, {primaryTouchIdentifier: Int, activeCount: Int}>
		var touchInfoForType = new Map<String, {primaryTouchIdentifier: Int, activeCount: Int}>();
		function getTouchInfoForType(type) {
			var touchInfo = touchInfoForType[type];
			if (touchInfo == null) {
				touchInfoForType[type] = touchInfo = {
					primaryTouchIdentifier: null,
					activeCount: 0,
				}
			}
			return touchInfo;
		}

		function executePointerMethodFromTouchEvent(touchEvent: TouchEvent, pointerMethod: (app.event.PointerEvent) -> Bool) {
			var buttonStates: {
				button: Int,
				buttons: Int,
			} = switch (touchEvent.type) {
				case 'touchstart': {
					button: 0,
					buttons: 1,
				}
				case 'touchforcechange', 'touchmove': {
					button: -1,
					buttons: 1,
				}
				default: {
					button: 0,
					buttons: 0,
				}
			}

			for (i in 0...touchEvent.changedTouches.length) {
				var touch: TouchLevel2 = cast touchEvent.changedTouches[i];

				// touchforcechange can fire _after_ touchup fires
				// we filter it out by checking if the touch is included in the list of active touches
				if (touchEvent.type == 'touchforcechange') {
					var touchIsActive = false;
					for (t in touchEvent.touches) {
						if (touch == cast t) {
							touchIsActive = true;
							break;
						}
					}
					if (!touchIsActive) {
						continue;
					}
				}

				var touchInfo = getTouchInfoForType(touch.touchType);

				// set primary touch as the first active touch
				if (touchInfo.activeCount == 0 && touchEvent.type == 'touchstart') {
					touchInfo.primaryTouchIdentifier = touch.identifier;
				}
				// update activeCount
				switch (touchEvent.type) {
					case 'touchstart':
						touchInfo.activeCount++;
					case 'touchcancel', 'touchend':
						touchInfo.activeCount--;
				}

				// convert altitude-azimuth to tilt xy
				var tanAlt = Math.tan(touch.altitudeAngle);
				var radToDeg = 180.0 / Math.PI;
				var tiltX = Math.atan(Math.cos(touch.azimuthAngle) / tanAlt) * radToDeg;
				var tiltY = Math.atan(Math.sin(touch.azimuthAngle) / tanAlt) * radToDeg;

				var radiusX = touch.radiusX != null ? touch.radiusX : (js.Syntax.field(touch, 'webkitRadiusX') != null ? js.Syntax.field(touch, 'webkitRadiusX') : 5);
				var radiusY = touch.radiusY != null ? touch.radiusY : (js.Syntax.field(touch, 'webkitRadiusY') != null ? js.Syntax.field(touch, 'webkitRadiusY') : 5);

				if (pointerMethod({
					pointerId: touch.identifier,
					pointerType: (touch.touchType == 'stylus') ? 'pen' : 'touch',
					isPrimary: touch.identifier == touchInfo.primaryTouchIdentifier,
					button: buttonStates.button,
					buttons: buttonStates.buttons,
					x: touch.clientX,
					y: touch.clientY,
					width: radiusX * 2,
					height: radiusY * 2,
					pressure: touch.force,
					tangentialPressure: 0,
					tiltX: Math.isFinite(tiltX) ? tiltX : 0,
					tiltY: Math.isFinite(tiltY) ? tiltY : 0,
					twist: touch.rotationAngle,
				})) {
					touchEvent.preventDefault();
				}
			}
		}

		var onPointerDown = (e) -> appInstance.onPointerDown(e);
		var onPointerMove = (e) -> appInstance.onPointerMove(e);
		var onPointerUp = (e) -> appInstance.onPointerUp(e);
		var onPointerCancel = (e) -> appInstance.onPointerCancel(e);

		// use PointerEvent API if supported
		if (js.Syntax.field(window, 'PointerEvent')) {
			canvas.addEventListener('pointerdown', onPointerDown);
			window.addEventListener('pointermove', onPointerMove);
			window.addEventListener('pointerup', onPointerUp);
			window.addEventListener('pointercancel', onPointerCancel);
		} else {
			canvas.addEventListener('mousedown', (e) -> executePointerMethodFromMouseEvent(e, onPointerDown));
			window.addEventListener('mousemove', (e) -> executePointerMethodFromMouseEvent(e, onPointerMove));
			window.addEventListener('webkitmouseforcechanged', (e) -> executePointerMethodFromMouseEvent(e, onPointerMove));
			window.addEventListener('mouseforcechanged', (e) -> executePointerMethodFromMouseEvent(e, onPointerMove));
			window.addEventListener('mouseup', (e) -> executePointerMethodFromMouseEvent(e, onPointerUp));
			var useCapture = true;
			canvas.addEventListener('touchstart', (e) -> executePointerMethodFromTouchEvent(e, onPointerDown), { capture: useCapture,  }); // passive: false
			window.addEventListener('touchmove', (e) -> executePointerMethodFromTouchEvent(e, onPointerMove), { capture: useCapture,  }); // passive: false
			window.addEventListener('touchforcechange', (e) -> executePointerMethodFromTouchEvent(e, onPointerMove), { capture: useCapture,  }); // passive: true
			window.addEventListener('touchend', (e) -> executePointerMethodFromTouchEvent(e, onPointerUp), {capture: useCapture, }); // passive: true
			window.addEventListener('touchcancel', (e) -> executePointerMethodFromTouchEvent(e, onPointerCancel), { capture: useCapture,  }); // passive: true
		}
	}

	function addWheelEventListeners() {
		canvas.addEventListener('wheel', (e: js.html.WheelEvent) -> {
			// we normalize for delta modes, so we always scroll in px
			// chrome always uses pixels but firefox can sometime uses lines and pages
			// see https://stackoverflow.com/questions/20110224/what-is-the-height-of-a-line-in-a-wheel-event-deltamode-dom-delta-line
			var x_px = e.clientX;
			var y_px = e.clientY;
			var deltaX_px = e.deltaX;
			var deltaY_px = e.deltaY;
			var deltaZ_px = e.deltaZ;
			switch (e.deltaMode) {
				case WheelEvent.DOM_DELTA_PIXEL:
					deltaX_px = e.deltaX;
					deltaY_px = e.deltaY;
					deltaZ_px = e.deltaZ;
				case WheelEvent.DOM_DELTA_LINE:
					// lets assume the line-height is 16px
					deltaX_px = e.deltaX * 16;
					deltaY_px = e.deltaY * 16;
					deltaZ_px = e.deltaZ * 16;
				case WheelEvent.DOM_DELTA_PAGE:
					// this needs further testing
					deltaX_px = e.deltaX * 100;
					deltaY_px = e.deltaY * 100;
					deltaZ_px = e.deltaZ * 100;
			}
			if (appInstance.onWheel({
				x: x_px,
				y: y_px,
				deltaX: deltaX_px,
				deltaY: deltaY_px,
				deltaZ: deltaZ_px,
				// deltaMode: e.deltaMode,
				altKey: e.altKey,
				ctrlKey: e.ctrlKey,
				metaKey: e.metaKey,
				shiftKey: e.shiftKey,
			})) {
				e.preventDefault();
			}
		});
	}

	function addKeyboardEventListeners() {
		// keyboard event
		window.addEventListener('keydown', (e: KeyboardEvent) -> {
			var hasFocus = e.target == canvas;
			if (appInstance.onKeyDown(cast e, hasFocus)) {
				e.preventDefault();
			}
		});
		window.addEventListener('keyup', (e) -> {
			var hasFocus = e.target == canvas;
			if (appInstance.onKeyUp(cast e, hasFocus)) {
				e.preventDefault();
			}
		});
	}

	function addLifeCycleEventListeners() {
		// life-cycle events
		document.addEventListener('visibilitychange', () -> onVisibilityChange());
	}

	function addResizeEventListeners() {
		// we assume the canvas may resize if the window resizes
		// however, you can call onResize() if the canvas resizes without the window resizing
		window.addEventListener('resize', () -> onResize(), {
			capture: false,
		});
	}

}

/**
	Adds missing fields to touch type in the level2 spec
**/
extern class TouchLevel2 extends js.html.Touch {
	var touchType: String;
	var altitudeAngle: Float;
	var azimuthAngle: Float;
}