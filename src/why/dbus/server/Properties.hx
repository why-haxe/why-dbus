package why.dbus.server;

import why.dbus.Message;
import why.dbus.types.*;

using tink.CoreApi;

@:genericBuild(why.dbus.server.Properties.build())
class Properties<T> {}

abstract class PropertiesBase<T> implements Router.RouterObject {
	public final signals:Signal<OutgoingSignalMessage>;
	public final target:T;
	
	public function new(target) {
		this.target = target;
		this.signals = new Signal(cb -> null); // TODO
	}
	
	public function route(message:IncomingCallMessage):Promise<OutgoingReturnMessage> {
		return switch message.member {
			case 'Get':
				get(message.body[1]).next(v -> ({
					signature: Signature.Variant,
					body: [v],
				}:OutgoingReturnMessage));
			case 'GetAll':
				getAll().next(v -> ({
					signature: Signature.Array(DictEntry(String, Variant)),
					body: [v],
				}:OutgoingReturnMessage));
			case 'Set':
				set(message.body[1], message.body[2]).next(v -> ({
					signature: cast '',
					body: [],
				}:OutgoingReturnMessage));
			case member:
				new Error(BadRequest, 'Unknown member "' + member  + '"');
		}
	}
	
	abstract function get(name:String):Promise<Variant>;
	abstract function getAll():Promise<Map<String, Variant>>;
	abstract function set(name:String, value:Variant):Promise<Noise>;
}