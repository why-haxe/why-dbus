package why.dbus;

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
	
	function __parseEmptyResponse(message:Message):Promise<Noise> {
		return switch message.signature {
			case []: 
				tink.core.Promise.NOISE;
			case sigs:
				new tink.core.Error('Unexpected return of type "${why.dbus.Signature.SignatureTools.toTypeCode(sigs)}" ');
		}
	}
	
	function __parseResponse<T>(expectedSignature:Signature, message:Message):Promise<T> {
		return switch message.signature {
			case []: 
				new tink.core.Error('Unexpected empty return');
			case [sig]:
				if(sig.eq(expectedSignature))
					tink.core.Promise.resolve(message.body[0]);
				else
					new tink.core.Error('Unexpected return type, perhaps the definition is wrong? Expected "${expectedSignature.toSingleTypeCode()}", got "${why.dbus.Signature.SignatureTools.toTypeCode(message.signature)}"');
			case v:
				new tink.core.Error('Multi-return is not supported.');
		}
	}
}