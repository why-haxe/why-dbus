package why.dbus.server;

import why.dbus.types.*;

using tink.CoreApi;

@:genericBuild(why.dbus.server.Properties.build())
class Properties<Rest> {}

class PropertiesBase implements Interface<org.freedesktop.DBus.Properties> {
	public final propertiesChanged:why.dbus.server.Signal<String, Map<String, Variant>, Array<String>> = Signal.trigger(); // TODO
	
	final map:Map<String, InterfacePropertiesObject>;
	
	public function new(map) {
		this.map = map;
	}
	
	public function get(iface:String, name:String):Promise<Variant> {
		return forward(iface, props -> props.get(name));
	}
	
	public function getAll(iface:String):Promise<Map<String, Variant>> {
		return forward(iface, props -> props.getAll());
	}
	
	public function set(iface:String, name:String, value:Variant):Promise<Noise> {
		return forward(iface, props -> props.set(name, value));
	}
	
	inline function forward<T>(iface, f:InterfacePropertiesObject->Promise<T>):Promise<T> {
		return switch map[iface] {
			case null: new Error(NotFound, 'Interface Not Found');
			case v: f(v);
		}
	}
	
}

@:genericBuild(why.dbus.server.Properties.InterfaceProperties.build())
class InterfaceProperties<T> {}

interface InterfacePropertiesObject {
	function get(name:String):Promise<Variant>;
	function getAll():Promise<Map<String, Variant>>;
	function set(name:String, value:Variant):Promise<Noise>;
}