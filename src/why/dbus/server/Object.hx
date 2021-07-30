package why.dbus.server;

import why.dbus.server.Router;
import why.dbus.Message;

using tink.CoreApi;

class Object {
	public final path:String;
	public final signals:Signal<OutgoingSignalMessage>;
	
	final interfaces:Map<String, RouterObject>;
	final properties:Map<String, RouterObject>;
	
	public function new(path, interfaces, properties) {
		this.path = path;
		this.interfaces = interfaces;
		this.properties = properties;
		this.signals = new Signal(cb -> [for(iface in interfaces) iface.signals.handle(cb)]);
	}
	
	public function route(message:IncomingCallMessage):Promise<OutgoingReturnMessage> {
		return
			if(message.iface == 'org.freedesktop.DBus.Properties') {
				switch properties[message.body[0]] {
					case null: new Error(NotFound, 'Interface "${message.body[0]}" not found on $path');
					case router: router.route(message);
				}
			} else {
				switch interfaces[message.iface] {
					case null: new Error(NotFound, 'Interface "${message.iface}" not found on $path');
					case router: router.route(message);
				}
			}
	}
}