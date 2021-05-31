package why.dbus.transport;

import why.dbus.types.Variant;
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
				case msg = {type: Signal}: cb(msg);
				case _: // swallow
			});
			() -> bus.off('message', onMessage);
		});
	}
	
	public static inline function systemBus()
		return new NodeDBusNext(DBus.systemBus());
	
	public static inline function sessionBus(?opt)
		return new NodeDBusNext(DBus.sessionBus(opt));
	
	public function call(message:Message, ?pos):Promise<Message> {
		return Promise.ofJsPromise(
			bus.call(toNativeMessage(message)),
			e -> switch Std.downcast(e, DBusError) {
				case null:
					tink.core.Error.ofJsError(e);
				case e:
					new why.dbus.Error(500, e.text, {type: e.type, message: fromNativeMessage(e.reply)}, pos);
			}
		).next(fromNativeMessage);
	}
	
	static function toNativeMessage(message:Message):DBusMessage {
		return new DBusMessage({
			type: message.type,
			serial: message.serial,
			destination: message.destination,
			path: message.path,
			'interface': message.iface,
			member: message.member,
			signature: message.signature,
			body: {
				var i = 0;
				[for(s in message.signature) toNativeValue(s, message.body[i++])];
			},
			errorName: message.errorName,
			replySerial: message.replySerial,
			flags: message.flags,
		});
	}
	
	static function fromNativeMessage(message:DBusMessage):Message {
		return {
			type: message.type,
			serial: message.serial,
			destination: message.destination,
			path: message.path,
			iface: message.iface,
			member: message.member,
			signature: cast message.signature,
			body: {
				var i = 0;
				[for(s in (cast message.signature:SignatureCode)) fromNativeValue(s, message.body[i++])];
			},
			errorName: message.errorName,
			replySerial: message.replySerial,
			flags: message.flags,
		}
	}
	
	static function toNativeValue(signature:Signature, value:Any):Any {
		return switch signature {
			case Array(DictEntry(ObjectPath | String, s)):
				final obj = new DynamicAccess<Any>();
				for(k => v in (value:Map<String, Any>)) obj.set(k, toNativeValue(s, v));
				obj;
			case Array(DictEntry(Int16 | UInt16 | Int32 | UInt32, s)):
				final obj = new DynamicAccess<Any>();
				for(k => v in (value:Map<Int, Any>)) obj.set(cast k, toNativeValue(s, v));
				obj;
			case Array(Byte):
				(value:tink.Chunk).toBuffer();
			case Array(s):
				(value:Array<Any>).map(toNativeValue.bind(s));
			case Variant:
				final value:Variant = value;
				new DBusVariant(value.signature, toNativeValue(value.signature, value.value));
			case _:
				value;
		}
	}
	
	static function fromNativeValue(signature:Signature, value:Any):Any {
		return switch signature {
			case Array(DictEntry(ObjectPath | String, s)):
				final map = new Map<String, Any>();
				for(k => v in (value:DynamicAccess<Any>)) map.set(k, fromNativeValue(s, v));
				map;
			case Array(DictEntry(Int16 | UInt16 | Int32 | UInt32, s)):
				final map = new Map<Int, Any>();
				for(k => v in (value:DynamicAccess<Any>)) map.set(Std.parseInt(k), fromNativeValue(s, v));
				map;
			case Array(Byte):
				tink.Chunk.ofBuffer(value);
			case Array(s):
				(value:Array<Any>).map(fromNativeValue.bind(s));
			case Variant:
				final value:DBusVariant = value;
				final sig:SignatureCode = cast value.signature;
				new Variant(sig, fromNativeValue(sig, value.value));
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
	final value:Any;
	function new(s:String, v:Any);
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
	final body:Array<Any>;
	final errorName:String;
	final replySerial:String;
	final flags:Int;
	
	function new(opt:{});
}

@:jsRequire('dbus-next', 'DBusError')
private extern class DBusError {
	final type:String;
	final text:String;
	final reply:DBusMessage;
}