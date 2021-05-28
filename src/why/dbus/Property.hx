package why.dbus;

using tink.CoreApi;

class Property<T> extends why.dbus.Object.ObjectBase implements ReadableProperty<T> implements WritableProperty<T> {
	
	final __iface:String;
	final __name:String;
	final __signature:Signature;
	
	public function new(transport, destination, path, iface, name, signature) {
		super(transport, destination, path);
		__iface = iface;
		__name = name;
		__signature = signature;
	}
	
	public function get():Promise<T> {
		return __transport.call({
			type: MethodCall,
			destination: __destination,
			path: __path,
			iface: 'org.freedesktop.DBus.Properties',
			signature: [String, String],
			body: [__iface, __name],
			member: 'Get',
		}).next(msg -> {
			final v:Variant = msg.body[0];
			if(v.signature.eq(__signature)) Promise.resolve(v.value);
			else new Error('Unexpected return type. Expected "${__signature.toSingleTypeCode()}" but got "${v.signature.toSingleTypeCode()}"');
		});
	}
	
	public function set(value:T):Promise<Noise> {
		return __transport.call({
			type: MethodCall,
			destination: __destination,
			path: __path,
			iface: 'org.freedesktop.DBus.Properties',
			signature: [String, String, __signature],
			body: [__iface, __name, value],
			member: 'Set',
		}).noise();
	}
}

interface ReadableProperty<T> {
	function get():Promise<T>;
}

interface WritableProperty<T> {
	function set(value:T):Promise<Noise>;
}