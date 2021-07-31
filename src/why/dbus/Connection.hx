package why.dbus;

import why.dbus.server.Router;
import why.dbus.server.Properties;
import why.dbus.Message;

using tink.CoreApi;

class Connection {
	public final bus:why.dbus.client.Interface<org.freedesktop.DBus>;
	final transport:Transport;
	
	public function new(transport) {
		this.transport = transport;
		
		bus = getDestination('org.freedesktop.DBus').getObject('/org/freedesktop/DBus').getInterface(org.freedesktop.DBus);
	}
	
	public inline function getDestination(destination) {
		return new why.dbus.client.Destination(transport, destination);
	}
	
	public macro function exportObject(ethis, path, interfaces);
	
	function export(object:why.dbus.server.Object):CallbackLink {
		return [
			// listen for incoming calls
			transport.calls.handle(pair -> {
				final message = pair.a;
				if(message.path == object.path)
					object.route(message).handle(o -> pair.b.invoke(createReply(o)));
			}),
			
			// forward signals
			object.signals.handle(transport.emit),
		];
	}
	
	static function createReply(outcome:Outcome<OutgoingReturnMessage, Error>):Outcome<OutgoingReturnMessage, OutgoingErrorMessage> {
		return switch outcome {
			case Success(result):
				Success(result);
			case Failure(error):
				Failure(({
					name: error.message, // TODO: use well-known error names e.g. org.freedesktop.DBus.Error.InvalidArgs
					signature: cast '', // TODO: encode error data
					body: [], // TODO: encode error data
				}:OutgoingErrorMessage));
		}
	}
}