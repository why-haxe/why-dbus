package why.dbus.transport;

import why.dbus.Message;
import why.dbus.Transport;
import why.dbus.Signature;

using tink.CoreApi;

class NodeDBusNext implements Transport {
	
	final bus:DBus;
	
	public function new(bus) {
		this.bus = bus;
	}
	
	public static inline function sessionBus()
		return new NodeDBusNext(DBus.sessionBus());
	
	public function call(message:Message):Promise<Message> {
		return Promise.ofJsPromise(bus.call(toNativeMessage(message))).next(fromNativeMessage);
	}
	
	static function toNativeMessage(message:Message):DBusMessage {
		return new DBusMessage({
			type: message.type,
			serial: message.serial,
			destination: message.destination,
			path: message.path,
			'interface': message.iface,
			member: message.member,
			signature: SignatureTools.toTypeCode(message.signature),
			body: message.body,
			errorName: message.errorName,
			replySerial: message.replySerial,
			flags: message.flags,
		});
	}
	
	static function fromNativeMessage(message:DBusMessage):Outcome<Message, Error> {
		return SignatureTools.fromTypeCode(message.signature).map(signature -> ({
			type: message.type,
			serial: message.serial,
			destination: message.destination,
			path: message.path,
			iface: message.iface,
			member: message.member,
			signature: signature,
			body: message.body,
			errorName: message.errorName,
			replySerial: message.replySerial,
			flags: message.flags,
		}:Message));
	}
}

@:jsRequire('dbus-next')
private extern class DBus {
	static function sessionBus():DBus;
	function call(message:DBusMessage):js.lib.Promise<DBusMessage>;
}

@:jsRequire('dbus-next', 'Message')
private extern class DBusMessage {
	final type:MessageType;
	final serial:Int;
	final destination:String;
	final path:String;
	@:native('interface') final iface:String;
	final member:String;
	final signature:String;
	final body:Array<Dynamic>;
	final errorName:String;
	final replySerial:String;
	final flags:Int;
	
	function new(opt:{});
}