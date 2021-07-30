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
	
	public macro function exportObject(ethis:Expr, path:ExprOf<String>, interfaces:Array<Expr>):ExprOf<CallbackLink> {
		final vars:Array<Var> = [];
		final routers = [];
		final properties = [];
		
		for(i => iface in interfaces) {
			switch iface {
				case macro ($value:$ct):
					final ident = 'v$i';
					final iface = ct.toString();
					vars.push({name: ident, expr: value});
					routers.push(macro $v{iface} => new why.dbus.server.Router<$ct>(path, $v{iface}, $i{ident}));
					properties.push(macro $v{iface} => new why.dbus.server.Properties<$ct>($i{ident}));
				case _:
					iface.pos.error('Expected check type syntax');
			}
		}
		
		return macro {
			${EVars(vars).at()}
			final path = $path;
			@:privateAccess $ethis.export(new why.dbus.server.Object(path, ${macro $a{routers}}, ${macro $a{properties}}));
		}
	}
}