package why.dbus.client;

class Object {
	public final transport:Transport;
	public final destination:String;
	public final path:String;
	// public final properties:Interface<org.freedesktop.DBus.Properties>;
	
	public function new(transport, destination, path) {
		this.transport = transport;
		this.destination = destination;
		this.path = path;
	}
	
	public macro function getInterface(ethis, type);
}