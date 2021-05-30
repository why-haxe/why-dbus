package why.dbus;

@:structInit
class Message {
	public final type:MessageType;
	@:optional public final serial:Int;
	@:optional public final destination:String;
	@:optional public final path:String;
	@:optional public final iface:String;
	@:optional public final member:String;
	@:optional public final signature:Array<Signature>;
	@:optional public final body:Array<Dynamic>;
	@:optional public final errorName:String;
	@:optional public final replySerial:String;
	@:optional public final flags:Int;
}

enum abstract MessageType(Int) to Int {
	final MethodCall = 1;
	final MethodReturn = 2;
	final Error = 3;
	final Signal = 4;
	
	public function toString() {
		return switch (cast this:MessageType) {
			case MethodCall: 'method_call';
			case MethodReturn: 'method_return';
			case Error: 'error';
			case Signal: 'signal';
		}
	}
}

enum abstract MessageFlag(Int) to Int {
	final NoReplyExpected = 1;
	final NoAutoStart = 2;
	final Async = 64;
	
}