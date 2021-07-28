package why.dbus.client;

import why.dbus.types.Variant;

using tink.CoreApi;

class Property<T> implements ReadWriteProperty<T> {
	public final iface:String;
	public final name:String;
	public final signature:Signature.SignatureCode;
	public final changed:Signal<T>;
	
	final optional:Bool;
	final properties:Interface<org.freedesktop.DBus.Properties>;
	
	public function new(properties, iface, name, signature, optional) {
		this.properties = properties;
		this.iface = iface;
		this.name = name;
		this.signature = signature;
		this.optional = optional;
		this.changed = properties.propertiesChanged.select(v -> {
			if(v.v0 == iface) {
				switch v.v1.get(name) {
					case null: None;
					case variant: Some((variant.value:T));
				}
			} else {
				None;
			}
		});
	}
	
	public function get():Promise<T> {
		final value = properties.get(iface, name)
			.next(v -> v.signature == signature ? Promise.resolve((v.value:T)) : new Error('Unexpected return type. Expected "$signature" but got "${v.signature}"'));
		
		return
			if(optional) 
				value.tryRecover(e -> switch Std.downcast(e, why.dbus.Error) {
					case null: e;
					case err if(err.data.type == 'org.freedesktop.DBus.Error.InvalidArgs'): cast Promise.NOISE;
					case _: e;
				});
			else
				value;
	}
	
	public function set(value:T):Promise<Noise> {
		return properties.set(iface, name, new Variant(signature, value));
	
	}
}

interface ReadWriteProperty<T> extends ReadableProperty<T> extends WritableProperty<T> {}

interface ReadableProperty<T> extends PropertyBase {
	final changed:Signal<T>;
	function get():Promise<T>;
}

interface WritableProperty<T> extends PropertyBase {
	function set(value:T):Promise<Noise>;
}

interface PropertyBase {
	// public final path:String;
	public final iface:String;
	public final name:String;
	public final signature:Signature.SignatureCode;
}