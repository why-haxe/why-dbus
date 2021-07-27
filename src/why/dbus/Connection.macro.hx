package why.dbus;

import haxe.macro.Context;
import haxe.macro.Expr;

using tink.MacroApi;

class Connection {
	public macro function getInterface(ethis:Expr, destination:ExprOf<String>, path:ExprOf<String>, iface:Expr):Expr {
		final type = Context.getType(iface.toString());
		final ct = type.toComplex();
		return macro (new why.dbus.Object<$ct>(@:privateAccess $ethis.transport, $destination, $path):why.dbus.Interface<$ct>);
	}
	
	// public macro function exportInterface(ethis:Expr, destination:ExprOf<String>, path:ExprOf<String>, instance:Expr):ExprOf<tink.core.Callback.CallbackLink> {
	// 	final type = Context.typeof(instance);
	// 	final ct = type.toComplex();
		
		
	// 	return macro null;
	// 	// return macro (new why.dbus.Object<$ct>(@:privateAccess $ethis.transport, $destination, $path):why.dbus.Interface<$ct>);
	// }
}