package why.dbus.server;

using tink.CoreApi;

typedef Getter<T> = () -> Promise<T>;
typedef Setter<T> = T->Promise<Noise>;

class SimpleProperty<T> extends Property<T> {
	var value:T;
	public function new(value:T) {
		super(
			() -> {
				Promise.resolve(value);
			},
			v -> {
				value = v;
				Promise.NOISE;
			}
		);
	}
}
class ClassicProperty<T> extends Property<T> {
	public function new(get:()->T, set:T->Void) {
		super(
			() -> {
				Promise.resolve(get());
			},
			v -> {
				set(v);
				Promise.NOISE;
			}
		);
	}
}

class Property<T> implements ReadWriteProperty<T> {
	public final changed:Signal<T>;
	final _get:Getter<T>;
	final _set:Setter<T>;
	final _changed:SignalTrigger<T>;
	public function new(get, set) {
		_get = get;
		_set = set;
		changed = _changed = Signal.trigger();
	}
	public function get():Promise<T> {
		return _get();
	}
	public function set(v:T):Promise<Noise> {
		_changed.trigger(v);
		return _set(v);
	}
}

interface ReadWriteProperty<T> extends ReadableProperty<T> extends WritableProperty<T> {}

interface ReadableProperty<T> {
	final changed:Signal<T>;
	function get():Promise<T>;
}

interface WritableProperty<T> {
	function set(value:T):Promise<Noise>;
}