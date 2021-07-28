package;

import why.dbus.*;
import why.dbus.types.*;

using tink.CoreApi;

@:asserts
class ServerTest {
	public function new() {}
	
	public function test() {
		final cnx1 = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		final cnx2 = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		
		
		final obj = cnx1.getInterface('org.freedesktop.DBus', '/org/freedesktop/DBus', org.freedesktop.DBus);
		obj.requestName('why.dbus.ServerTest', 0)
			.handle(_ -> cnx1.exportInterface('/path/to/object', (new Properties():org.freedesktop.DBus.Properties)));
			
		return asserts.done();
	}
}


class Properties implements why.dbus.server.Interface<org.freedesktop.DBus.Properties> {
	public final propertiesChanged:why.dbus.server.Signal<String, Map<String, Variant>, Array<String>> = tink.core.Signal.trigger();
	
	final interfaces:Map<String, Map<String, Variant>> = [];
	
	public function new() {}
	
	public function get(iface:String, name:String):Promise<Variant> {
		return switch interfaces[iface] {
			case null:
				new Error(NotFound, 'Interface Not Found');
			case _[name] => null:
				new Error(NotFound, 'Property Not Found');
			case _[name] => v:
				v;
		}
	}
	
	public function getAll(iface:String):Promise<Map<String, Variant>> {
		return switch interfaces[iface] {
			case null:
				new Error(NotFound, 'Interface Not Found');
			case v:
				v;
		} 
	}
	
	public function set(iface:String, name:String, value:Variant):Promise<Noise> {
		return switch interfaces[iface] {
			case null:
				new Error(NotFound, 'Interface Not Found');
			case props:
				final original = props[name];
				props[name] = value;
				// TODO: emit signal
				// if(original.signature == value.signature) ...
				
				Promise.NOISE;
		} 
	}
}