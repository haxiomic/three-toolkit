package tool;

class StructureTools {

	static public function extend<T>(base: T, extendWidth: Any): T {
		var extended = {};
		if (base != null) for (field in Reflect.fields(base)) {
			Reflect.setField(extended, field, Reflect.field(base, field));
		}
		if (extendWidth != null) for (field in Reflect.fields(extendWidth)) {
			Reflect.setField(extended, field, Reflect.field(extendWidth, field));
		}
		return cast extended;
	}

}