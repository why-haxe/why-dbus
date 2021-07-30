package why.dbus;

import haxe.macro.Context;
import haxe.macro.Expr;

using tink.CoreApi;
using tink.MacroApi;

class Connection {
	// public macro function getInterface(ethis:Expr, destination:ExprOf<String>, path:ExprOf<String>, iface:Expr):Expr {
	// 	final type = Context.getType(iface.toString());
	// 	final ct = type.toComplex();
	// 	return macro (new why.dbus.client.Object<$ct>(@:privateAccess $ethis.transport, $destination, $path):why.dbus.client.Interface<$ct>);
	// }
	
	public macro function exportInterface(ethis:Expr, path:ExprOf<String>, instance:Expr):ExprOf<CallbackLink> {
		return switch instance {
			case macro ($value:$ct):
				macro {
					final path = $path;
					final iface = $v{ct.toString()};
					final target = $value;
					@:privateAccess $ethis.export(path, iface, new why.dbus.server.Router<$ct>(path, iface, target), new why.dbus.server.Properties<$ct>(target));
				}
			case _:
				instance.pos.error('Expected check type syntax');
		}
	}
}