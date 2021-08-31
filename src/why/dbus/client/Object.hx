package why.dbus.client;

class Object {
	public final destination:Destination;
	public final path:String;
	
	public var properties(get, null):Interface<org.freedesktop.DBus.Properties>;
	public var introspectable(get, null):Interface<org.freedesktop.DBus.Introspectable>;
	
	public function new(destination, path) {
		this.destination = destination;
		this.path = path;
	}
	
	function get_properties() {
		if(properties == null) properties = getInterface(org.freedesktop.DBus.Properties);
		return properties;
	}
	
	function get_introspectable() {
		if(introspectable == null) introspectable = getInterface(org.freedesktop.DBus.Introspectable);
		return introspectable;
	}
	
	public macro function getInterface(ethis, type);
}