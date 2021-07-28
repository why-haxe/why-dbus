package why.dbus.client;

using why.dbus.Signature;
using tink.CoreApi;

@:genericBuild(why.dbus.client.Object.build())
class Object<T> {}

class ObjectBase {
	final __transport:Transport;
	final __destination:String;
	final __path:String;
	
	public function new(transport, destination, path) {
		__transport = transport;
		__destination = destination;
		__path = path;
	}
	
	function __signal<T>(iface:String, member:String, signature:SignatureCode):Signal<T> {
		return new Signal(cb -> {
			final binding = __transport.signals.select(
				message -> {
					return if(
						(__path == null || message.path == __path) &&
						message.iface == iface && 
						message.member == member &&
						message.signature == signature
					)
						Some(cast message.body);
					else
						None;
				}
			).handle(cb);
			final registrar = new why.dbus.client.Object<org.freedesktop.DBus>(__transport, 'org.freedesktop.DBus', '/org/freedesktop/DBus');
			final rule = new why.dbus.MatchRule({type: Signal, sender: __destination, path: __path, iface: iface, member: member}).toString();
			
			registrar
				.addMatch(rule)
				.eager();
				// .handle(o -> switch o {
				// 	case Success(_): trace('registered signal: $rule');
				// 	case Failure(e): trace('failed to register signal: $rule, reason: $e');
				// });
				
			() -> {
				registrar.removeMatch(rule).eager();
				binding.cancel();
			}
		});
	}
	
	function __property<T>(iface, name, signature, optional):Property<T> {
		return new Property<T>(__transport, __destination, __path, iface, name, signature, optional);
	}
	
	function __call<T>(iface, name, signature, body, parser, ?pos):Promise<T> {
		return __transport.call({
			destination: __destination,
			path: __path,
			iface: iface,
			member: name,
			signature: signature,
			body: body,
		}, pos).next(parser);
	}
	
	static function __parseEmptyResponse(message:Message):Promise<Noise> {
		return 
			if(message.signature.isEmpty())
				Promise.NOISE;
			else
				new Error('Unexpected return of type "${message.signature}"');
	}
	
	static function __parseResponse<T>(expectedSignature:SignatureCode, message:Message):Promise<T> {
		return
			if(message.signature.isEmpty())
				new Error('Unexpected empty return');
			else if(expectedSignature == message.signature)
				Promise.resolve((message.body[0]:T));
			else
				new Error('Unexpected return type, perhaps the definition is wrong? Expected "$expectedSignature", got "${message.signature}"');
				
			// TODO: new Error('Multi-return is not supported.');
	}
}