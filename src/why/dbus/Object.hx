package why.dbus;

using why.dbus.Signature;
using tink.CoreApi;

@:genericBuild(why.dbus.Object.build())
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
	
	function __filterSignal<T>(iface, name, signature:Signature.SignatureCode, extract:Message->T, message:Message):Option<T> {
		return if(
			(__path == null || message.path == __path) &&
			message.iface == iface && 
			message.member == name &&
			message.signature == signature
		)
			Some(extract(message));
		else
			None;
	}
	
	function __property<T>(iface, name, signature):Property<T> {
		return new Property<T>(__transport, __destination, __path, iface, name, signature);
	}
	
	function __call<T>(iface, name, signature, body, parser):Promise<T> {
		return __transport.call({
			type: MethodCall,
			destination: __destination,
			path: __path,
			iface: iface,
			member: name,
			signature: signature,
			body: body,
		}).next(parser);
	}
	
	function __parseEmptyResponse(message:Message):Promise<Noise> {
		return 
			if(message.signature.isEmpty())
				Promise.NOISE;
			else
				new Error('Unexpected return of type "${message.signature}"');
	}
	
	function __parseResponse<T>(expectedSignature:SignatureCode, message:Message):Promise<T> {
		return
			if(message.signature.isEmpty())
				new Error('Unexpected empty return');
			else if(expectedSignature == message.signature)
				Promise.resolve(message.body[0]);
			else
				new Error('Unexpected return type, perhaps the definition is wrong? Expected "$expectedSignature", got "${message.signature}"');
				
			// TODO: new Error('Multi-return is not supported.');
	}
}