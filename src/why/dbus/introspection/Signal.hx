package why.dbus.introspection;

typedef Signal = {
	@:attr var name:String;
	@:list('arg') var args:Array<SignalArg>;
}

typedef SignalArg = {
	@:attr var name:String;
	@:attr var type:String;
}