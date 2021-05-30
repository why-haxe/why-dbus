package why.dbus;

import why.dbus.Signature;
import haxe.macro.Expr;
import tink.macro.BuildCache;
import why.dbus.macro.Helpers.*;

using tink.CoreApi;
using tink.MacroApi;

class Object {
	public static function build() {
		return BuildCache.getType('why.dbus.Object', (ctx:BuildContext) -> {
			final name = ctx.name;
			final type = ctx.type;
			
			switch type.getFields() {
				case Success(fields):
					
					final ct = type.toComplex();
					final iface = ct.toString();
					final init = [];
					
					final def = macro class $name extends why.dbus.Object.ObjectBase implements why.dbus.Interface<$ct> {
						final __iface:String;
						public function new(transport, destination, path) {
							super(transport, destination, path);
							__iface = $v{iface};
							$b{init}
						}
					}
					
					for(f in fields) {
						final name = switch f.meta.extract(':member') {
							case []: capitalize(f.name);
							case [{params: [{expr: EConst(CString(name))}]}]: name;
							case _: f.pos.error('Invalid use of @:member');
						}
						switch f.type.reduce() {
							case TFun(args, ret):
								final parser = {
									final sig = SignatureCode.fromType(ret);
									sig.isEmpty() ? macro why.dbus.Object.ObjectBase.__parseEmptyResponse : macro why.dbus.Object.ObjectBase.__parseResponse.bind(${sig});
								}
							
								def.fields.push({
									access: [APublic],
									name: f.name,
									pos: f.pos,
									kind: FFun({
										args: args.map(arg -> ({name: arg.name, type: arg.t.toComplex(), opt: arg.opt}:FunctionArg)),
										ret: asynchronize(ret),
										expr: macro return __call(
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
									kind: FVar(f.type.toComplex()),
								});
								
								init.push(macro $i{f.name} = __signal(__iface, $v{name}, ${(types:SignatureCode)}));
								
							case t:
								final ct = t.toComplex();
								def.fields.push({
									access: [APublic, AFinal],
									name: f.name,
									pos: f.pos,
									kind: FVar(macro:why.dbus.Property<$ct>),
								});
								
								init.push(macro $i{f.name} = __property(__iface, $v{name}, ${SignatureCode.fromType(t)}));
						}
					}
					
					def.pack = ['why', 'dbus'];
					def;
				case Failure(e):
					ctx.pos.error(e);
			}
		});
	}
	
	static function capitalize(v:String) {
		return v.charAt(0).toUpperCase() + v.substr(1);
	}
}