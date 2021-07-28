package why.dbus;

import why.dbus.server.Router;
import why.dbus.server.Properties;
import why.dbus.Message;

using tink.CoreApi;

class Connection {
	final transport:Transport;
	
	public function new(transport) {
		this.transport = transport;
	}
	
	public macro function getInterface(ethis, destination, path, iface);
	public macro function exportInterface(ethis, path, instance);
	
	function export<T>(path:String, iface:String, router:RouterBase<T>, properties:PropertiesBase<T>):CallbackLink {
		return [
			// listen for incoming calls
			transport.calls.handle(pair -> {
				final message = pair.a;
				
				if(message.path == path) {
					if(message.iface == 'org.freedesktop.DBus.Properties') {
						if(message.body[0] == iface) {
							properties.route(message).handle(o -> pair.b.invoke(createReply(o)));
						}
					} else if(message.iface == iface) {
						router.route(message).handle(o -> pair.b.invoke(createReply(o)));
					}
				}
			}),
			
			// forward signals
			router.signals.handle(transport.emit),
		];
	}
	
	static function createReply(outcome:Outcome<OutgoingReturnMessage, Error>):Outcome<OutgoingReturnMessage, OutgoingErrorMessage> {
		return switch outcome {
			case Success(result):
				Success(result);
			case Failure(error):
				Failure(({
					name: error.message,
					signature: cast '', // TODO: encode error data
					body: [], // TODO: encode error data
				}:OutgoingErrorMessage));
		}
	}
}