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
		
		
		final obj = cnx1.getInterface('org.freedesktop.DBus', '/org/freedesktop/DBus', org.freedesktop.DBus);
		obj.requestName('why.dbus.ServerTest', 0)
			.next(_ -> cnx1.exportInterface('/path/to/object', (new CustomServiceImpl():foo.CustomService)))
			.next(_ -> {
				final obj = cnx2.getInterface('why.dbus.ServerTest', '/path/to/object', foo.CustomService);
				obj.getFoo()
					.next(v -> asserts.assert(v == 1))
					.next(_ -> obj.setFoo(2))
					.next(_ -> obj.getFoo())
					.next(v -> asserts.assert(v == 2))
					.next(_ -> obj.foo.get())
					.next(v -> asserts.assert(v == 2))
					.next(_ -> obj.foo.set(3))
					.next(_ -> obj.foo.get())
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


