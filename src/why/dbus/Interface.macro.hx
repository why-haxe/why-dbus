package why.dbus;

import tink.macro.BuildCache;
import haxe.macro.Expr;
import why.dbus.macro.Helpers.*;

using tink.CoreApi;
using tink.MacroApi;

class Interface {
	public static function build() {
		return BuildCache.getType('why.dbus.Interface', (ctx:BuildContext) -> {
			final name = ctx.name;
			final type = ctx.type;
			
			switch type.getFields() {
				case Success(fields):
					final def = macro class $name {}
					for(f in fields)
						def.fields.push({
							name: f.name,
							pos: f.pos,
							kind: switch f.type {
								case TFun(args, ret):
									FFun({
										args: args.map(arg -> ({name: arg.name, type: arg.t.toComplex(), opt: arg.opt}:FunctionArg)),
										ret: asynchronize(ret),
									});
								case _:
									throw 'TODO: [why.dbus.Interface] handle non function in ';
							}
						});
					def.kind = TDClass(null, [], true, false, false);
					def.pack = ['why', 'dbus'];
					def;
				case Failure(e):
					ctx.pos.error(e);
			}
		});
	}
}