package why.dbus;

import haxe.macro.Expr;
import tink.macro.BuildCache;

using tink.MacroApi;

class Body {
	public static function build() {
		return BuildCache.getTypeN('why.dbus.Body', (ctx:BuildContextN) -> {
			final name = ctx.name;
			final ct = TPath('why.dbus.Body.BodyArray${ctx.types.length}'.asTypePath(ctx.types.map(t -> TPType(t.toComplex()))));
			final init = [];
			final ctorArgs = [];
			
			final def = macro class $name {}
			
			for(i => type in ctx.types) {
				final fname = 'v$i';
				init.push(macro $i{fname});
				ctorArgs.push(fname);
				
				def.fields.push({
					access: [APublic],
					name: fname,
					pos: ctx.pos,
					kind: FProp('get', 'never', type.toComplex()),
				});
				def.fields.push({
					access: [AInline],
					name: 'get_$fname',
					pos: ctx.pos,
					kind: FFun({
						args: [],
						ret: type.toComplex(),
						expr: macro return this[$v{i}],
					}),
				});
			}
			
			def.fields.push({
				access: [APublic, AInline],
				name: 'new',
				pos: ctx.pos,
				kind: FFun({
					args: ctorArgs.map(a -> ({name: a, type: null}:FunctionArg)),
					ret: null,
					expr: macro @:pos(ctx.pos) this = $a{init},
				}),
			});
			def.kind = TDAbstract(ct, [ct], [ct]);
			def.pack = ['why', 'dbus'];
			def;
		});
	}
}