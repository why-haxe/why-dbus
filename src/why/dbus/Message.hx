package why.dbus;

@:structInit
class Message {
	public final signature:Signature.SignatureCode;
	public final body:Array<Any>;
}

@:structInit
class OutgoingCallMessage extends Message {
	public final destination:String;
	public final path:String;
	public final iface:String;
	public final member:String;
}

@:structInit
class IncomingCallMessage extends Message {
	public final path:String;
	public final iface:String;
	public final member:String;
}


typedef IncomingReturnMessage = Message;
typedef OutgoingReturnMessage = Message;

@:structInit
class IncomingSignalMessage extends Message {
	public final sender:String;
	public final path:String;
	public final iface:String;
	public final member:String;
}

@:structInit
class OutgoingSignalMessage extends Message {
	public final path:String;
	public final iface:String;
	public final member:String;
}

@:structInit
private class ErrorMessage extends Message {
	public final errorName:String;
}

typedef IncomingErrorMessage = ErrorMessage;
typedef OutgoingErrorMessage = ErrorMessage;

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