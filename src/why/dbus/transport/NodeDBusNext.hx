package why.dbus.transport;

import why.dbus.types.Variant;
import why.dbus.Message;
import why.dbus.Transport;
import why.dbus.Signature;
import haxe.DynamicAccess;

using tink.CoreApi;

class NodeDBusNext implements Transport {
	public final signals:Signal<IncomingSignalMessage>;
	final bus:DBus;
	
	public function new(bus) {
		this.bus = bus;
		
		this.signals = new Signal(cb -> {
			bus.on('message', function onMessage(message:NativeMessage) {
				switch message.type {
					case Signal: cb((message:IncomingSignalMessage));
					case _: // swallow
				}
			});
			() -> bus.off('message', onMessage);
		});
	}
	
	public static inline function systemBus()
		return new NodeDBusNext(DBus.systemBus());
	
	public static inline function sessionBus(?opt)
		return new NodeDBusNext(DBus.sessionBus(opt));
	
	public function call(message:OutgoingCallMessage, ?pos):Promise<IncomingReturnMessage> {
		return Promise.ofJsPromise(
			bus.call((message:NativeMessage)),
			e -> switch Std.downcast(e, DBusError) {
				case null:
					tink.core.Error.ofJsError(e);
				case e:
					new why.dbus.Error(500, e.text, {type: e.type, message: ((e.reply:NativeMessage):IncomingErrorMessage)}, pos);
			}
		).next((native:NativeMessage) -> (native:IncomingReturnMessage));
	}
}

@:forward
abstract NativeMessage(DBusMessage) from DBusMessage to DBusMessage {
	
	function denativizeBody():Array<Any> {
		var i = 0;
		return [for(s in (cast this.signature:SignatureCode)) fromNativeValue(s, this.body[i++])];
	}
	
	static function nativizeBody(message:Message):Array<Any> {
		var i = 0;
		return [for(s in message.signature) nativizeValue(s, message.body[i++])];
	}
	
	@:to
	function toCallMessage():IncomingCallMessage {
		return {
			path: this.path,
			iface: Reflect.field(this, 'interface'),
			member: this.member,
			signature: cast this.signature,
			body: denativizeBody(),
		}
	}
	
	@:to
	function toReturnMessage():IncomingReturnMessage {
		return {
			signature: cast this.signature,
			body: denativizeBody(),
		}
	}
	
	@:to
	function toErrorMessage():IncomingErrorMessage {
		return {
			errorName: this.errorName,
			signature: cast this.signature,
			body: denativizeBody(),
		}
	}
	
	@:to
	function toSignalMessage():IncomingSignalMessage {
		return {
			sender: this.sender,
			path: this.path,
			iface: Reflect.field(this, 'interface'),
			member: this.member,
			signature: cast this.signature,
			body: denativizeBody(),
		}
	}
	
	@:from
	static function fromCallMessage(message:OutgoingCallMessage):NativeMessage {
		return new DBusMessage({
			type: MessageType.MethodCall,
			destination: message.destination,
			path: message.path,
			'interface': message.iface,
			member: message.member,
			signature: message.signature,
			body: nativizeBody(message),
		});
	}
	
	@:from
	static function fromReturnMessage(message:OutgoingReturnMessage):NativeMessage {
		return new DBusMessage({
			type: MessageType.MethodReturn,
			signature: message.signature,
			body: nativizeBody(message),
		});
	}
	
	@:from
	static function fromSignalMessage(message:OutgoingSignalMessage):NativeMessage {
		return new DBusMessage({
			type: MessageType.Signal,
			path: message.path,
			'interface': message.iface,
			member: message.member,
			signature: message.signature,
			body: nativizeBody(message),
		});
	}
	
	@:from
	static function fromErrorMessage(message:OutgoingErrorMessage):NativeMessage {
		return new DBusMessage({
			type: MessageType.Error,
			errorName: message.errorName,
			signature: message.signature,
			body: {
				var i = 0;
				[for(s in message.signature) nativizeValue(s, message.body[i++])];
			},
		});
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	// static function toNativeMessage(message:Message):DBusMessage {
	// 	return new DBusMessage({
	// 		type: message.type,
	// 		serial: message.serial,
	// 		destination: message.destination,
	// 		path: message.path,
	// 		'interface': message.iface,
	// 		member: message.member,
	// 		signature: message.signature,
	// 		body: {
	// 			var i = 0;
	// 			[for(s in message.signature) nativizeValue(s, message.body[i++])];
	// 		},
	// 		errorName: message.errorName,
	// 		replySerial: message.replySerial,
	// 		flags: message.flags,
	// 	});
	// }
	
	// static function fromNativeMessage(message:DBusMessage):Message {
	// 	// js.Node.console.log(js.node.Util.inspect(message, false, null, true));
	// 	return {
	// 		type: message.type,
	// 		serial: message.serial,
	// 		destination: message.destination,
	// 		path: message.path,
	// 		iface: message.iface,
	// 		member: message.member,
	// 		signature: cast message.signature,
	// 		body: {
	// 			var i = 0;
	// 			[for(s in (cast message.signature:SignatureCode)) fromNativeValue(s, message.body[i++])];
	// 		},
	// 		errorName: message.errorName,
	// 		replySerial: message.replySerial,
	// 		flags: message.flags,
	// 	}
	// }
	
	static function nativizeValue(signature:Signature, value:Any):Any {
		return switch signature {
			case Array(DictEntry(ObjectPath | String, s)):
				final obj = new DynamicAccess<Any>();
				for(k => v in (value:Map<String, Any>)) obj.set(k, nativizeValue(s, v));
				obj;
			case Array(DictEntry(Byte | Int16 | UInt16 | Int32 | UInt32, s)):
				final obj = new DynamicAccess<Any>();
				for(k => v in (value:Map<Int, Any>)) obj.set(cast k, nativizeValue(s, v));
				obj;
			case Array(Byte):
				(value:tink.Chunk).toBuffer();
			case Array(s):
				(value:Array<Any>).map(nativizeValue.bind(s));
			case Variant:
				final value:Variant = value;
				new DBusVariant(value.signature, nativizeValue(value.signature, value.value));
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
			case Array(DictEntry(Byte | Int16 | UInt16 | Int32 | UInt32, s)):
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
	final sender:String;
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