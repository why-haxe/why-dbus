package why.dbus;

class Error extends tink.core.Error.TypedError<{
	final type:String;
	final message:Message;
}> {
	public function new(code, message, data, ?pos) {
		super(code, message, pos);
		this.data = data;
	}
}