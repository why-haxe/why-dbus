package;

import why.dbus.*;

using tink.CoreApi;

@:asserts
class ObjectTest {
	public function new() {}
	
	public function method() {
		final cnx = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		final obj = cnx.getInterface('org.freedesktop.DBus', '/org/freedesktop/DBus', org.freedesktop.DBus);
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
	
	public function property() {
		final cnx = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		final obj = cnx.getInterface('org.freedesktop.DBus', '/org/freedesktop/DBus', org.freedesktop.DBus);
		obj.interfaces.get()
			.next(values -> {
				trace(values);
				for(v in values) asserts.assert(Std.is(v, String));
				Noise;
			})
			.handle(asserts.handle);
		return asserts;
	}
	
	public function signal() {
		final cnx = new why.dbus.Connection(why.dbus.transport.NodeDBusNext.sessionBus());
		final obj = cnx.getInterface('org.freedesktop.DBus', '/org/freedesktop/DBus', org.freedesktop.DBus);
		
		var nameLostFired = false;
		var nameAcquiredFired = false;
		
		obj.nameLost.handle(v -> nameLostFired = true);
		obj.nameAcquired.handle(v -> nameAcquiredFired = true);
		obj.requestName('why.dbus.Test', 0)
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
		final obj = cnx.getInterface('org.freedesktop.DBus', '/org/freedesktop/DBus', org.freedesktop.DBus.Properties);
		obj.getAll('org.freedesktop.DBus')
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