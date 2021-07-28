package why.dbus;

import haxe.macro.Context;
import haxe.macro.Expr;

using tink.MacroApi;

class Connection {
	public macro function getInterface(ethis:Expr, destination:ExprOf<String>, path:ExprOf<String>, iface:Expr):Expr {
		final type = Context.getType(iface.toString());
		final ct = type.toComplex();
		return macro (new why.dbus.client.Object<$ct>(@:privateAccess $ethis.transport, $destination, $path):why.dbus.client.Interface<$ct>);
	}
	
	public macro function exportInterface(ethis:Expr, path:ExprOf<String>, instance:Expr):ExprOf<tink.core.Callback.CallbackLink> {
		return switch instance {
			case macro ($value:$ct):
				return macro {
					final transport = @:privateAccess $ethis.transport;
					final path = $path;
					final iface = $v{ct.toString()};
					final target = $value;
					final router = new why.dbus.server.Router<$ct>(path, iface, target);
					final properties = new why.dbus.server.Properties<$ct>(target);
					
					// listen for incoming calls
					transport.calls.handle(pair -> {
						final message = pair.a;
						final reply = (outcome:tink.core.Outcome<why.dbus.Message.OutgoingReturnMessage, Error>) -> {
							pair.b.invoke(switch outcome {
								case Success(result):
									Success(result);
								case Failure(error):
									Failure(({
										name: error.message,
										signature: cast '', // TODO: encode error data
										body: [], // TODO: encode error data
									}:why.dbus.Message.OutgoingErrorMessage));
							});
						}
						
						if(message.path == path) {
							if(message.iface == 'org.freedesktop.DBus.Properties') {
								if(message.body[0] == iface) {
									properties.route(message).handle(reply);
								}
							} else if(message.iface == iface) {
								router.route(message).handle(reply);
							}
						}
					});
					
					// forward signals
					router.signals.handle(transport.emit);
				}
			case _:
				instance.pos.error('Expected check type syntax');
		}
	}
}