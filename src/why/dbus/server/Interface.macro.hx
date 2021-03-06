package why.dbus.server;

import tink.macro.BuildCache;
import haxe.macro.Expr;
import why.dbus.macro.Helpers.*;

using tink.CoreApi;
using tink.MacroApi;

class Interface {
	public static function build() {
		return BuildCache.getType('why.dbus.server.Interface', (ctx:BuildContext) -> {
			final name = ctx.name;
			final type = ctx.type;
			
			switch type.getFields() {
				case Success(fields):
					final def = macro class $name {}
					for(f in fields)
						switch f.type.reduce() {
							case TFun(args, ret):
								def.fields.push({
									name: f.name,
									pos: f.pos,
									kind: FFun({
										args: args.map(arg -> ({name: arg.name, type: arg.t.toComplex(), opt: arg.opt}:FunctionArg)),
										ret: asynchronize(ret),
									}),
								});
						
							case getSignal(_) => Some(types): 
								def.fields.push({
									access: [AFinal],
									name: f.name,
									pos: f.pos,
									kind: FVar(TPath('why.dbus.server.Signal'.asTypePath(types.map(t -> TPType(t.toComplex()))))),
								});
								
							case t:
								final ct = t.toComplex();
								def.fields.push({
									access: [AFinal],
									name: f.name,
									pos: f.pos,
									kind: FVar(switch [f.meta.has(':readonly'), f.meta.has(':writeonly')] {
										case [true, true]:
											f.pos.error('Either @:readonly or @:writeonly, but not both');
										case [true, false]:
											macro:why.dbus.server.Property.ReadableProperty<$ct>;
										case [false, true]:
											macro:why.dbus.server.Property.WritableProperty<$ct>;
										case [false, false]:
											macro:why.dbus.server.Property.ReadWriteProperty<$ct>;
									}),
								});
						}
					def.kind = TDClass(null, [], true, false, false);
					def.pack = ['why', 'dbus', 'server'];
					def;
				case Failure(e):
					ctx.pos.error(e);
			}
		});
	}
}