package why.dbus;

import haxe.macro.Context;
import haxe.macro.Expr;

using tink.CoreApi;
using tink.MacroApi;

class Connection {
	
	public macro function exportObject(ethis:Expr, path:ExprOf<String>, interfaces:Array<Expr>):ExprOf<CallbackLink> {
		final vars:Array<Var> = [];
		final propsParams = [];
		final propsArgs = [];
		final propsTp = 'why.dbus.server.Properties'.asTypePath(propsParams);
		final routers = [macro 'org.freedesktop.DBus.Properties' => new why.dbus.server.Router<org.freedesktop.DBus.Properties>(path, 'org.freedesktop.DBus.Properties', new $propsTp($a{propsArgs}))];
		
		for(i => iface in interfaces) {
			switch iface {
				case macro ($value:$ct):
					final ident = 'v$i';
					final iface = ct.toString();
					vars.push({name: ident, expr: value});
					routers.push(macro $v{iface} => new why.dbus.server.Router<$ct>(path, $v{iface}, $i{ident}));
					propsParams.push(TPType(ct));
					propsArgs.push(macro $i{ident});
				case _:
					iface.pos.error('Expected check type syntax');
			}
		}
		
		return macro {
			${EVars(vars).at()}
			final path = $path;
			@:privateAccess $ethis.export(new why.dbus.server.Object(path, ${macro $a{routers}}));
		}
	}
}