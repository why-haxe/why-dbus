package why.dbus;

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
}