package why.dbus.client;

import haxe.macro.Context;
import haxe.macro.Expr;

using tink.MacroApi;

class Object {
	public macro static function getInterface(ethis:Expr, type:Expr):Expr {
		final ct = Context.getType(type.toString()).toComplex();
		return macro @:privateAccess new why.dbus.client.Interface<$ct>($ethis);
	}
}