package event;

/**
	See https://w3c.github.io/uievents/#idl-keyboardevent
**/
@:publicFields
@:structInit
@:unreflective
#if cpp @:keep #end
class KeyboardEvent {

	/**
		Locale-aware key

		Either a
		- A key string that corresponds to the character typed (accounting for the user's current locale and mappings), e.g. `"a"`
		- A named key mapping to the values in the [specification](https://www.w3.org/TR/uievents-key/#named-key-attribute-value) e.g. `"ArrowDown"`

		Example use-cases include detecting keyboard shortcuts

		See https://www.w3.org/TR/uievents-key/#key-attribute-value
	**/
	final key: String;

	/**
		A string that identifies the physical key being pressed, it differs from the `key` field in that it **doesn't** account for the user's current locale and mappings.
		The list of possible codes and their mappings to physical keys is given here https://www.w3.org/TR/uievents-code/.

		Example use-cases include detecting WASD keys for moving controls in a game

		See https://w3c.github.io/uievents/#keys-codevalues
	**/
	final code: String;

	final location: KeyLocation;

	final altKey: Bool;
	final ctrlKey: Bool;
	final metaKey: Bool;
	final shiftKey: Bool;

	final preventDefault: () -> Void;
	final defaultPrevented: () -> Bool;

	/**
		Reference to original native event object – type varies between platform
	**/
	final nativeEvent: #if js js.html.KeyboardEvent #else Dynamic #end;

}

/**
	See https://w3c.github.io/uievents/#dom-keyboardevent-dom_key_location_standard
**/
enum abstract KeyLocation(Int) to Int from Int {
	var STANDARD = 0;
	var LEFT = 1;
	var RIGHT = 2;
	var NUMPAD = 3;
}