package why.dbus;

import why.dbus.types.Variant;

using tink.CoreApi;

class Property<T> implements ReadWriteProperty<T> {
	public final iface:String;
	public final name:String;
	public final signature:Signature.SignatureCode;
	
	final prop:Interface<org.freedesktop.DBus.Properties>;
	
	public function new(transport, destination, path, iface, name, signature) {
		this.prop = new Object<org.freedesktop.DBus.Properties>(transport, destination, path);
		this.iface = iface;
		this.name = name;
		this.signature = signature;
	}
	
	public function get():Promise<T> {
		return prop.get(iface, name)
			.next(v -> v.signature == signature ? Promise.resolve((v.value:T)) : new Error('Unexpected return type. Expected "$signature" but got "${v.signature}"'));
	}
	
	public function set(value:T):Promise<Noise> {
		return prop.set(iface, name, new Variant(signature, value));
	}
}

interface ReadWriteProperty<T> extends ReadableProperty<T> extends WritableProperty<T> {}

interface ReadableProperty<T> extends PropertyBase {
	function get():Promise<T>;
}

interface WritableProperty<T> extends PropertyBase {
	function set(value:T):Promise<Noise>;
}

interface PropertyBase {
	public final iface:String;
	public final name:String;
	public final signature:Signature.SignatureCode;
}