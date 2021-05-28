package why.dbus;

@:forward
abstract Variant(VariantObject) from VariantObject to VariantObject {}

typedef VariantObject = {
	final signature:Signature;
	final value:Dynamic;
}