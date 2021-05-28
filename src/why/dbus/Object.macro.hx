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
						public function new(transport, destination, path) {
							super(transport, destination, path);
							$b{init}
						}
					}
					
					for(f in fields) 
						switch f.type {
							case TFun(args, ret):
								final argSigs = args.map(arg -> SignatureTools.fromType(arg.t).force());
								final parser = switch SignatureTools.fromType(ret) {
									case None: macro __parseEmptyResponse;
									case Some(retSig): macro __parseResponse.bind($v{retSig});
								}
							
								def.fields.push({
									access: [APublic],
									name: f.name,
									pos: f.pos,
									kind: FFun({
										args: args.map(arg -> ({name: arg.name, type: arg.t.toComplex(), opt: arg.opt}:FunctionArg)),
										ret: asynchronize(ret),
										expr: macro return __transport.call({
											type: MethodCall,
											destination: __destination,
											path: __path,
											iface: $v{iface},
											member: $v{capitalize(f.name)},
											signature: $v{argSigs},
											body: $a{args.map(arg -> macro $i{arg.name})},
										}).next($parser),
									}),
								});
							case t:
								final ct = t.toComplex();
								def.fields.push({
									access: [APublic, AFinal],
									name: f.name,
									pos: f.pos,
									kind: FVar(macro:why.dbus.Property<$ct>),
								});
								
								init.push(macro $i{f.name} = new why.dbus.Property<$ct>(__transport, __destination, __path, $v{iface}, $v{capitalize(f.name)}, $v{SignatureTools.fromType(t).force()}));
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