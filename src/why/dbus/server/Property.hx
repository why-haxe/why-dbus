package why.dbus.server;

using tink.CoreApi;

typedef Property<T> = ReadWriteProperty<T>;
typedef ReadWriteProperty<T> = ReadableProperty<T> & WritableProperty<T>;

typedef ReadableProperty<T> = {
	function get():Promise<T>;
}

typedef WritableProperty<T> = {
	function set(value:T):Promise<Noise>;
}