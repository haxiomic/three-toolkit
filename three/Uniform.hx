package three;

@:jsRequire("three", "Uniform") extern class Uniform<T> {
	@:overload(function(type:String, value:T): Uniform<T> { })
	function new(value:T);
	var type : String;
	var value : T;
	@:native("dynamic")
	var dynamic_ : Bool;
	var onUpdateCallback : haxe.Constraints.Function;
	function onUpdate(callback:haxe.Constraints.Function):Uniform<T>;
	static var prototype : Uniform<Any>;
}