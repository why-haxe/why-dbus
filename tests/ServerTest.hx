package;

import why.dbus.*;
import why.dbus.types.*;
import why.dbus.server.Property;

using tink.CoreApi;

@:asserts
class ServerTest {
	public function new() {}
	
	public function test() {
		final server = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		final client = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		final path = '/path/to/object';
		
		
		final object = client.getDestination('why.dbus.ServerTest').getObject(path);
		
		// server.exportObject('/test/test', (null:org.freedesktop.DBus.ObjectManager));
		
		server.bus.requestName('why.dbus.ServerTest', 0)
			.next(_ -> server.exportObject(path, (new FooCustomService():foo.CustomService), (new BarCustomService():bar.CustomService)))
			.next(_ -> {
				final iface = object.getInterface(foo.CustomService);
				
				final changes = [];
				iface.foo.changed.handle(o -> changes.push(o));
				
				iface.getFoo()
					.next(v -> asserts.assert(v == 1))
					.next(_ -> iface.setFoo(2))
					.next(_ -> iface.getFoo())
					.next(v -> asserts.assert(v == 2))
					.next(_ -> iface.foo.get())
					.next(v -> asserts.assert(v == 2))
					.next(_ -> iface.foo.set(3))
					.next(_ -> iface.foo.get())
					.next(v -> asserts.assert(v == 3))
					.next(v -> asserts.assert(changes.join(',') == '2,3'));
			})
			.next(_ -> {
				final iface = object.getInterface(bar.CustomService);
				
				final changes = [];
				iface.bar.changed.handle(o -> changes.push(o));
				
				iface.getBar()
					.next(v -> asserts.assert(v == 42))
					.next(_ -> iface.setBar(43))
					.next(_ -> iface.getBar())
					.next(v -> asserts.assert(v == 43))
					.next(_ -> iface.bar.get())
					.next(v -> asserts.assert(v == 43))
					.next(_ -> iface.bar.set(44))
					.next(_ -> iface.bar.get())
					.next(v -> asserts.assert(v == 44))
					.next(v -> asserts.assert(changes.join(',') == '43,44'));
			})
			.next(_ -> {
				final iface = object.getInterface(org.freedesktop.DBus.Properties);
				iface.getAll('foo.CustomService')
					.next(v -> asserts.assert(v['Foo'].value == 3))
					.next(_ -> iface.get('foo.CustomService', 'Foo'))
					.next(v -> asserts.assert(v.value == 3));
			})
			.next(_ -> {
				final iface = object.getInterface(org.freedesktop.DBus.Properties);
				iface.getAll('bar.CustomService')
					.next(v -> asserts.assert(v['Bar'].value == 44))
					.next(_ -> iface.get('bar.CustomService', 'Bar'))
					.next(v -> asserts.assert(v.value == 44));
			})
			.handle(asserts.handle);
			
		
			
		return asserts;
	}
}


class FooCustomService implements why.dbus.server.Interface<foo.CustomService> {
	public final foo = {
		var ref:Ref<Int> = 1; // TODO: https://github.com/HaxeFoundation/haxe/issues/10335
		new Property(() -> ref.value, v -> {ref.value = v; Promise.NOISE;});
	}
	
	public function new() {}
	
	public function getFoo():Promise<Int> {
		return foo.get();
	}
	
	public function setFoo(v:Int):Promise<Noise> {
		return foo.set(v);
	}
}

class BarCustomService implements why.dbus.server.Interface<bar.CustomService> {
	public final bar = {
		var ref:Ref<Int> = 42; // TODO: https://github.com/HaxeFoundation/haxe/issues/10335
		new Property(() -> ref.value, v -> {ref.value = v; Promise.NOISE;});
	}
	
	public function new() {}
	
	public function getBar():Promise<Int> {
		return bar.get();
	}
	
	public function setBar(v:Int):Promise<Noise> {
		return bar.set(v);
	}
}


