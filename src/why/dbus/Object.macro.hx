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
					
					final def = macro class $name extends why.dbus.Object.ObjectBase implements why.dbus.Interface<$ct> {}
					
					for(f in fields) 
						switch f.type {
							case TFun(args, ret):
								final argSigs = args.map(arg -> SignatureTools.fromType(arg.t).force());
							
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
											signature: $v{argSigs},
											body: $a{args.map(arg -> macro $i{arg.name})},
											member: $v{capitalize(f.name)},
										}).next(msg -> {
											${switch SignatureTools.fromType(ret) {
												case None:
													macro switch msg.signature {
														case []: 
															macro tink.core.Promise.NOISE;
														case sigs:
															new tink.core.Error('Unexpected return of type "' + why.dbus.Signature.SignatureTools.toTypeCode(sigs) + '" ');
													}
													
												case Some(retSig):
													macro switch msg.signature {
														case []: 
															new tink.core.Error('Unexpected empty return');
														case [sig]:
															if(sig.eq($v{retSig}))
																tink.core.Promise.resolve(msg.body[0]);
															else
																new tink.core.Error('Unexpected return type, perhaps the definition is wrong? Expected "' + $v{retSig.toSingleTypeCode()} +'", got "' + why.dbus.Signature.SignatureTools.toTypeCode(msg.signature) + '"');
														case v:
															new tink.core.Error('Multi-return is not supported.');
													}
											}}
												
										}),
									}),
								});
							case _:
								throw 'TODO';
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