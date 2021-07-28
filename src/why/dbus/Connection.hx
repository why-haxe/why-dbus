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
				
				function reply(outcome:Outcome<OutgoingReturnMessage, Error>) {
					pair.b.invoke(switch outcome {
						case Success(result):
							Success(result);
						case Failure(error):
							Failure(({
								name: error.message,
								signature: cast '', // TODO: encode error data
								body: [], // TODO: encode error data
							}:OutgoingErrorMessage));
					});
				}
				
				if(message.path == path) {
					if(message.iface == 'org.freedesktop.DBus.Properties') {
						if(message.body[0] == iface) {
							properties.route(message).handle(reply);
						}
					} else if(message.iface == iface) {
						router.route(message).handle(reply);
					}
				}
			}),
			
			// forward signals
			router.signals.handle(transport.emit),
		];
	}
}