package why.dbus.client;

import why.dbus.Signature;
import haxe.macro.Expr;
import tink.macro.BuildCache;
import why.dbus.macro.Helpers.*;

using tink.CoreApi;
using tink.MacroApi;

class Signal {
	public static function build() {
		return BuildCache.getTypeN('why.dbus.client.Signal', (ctx:BuildContextN) -> {
			final name = ctx.name;
			final tupleCt = TPath('why.dbus.Body'.asTypePath(ctx.types.map(t -> TPType(t.toComplex()))));
			final signalCt = TPath('tink.core.Signal'.asTypePath([TPType(tupleCt)]));
			
			final def = macro class $name {}
			
			def.fields.push({
				access: [APublic, AInline],
				name: 'handle',
				pos: ctx.pos,
				kind: FFun({
					args: [({name: 'f'}:FunctionArg)],
					ret: macro:tink.core.Callback.CallbackLink,
					expr: {
						final args = [for(i in 0...ctx.types.length) {
							final name = 'v$i';
							macro body.$name;
						}];
						macro return this.handle(body -> f($a{args}));
					},
				})
			});
			
			def.meta = [{pos: ctx.pos, name: ':forward'}];
			def.kind = TDAbstract(signalCt, [signalCt], [signalCt]);
			def.pack = ['why', 'dbus', 'client'];
			def;
		});
	}
}