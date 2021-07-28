package why.dbus;

import haxe.macro.Expr;
import tink.macro.BuildCache;

using tink.MacroApi;

class Signal {
	public static function build() {
		return BuildCache.getTypeN('why.dbus.Signal', (ctx:BuildContextN) -> {
			final name = ctx.name;
			final ct = TPath('why.dbus.Body.BodyArray${ctx.types.length}'.asTypePath(ctx.types.map(t -> TPType(t.toComplex()))));
			final def = macro class $name {}
			def.kind = TDAbstract(ct, [ct], [ct]);
			def.pack = ['why', 'dbus'];
			def;
		});
	}
}