package why.dbus.transport;

import why.dbus.Message;
import why.dbus.Transport;
import why.dbus.Signature;
import haxe.DynamicAccess;

using tink.CoreApi;

class NodeDBusNext implements Transport {
	public final signals:Signal<Message>;
	final bus:DBus;
	
	public function new(bus) {
		this.bus = bus;
		
		this.signals = new Signal(cb -> {
			bus.on('message', function onMessage(message) switch fromNativeMessage(message) {
				case Success(msg) if(msg.type == Signal): cb(msg);
				case _: // swallow
			});
			() -> bus.off('message', onMessage);
		});
	}
	
	public static inline function systemBus()
		return new NodeDBusNext(DBus.systemBus());
	
	public static inline function sessionBus(?opt)
		return new NodeDBusNext(DBus.sessionBus(opt));
	
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
			body: [for(i => s in message.signature) toNativeValue(s, message.body[i])],
			errorName: message.errorName,
			replySerial: message.replySerial,
			flags: message.flags,
		});
	}
	
	static function fromNativeMessage(message:DBusMessage):Outcome<Message, Error> {
		return tink.core.Error.catchExceptions(() -> {
			final signature = SignatureTools.fromTypeCode(message.signature).sure();
			({
				type: message.type,
				serial: message.serial,
				destination: message.destination,
				path: message.path,
				iface: message.iface,
				member: message.member,
				signature: signature,
				body: [for(i => s in signature) fromNativeValue(s, message.body[i])],
				errorName: message.errorName,
				replySerial: message.replySerial,
				flags: message.flags,
			}:Message);
		});
	}
	
	static function toNativeValue(signature:Signature, value:Dynamic):Dynamic {
		return switch signature {
			case Array(DictEntry(ObjectPath | String, s)):
				final obj = new DynamicAccess<Dynamic>();
				for(k => v in (value:Map<String, Dynamic>)) obj.set(k, toNativeValue(s, v));
				obj;
			case Array(Byte):
				js.node.Buffer.hxFromBytes(value);
			case Variant:
				final value:Variant = value;
				new DBusVariant(value.signature.toSingleTypeCode(), value.value);
			case _:
				value;
		}
	}
	
	static function fromNativeValue(signature:Signature, value:Dynamic):Dynamic {
		return switch signature {
			case Array(DictEntry(ObjectPath | String, s)):
				final map = new Map<String, Dynamic>();
				for(k => v in (value:DynamicAccess<Dynamic>)) map.set(k, fromNativeValue(s, v));
				map;
			case Array(Byte):
				((value:js.node.Buffer)).hxToBytes();
			case Variant:
				final value:DBusVariant = value;
				new Variant(SignatureTools.fromTypeCode(value.signature).sure()[0], value.value);
			case _:
				value;
		}
	}
}

@:jsRequire('dbus-next')
private extern class DBus {
	static function systemBus():DBus;
	static function sessionBus(?opt:{}):DBus;
	function call(message:DBusMessage):js.lib.Promise<DBusMessage>;
	function on(name:String, f:haxe.Constraints.Function):Void;
	function off(name:String, f:haxe.Constraints.Function):Void;
}

@:jsRequire('dbus-next', 'Variant')
private extern class DBusVariant {
	final signature:String;
	final value:Dynamic;
	function new(s:String, v:Dynamic);
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