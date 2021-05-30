package;

import deepequal.DeepEqual.compare;
import why.dbus.Signature;

@:asserts
class SignatureTest {
	public function new() {}
	
	@:variant('ii', [Int32, Int32])
	@:variant('as', [Array(String)])
	@:variant('a{is}', [Array(DictEntry(Int32, String))])
	@:variant('(ss)', [Struct([String, String])])
	@:variant('(a{is}a{is})', [Struct([Array(DictEntry(Int32, String)), Array(DictEntry(Int32, String))])])
	public function parse(code:String, sigs:Array<Signature>) {
		final parsed = SignatureCode.parse(code).sure();
		
		asserts.assert(compare(parsed, sigs));
		
		for(i in 0...sigs.length)
			asserts.assert(sigs[i].eq(parsed[i]));
		
		asserts.assert((sigs:SignatureCode) == code);
		return asserts.done();
	}
}