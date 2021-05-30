package why.dbus.types;

@:forward
abstract Variant(VariantObject) from VariantObject to VariantObject {
	public inline function new(signature, value) {
		this = {
			signature: signature,
			value: value,
		}
	}
}

typedef VariantObject = {
	final signature:Signature.SignatureCode;
	final value:Dynamic;
}