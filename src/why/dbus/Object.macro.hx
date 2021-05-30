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
					
					for(f in fields) 
						switch f.type.reduce() {
							case TFun(args, ret):
								final argSigs:SignatureCode = args.map(arg -> arg.t);
								final parser = {
									final sig = SignatureCode.fromType(ret);
									sig.isEmpty() ? macro __parseEmptyResponse : macro __parseResponse.bind(${makeSigExpr(sig)});
								}
							
								def.fields.push({
									access: [APublic],
									name: f.name,
									pos: f.pos,
									kind: FFun({
										args: args.map(arg -> ({name: arg.name, type: arg.t.toComplex(), opt: arg.opt}:FunctionArg)),
										ret: asynchronize(ret),
										expr: macro return __call(__iface, $v{capitalize(f.name)}, ${makeSigExpr(argSigs)}, $a{args.map(arg -> macro $i{arg.name})}, $parser),
									}),
								});
								
							case getSignal(_) => Some(types):
								final sig:SignatureCode = types;
								def.fields.push({
									access: [APublic, AFinal],
									name: f.name,
									pos: f.pos,
									kind: FVar(f.type.toComplex()),
								});
								
								init.push(macro $i{f.name} = new tink.core.Signal(cb -> {
									final binding = __transport.signals.select(__filterSignal.bind(__iface, $v{capitalize(f.name)}, ${makeSigExpr(sig)}, msg -> msg.body)).handle(cb);
									
									final registrar = new why.dbus.Object<org.freedesktop.DBus>(__transport, 'org.freedesktop.DBus', '/org/freedesktop/DBus');
									final rule = new why.dbus.MatchRule({type: Signal, sender: __destination, path: __path, iface: __iface, member: $v{capitalize(f.name)}}).toString();
									
									registrar
										.addMatch(rule)
										.eager();
										// .handle(o -> switch o {
										// 	case Success(_): trace('registered signal: $rule');
										// 	case Failure(e): trace('failed to register signal: $rule, reason: $e');
										// });
										
									() -> {
										registrar.removeMatch(rule).eager();
										binding.cancel();
									}
								}));
								
							case t:
								final ct = t.toComplex();
								def.fields.push({
									access: [APublic, AFinal],
									name: f.name,
									pos: f.pos,
									kind: FVar(macro:why.dbus.Property<$ct>),
								});
								
								init.push(macro $i{f.name} = __property(__iface, $v{capitalize(f.name)}, ${makeSigExpr(SignatureCode.fromType(t))}));
						}
					
					def.pack = ['why', 'dbus'];
					def;
				case Failure(e):
					ctx.pos.error(e);
			}
		});
	}
	
	static function makeSigExpr(sig:SignatureCode) {
		return macro @:privateAccess new why.dbus.Signature.SignatureCode($v{sig});
	}
	
	static function capitalize(v:String) {
		return v.charAt(0).toUpperCase() + v.substr(1);
	}
}