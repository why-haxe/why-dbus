package why.dbus.introspection;

using tink.CoreApi;

@:forward
abstract Introspection(Node) from Node to Node {
	public static inline function parse(xml:String):Outcome<Introspection, Error> {
		return cast new tink.xml.Structure<Node>().read(xml);
	}
}