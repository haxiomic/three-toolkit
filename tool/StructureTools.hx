package tool;

import haxe.macro.Expr;
import haxe.macro.Context;

class StructureTools {

	static public macro function extend(a, b) {
		var aType = Context.followWithAbstracts(Context.typeof(a));
		var bType = Context.followWithAbstracts(Context.typeof(b));

		return switch [aType, bType] {
			case [TAnonymous(aAnon), TAnonymous(bAnon)]:

				var fields: Array<ObjectField> = 
					bAnon.get().fields.map(f -> {
						var name = f.name;
						return ({field: f.name, expr: macro b.$name}: ObjectField);
					});

				for (f in aAnon.get().fields) {
					var name = f.name;
					var hasMatchingField = Lambda.find(fields, g -> g.field == name) != null;
					if (hasMatchingField) continue;
					fields.push({
						field: name,
						expr: macro a.$name
					});
				}

				var objExpr: Expr = {expr: EObjectDecl(fields), pos: Context.currentPos()};

				return macro {
					var a = $a;
					var b = $b;
					$objExpr;
				};
			default:
				return macro @:privateAccess tool.StructureTools.extendAny($a, $b);
				// Context.fatalError('Can only extend structures', Context.currentPos());
		}
	}

	static public function extendAny<T>(base: T, extendWidth: Any): T {
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