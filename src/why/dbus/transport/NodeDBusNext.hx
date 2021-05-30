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
	
	static function toNativeValue(signature:Signature, value:Dynamic):Dynamic {
		return switch signature {
			case Array(DictEntry(ObjectPath | String, s)):
				final obj = new DynamicAccess<Dynamic>();
				for(k => v in (value:Map<String, Dynamic>)) obj.set(k, toNativeValue(s, v));
				obj;
			case Array(DictEntry(Int16 | UInt16 | Int32 | UInt32, s)):
				final obj = new DynamicAccess<Dynamic>();
				for(k => v in (value:Map<Int, Dynamic>)) obj.set(cast k, toNativeValue(s, v));
				obj;
			case Array(Byte):
				js.node.Buffer.hxFromBytes(value);
			case Array(s):
				(value:Array<Dynamic>).map(toNativeValue.bind(s));
			case Variant:
				final value:Variant = value;
				new DBusVariant(value.signature, toNativeValue(value.signature, value.value));
			case _:
				value;
		}
	}
	
	static function fromNativeValue(signature:Signature, value:Dynamic):Dynamic {
		return switch signature {
			case Array(DictEntry(ObjectPath | String, s)):
				final map = new Map<String, Dynamic>();
				for(k => v in (value:DynamicAccess<Any>)) map.set(k, fromNativeValue(s, v));
				map;
			case Array(DictEntry(Int16 | UInt16 | Int32 | UInt32, s)):
				final map = new Map<Int, Dynamic>();
				for(k => v in (value:DynamicAccess<Dynamic>)) map.set(Std.parseInt(k), fromNativeValue(s, v));
				map;
			case Array(Byte):
				((value:js.node.Buffer)).hxToBytes();
			case Array(s):
				(value:Array<Dynamic>).map(fromNativeValue.bind(s));
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