package why.dbus.client;

class Destination {
	public final transport:Transport;
	public final name:String;
	
	public function new(transport, name) {
		this.transport = transport;
		this.name = name;
	}
	
	public inline function getObject(path):Object {
		return new Object(this, path);
	}
}