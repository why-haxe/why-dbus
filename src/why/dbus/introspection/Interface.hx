package why.dbus.introspection;

typedef Interface = {
	@:attr var name:String;
	@:list('method') var methods:Array<Method>;
	@:list('property') var properties:Array<Property>;
	@:list('signal') var signals:Array<Signal>;
}