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
	
	function __filterSignal<T>(iface, name, signature:Signature, extract:Message->T, message:Message):Option<T> {
		trace('================================');
		trace('path', message.path, __path);
		trace('iface', message.iface, iface);
		trace('member', message.member, name);
		trace('signature', message.signature, signature);
		trace('signature', message.signature.toTypeCode(), signature.toSingleTypeCode());
		return if(
			(__path == null || message.path == __path) &&
			message.iface == iface && 
			message.member == name &&
			message.signature.toTypeCode() == signature.toSingleTypeCode()
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
		return switch message.signature {
			case []: 
				Promise.NOISE;
			case sigs:
				new Error('Unexpected return of type "${why.dbus.Signature.SignatureTools.toTypeCode(sigs)}" ');
		}
	}
	
	function __parseResponse<T>(expectedSignature:Signature, message:Message):Promise<T> {
		return switch message.signature {
			case []: 
				new Error('Unexpected empty return');
			case [sig]:
				if(sig.eq(expectedSignature))
					Promise.resolve(message.body[0]);
				else
					new Error('Unexpected return type, perhaps the definition is wrong? Expected "${expectedSignature.toSingleTypeCode()}", got "${why.dbus.Signature.SignatureTools.toTypeCode(message.signature)}"');
			case v:
				new Error('Multi-return is not supported.');
		}
	}
}