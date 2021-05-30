package why.dbus;

import why.dbus.Signature;
import haxe.macro.Expr;
import tink.macro.BuildCache;
import why.dbus.macro.Helpers.*;

using tink.CoreApi;
using tink.MacroApi;

class Signal {
	public static function build() {
		return BuildCache.getTypeN('why.dbus.Signal', (ctx:BuildContextN) -> {
			final name = ctx.name;
			final tupleCt = TPath('why.Tuple'.asTypePath(ctx.types.map(t -> TPType(t.toComplex()))));
			final signalCt = TPath('tink.core.Signal'.asTypePath([TPType(tupleCt)]));
			
			final def = macro class $name {}
			
			def.fields.push({
				access: [APublic, AInline],
				name: 'handle',
				pos: ctx.pos,
				kind: FFun({
					args: [({name: 'f'}:FunctionArg)],
					ret: macro:tink.core.Callback.CallbackLink,
					expr: macro return this.handle(tuple -> {}),
				})
			});
			
			def.meta = [{pos: ctx.pos, name: ':forward'}];
			def.kind = TDAbstract(signalCt, [signalCt], [signalCt]);
			def.pack = ['why', 'dbus'];
			def;
		});
	}
}