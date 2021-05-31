package why.dbus.introspection;

typedef Method = {
	@:attr var name:String;
	@:list('arg') var args:Array<MethodArg>;
}

typedef MethodArg = {
	@:attr var name:String;
	@:attr var type:String;
	@:attr var direction:String;
}