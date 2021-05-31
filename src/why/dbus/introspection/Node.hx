package why.dbus.introspection;

typedef Node = {
	@:list('interface') var interfaces:Array<Interface>;
	@:list('node') var children:Array<Child>;
}

typedef Child = {
	@:attr var name:String;
}