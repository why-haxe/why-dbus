package why.dbus.server;

import why.dbus.server.Router;
import why.dbus.Message;

using tink.CoreApi;

class Object {
	public final path:String;
	public final signals:Signal<OutgoingSignalMessage>;
	
	final interfaces:Map<String, RouterObject>;
	
	public function new(path, interfaces) {
		this.path = path;
		this.interfaces = interfaces;
		this.signals = new Signal(cb -> [for(name => iface in interfaces) iface.signals.handle(payload -> cb(({
			path: path,
			iface: name,
			member: payload.member,
			signature: payload.signature,
			body: payload.body,
		}:OutgoingSignalMessage)))]);
	}
	
	public function route(message:IncomingCallMessage):Promise<OutgoingReturnMessage> {
		return switch interfaces[message.iface] {
			case null: new Error(NotFound, 'Interface "${message.iface}" not found on $path');
			case router: router.route(message);
		}
	}
}