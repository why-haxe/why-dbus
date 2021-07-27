package why.dbus;

class Connection {
	final transport:Transport;
	
	public function new(transport) {
		this.transport = transport;
	}
	
	public macro function getInterface(ethis, destination, path, iface);
	// public macro function exportInterface(ethis, destination, path, instance);
}