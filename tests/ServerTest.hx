package;

import why.dbus.*;
import why.dbus.types.*;

using tink.CoreApi;

@:asserts
class ServerTest {
	public function new() {}
	
	public function test() {
		final server = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		final client = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		
		
		server.bus.requestName('why.dbus.ServerTest', 0)
			.next(_ -> server.exportInterface('/path/to/object', (new CustomServiceImpl():foo.CustomService)))
			.next(_ -> {
				final iface = client.getDestination('why.dbus.ServerTest').getObject('/path/to/object').getInterface(foo.CustomService);
				iface.getFoo()
					.next(v -> asserts.assert(v == 1))
					.next(_ -> iface.setFoo(2))
					.next(_ -> iface.getFoo())
					.next(v -> asserts.assert(v == 2))
					.next(_ -> iface.foo.get())
					.next(v -> asserts.assert(v == 2))
					.next(_ -> iface.foo.set(3))
					.next(_ -> iface.foo.get())
					.next(v -> asserts.assert(v == 3));
			})
			.handle(asserts.handle);
			
		
			
		return asserts;
	}
}


class CustomServiceImpl implements why.dbus.server.Interface<foo.CustomService> {
	var foo:Int = 1;
	
	public function new() {}
	
	public function getFoo():Promise<Int> {
		return foo;
	}
	
	public function setFoo(v:Int):Promise<Noise> {
		foo = v;
		return Noise;
	}
	
	public function get_foo():Promise<Int> {
		return getFoo();
	}
	
	public function set_foo(v:Int):Promise<Noise> {
		return setFoo(v);
	}
}


