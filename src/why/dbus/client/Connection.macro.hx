package why.dbus.client;

import haxe.macro.Context;
import haxe.macro.Expr;

using tink.MacroApi;

class Connection {
	public macro function getInterface(ethis:Expr, destination:ExprOf<String>, path:ExprOf<String>, iface:Expr):Expr {
		final type = Context.getType(iface.toString());
		final ct = type.toComplex();
		return macro (new why.dbus.client.Object<$ct>(@:privateAccess $ethis.transport, $destination, $path):why.dbus.client.Interface<$ct>);
	}
	
	public macro function exportInterface(ethis:Expr, destination:ExprOf<String>, path:ExprOf<String>, instance:Expr):ExprOf<tink.core.Callback.CallbackLink> {
		final type = Context.typeof(instance);
		final ct = type.toComplex();
		
		return macro {
			final router = new why.dbus.Router<$ct>($instance);
			@:privateAccess $ethis.transport.calls.handle(pair -> {
				final message = pair.a;
				final callback = pair.b;
				
				router.route(message).handle(outcome -> {
					switch outcome {
						case Success(result): callback(Success(result));
						case Failure(error): callback(Failure(error));
					}
				});
			});
		}
		// return macro (new why.dbus.Object<$ct>(@:privateAccess $ethis.transport, $destination, $path):why.dbus.Interface<$ct>);
	}
}