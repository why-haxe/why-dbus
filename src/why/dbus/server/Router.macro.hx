package why.dbus.server;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import tink.macro.BuildCache;
import why.dbus.Signature;
import why.dbus.util.Tools.*;
import why.dbus.macro.Helpers.*;

using tink.MacroApi;

class Router {
	static final INCOMING = macro:why.dbus.Message.IncomingCallMessage;
	static final OUTGOING = macro:why.dbus.Message.OutgoingReturnMessage;
	
	public static function build() {
		return BuildCache.getType('why.dbus.server.Router', (ctx:BuildContext) -> {
			final name = ctx.name;
			final type = ctx.type;
			final ct = type.toComplex();
			
			final cases:Array<Case> = [];
			final listeners:Array<Expr> = [];
			final collectBody = macro $a{listeners};
			
			final def = macro class $name extends why.dbus.server.Router.RouterBase<why.dbus.server.Interface<$ct>> {
				public function route(message:$INCOMING):tink.core.Promise<$OUTGOING> {
					final member = message.member;
					final body = message.body;
					return ${ESwitch(macro member, cases, macro tink.core.Promise.reject(new tink.core.Error(BadRequest, 'Unknown member "' + member  + '"'))).at()};
				}
				
				public function collect(cb:why.dbus.server.Router.SignalPayload->Void):tink.core.Callback.CallbackLink {
					return $collectBody;
				}
			}
			
			
			switch type.getFields() {
				case Success(fields):
					for(f in fields) {
						final fname = f.name;
						switch f.type.reduce() {
							case TFun(args, unwrap(_) => ret):
								final ct = ret.toComplex();
								cases.push({
									values: [macro $v{capitalize(f.name)}],
									expr: {
										final callArgs = [for(i in 0...args.length) macro body[$v{i}]];
										macro @:pos(f.pos) (target.$fname($a{callArgs}):tink.core.Promise<$ct>)
											.next(value -> ({
												signature: ${(ret:SignatureCode)},
												body: [value],
											}:$OUTGOING));
									}
								});
								
							case getSignal(_) => Some(types): 
								listeners.push(macro target.$fname.listen(body -> cb({
									member: $v{capitalize(f.name)},
									signature: ${(types:SignatureCode)},
									body: body,
								})));
								
							case _:
						}
					}
				case Failure(e):
					throw e;
			}
			
			// optimization: return null CallbackLink if there are no listeners
			if(listeners.length == 0) {
				collectBody.expr = EConst(CIdent('null'));
			}
			
			def.pack = ['why', 'dbus', 'server'];
			def;
		});
	}
} 