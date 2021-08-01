package why.dbus.client;

import why.dbus.Signature;
import haxe.macro.Expr;
import tink.macro.BuildCache;
import why.dbus.macro.Helpers.*;

using why.dbus.util.Tools;
using tink.CoreApi;
using tink.MacroApi;

class Interface {
	public static function build() {
		return BuildCache.getType('why.dbus.client.Interface', (ctx:BuildContext) -> {
			final name = ctx.name;
			final type = ctx.type;
			
			switch type.getFields() {
				case Success(fields):
					
					final ct = type.toComplex();
					final iface = type.getInterfaceName();
					final init = [];
					
					final def = macro class $name extends why.dbus.client.Interface.InterfaceBase {
						final __iface:String;
						public function new(object) {
							super(object);
							__iface = $v{iface};
							$b{init}
						}
					}
					
					for(f in fields) {
						final name = f.getMemberName();
						
						switch f.type.reduce() {
							case TFun(args, ret):
								final parser = {
									final sig = SignatureCode.fromType(ret);
									sig.isEmpty() ? macro why.dbus.client.Interface.InterfaceBase.__parseEmptyResponse : macro why.dbus.client.Interface.InterfaceBase.__parseResponse.bind(${sig});
								}
							
								def.fields.push({
									access: [APublic],
									name: f.name,
									pos: f.pos,
									kind: FFun({
										args: args.map(arg -> ({name: arg.name, type: arg.t.toComplex(), opt: arg.opt}:FunctionArg)),
										ret: asynchronize(ret),
										expr: macro @:pos(f.pos) return __call(
											__iface,
											$v{name},
											${(args.map(arg -> arg.t):SignatureCode)},
											$a{args.map(arg -> macro $i{arg.name})},
											$parser
										),
									}),
								});
								
							case getSignal(_) => Some(types):
								def.fields.push({
									access: [APublic, AFinal],
									name: f.name,
									pos: f.pos,
									kind: FVar(TPath('why.dbus.client.Signal'.asTypePath(types.map(t -> TPType(t.toComplex()))))),
								});
								
								init.push(macro $i{f.name} = __signal(__iface, $v{name}, ${(types:SignatureCode)}));
								
							case t:
								final optional = f.meta.has(':optional');
								final ct = t.toComplex();
								def.fields.push({
									access: [APublic, AFinal],
									name: f.name,
									pos: f.pos,
									kind: FVar(macro:why.dbus.client.Property<$ct>),
								});
								
								init.push(macro $i{f.name} = __property(__iface, $v{name}, ${SignatureCode.fromType(t)}, $v{optional}));
						}
					}
					
					def.pack = ['why', 'dbus', 'client'];
					def;
				case Failure(e):
					ctx.pos.error(e);
			}
		});
	}
}