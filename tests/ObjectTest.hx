package;

import why.dbus.*;

using tink.CoreApi;

@:asserts
class ObjectTest {
	public function new() {}
	
	public function method() {
		final cnx = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		final obj = cnx.getDestination('org.freedesktop.DBus').getObject('/org/freedesktop/DBus');
		final iface = obj.getInterface(org.freedesktop.DBus);
		iface.listNames()
			.next(names -> {
				for(name in names) asserts.assert(Std.is(name, String));
				iface.getConnectionUnixProcessID(names[0]);
			})
			.next(pid -> {
				asserts.assert(Std.is(pid, Int));
				Noise;
			})
			.handle(asserts.handle);
		return asserts;
	}
	
	public function property() {
		final cnx = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		final obj = cnx.getDestination('org.freedesktop.DBus').getObject('/org/freedesktop/DBus');
		final iface = obj.getInterface(org.freedesktop.DBus);
		iface.interfaces.get()
			.next(values -> {
				// trace(values);
				for(v in values) asserts.assert(Std.is(v, String));
				Noise;
			})
			.handle(asserts.handle);
		return asserts;
	}
	
	public function signal() {
		final cnx = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		final obj = cnx.getDestination('org.freedesktop.DBus').getObject('/org/freedesktop/DBus');
		final iface = obj.getInterface(org.freedesktop.DBus);
		
		var nameLostFired = false;
		var nameAcquiredFired = false;
		
		iface.nameLost.handle(v -> nameLostFired = true);
		iface.nameAcquired.handle(v -> nameAcquiredFired = true);
		iface.requestName('why.dbus.Test', 0)
			.next(_ -> Future.delay(500, Noise))
			.next(_ -> {
				asserts.assert(!nameLostFired);
				asserts.assert(nameAcquiredFired);
			})
			.handle(asserts.handle);
		return asserts;
	}
	
	public function rawProperty() {
		final cnx = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		final obj = cnx.getDestination('org.freedesktop.DBus').getObject('/org/freedesktop/DBus');
		final iface = obj.getInterface(org.freedesktop.DBus.Properties);
		iface.getAll('org.freedesktop.DBus')
			.next(map -> {
				final features = map['Features'];
				asserts.assert(features.signature == 'as');
				for(v in (features.value:Array<String>)) asserts.assert(Std.is(v, String));
				
				final ifaces = map['Interfaces'];
				asserts.assert(ifaces.signature == 'as');
				for(v in (ifaces.value:Array<String>)) asserts.assert(Std.is(v, String));
				
				Noise;
			})
			.handle(asserts.handle);
		return asserts;
	}
}