package;

import why.dbus.*;
import why.dbus.types.*;

using tink.CoreApi;

@:asserts
class ServerTest {
	public function new() {}
	
	public function test() {
		final cnx1 = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		final cnx2 = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		
		
		final obj = cnx1.getObject('org.freedesktop.DBus', '/org/freedesktop/DBus');
		final iface = obj.getInterface(org.freedesktop.DBus);
		
		iface.requestName('why.dbus.ServerTest', 0)
			.next(_ -> cnx1.exportInterface('/path/to/object', (new CustomServiceImpl():foo.CustomService)))
			.next(_ -> {
				final obj = cnx2.getObject('why.dbus.ServerTest', '/path/to/object');
				final iface = obj.getInterface(foo.CustomService);
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


