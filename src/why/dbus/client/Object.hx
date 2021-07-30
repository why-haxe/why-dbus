package why.dbus.client;

class Object {
	public final destination:Destination;
	public final path:String;
	
	public final properties:Interface<org.freedesktop.DBus.Properties>;
	public final introspectable:Interface<org.freedesktop.DBus.Introspectable>;
	
	public function new(destination, path) {
		this.destination = destination;
		this.path = path;
		
		this.properties = getInterface(org.freedesktop.DBus.Properties);
		this.introspectable = getInterface(org.freedesktop.DBus.Introspectable);
	}
	
	public macro function getInterface(ethis, type);
}