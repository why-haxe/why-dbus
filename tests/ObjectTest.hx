package;

import why.dbus.*;

using tink.CoreApi;

@:asserts
class ObjectTest {
	public function new() {}
	
	public function test() {
		final transport = why.dbus.transport.NodeDBusNext.sessionBus();
		final obj:Interface<org.freedesktop.DBus> = new Object<org.freedesktop.DBus>(transport, 'org.freedesktop.DBus', '/org/freedesktop/DBus');
		obj.listNames()
			.next(names -> {
				for(name in names) asserts.assert(Std.is(name, String));
				obj.getConnectionUnixProcessID(names[0]);
			})
			.next(pid -> {
				asserts.assert(Std.is(pid, Int));
				Noise;
			})
			.handle(asserts.handle);
		return asserts;
	}
}