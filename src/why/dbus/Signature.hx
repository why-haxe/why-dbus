package why.dbus;

#if macro
import why.dbus.macro.Helpers.*;
using tink.MacroApi;
#end

import String.*;

using Lambda;
using StringTools;
using tink.CoreApi;

@:forward(length)
enum abstract SignatureCode(String) to String {
	inline function new(v) {
		this = v;
	}
	
	public inline function isEmpty() {
		return this == '';
	}
	
	@:from static inline function ofSignatures(arr:Array<Signature>):SignatureCode {
		return arr.map(ofSignature);
	}
	
	@:from static function ofSignature(s:Signature):SignatureCode {
		return new SignatureCode(switch s {
			case Byte: 'y';
			case Boolean: 'b';
			case Int16: 'n';
			case UInt16: 'q';
			case Int32: 'i';
			case UInt32: 'u';
			case Int64: 'x';
			case UInt64: 't';
			case Double: 'd';
			case UnixFd: 'h';
			case String: 's';
			case ObjectPath: 'o';
			case Signature: 'g';
			case Variant: 'v';
			case Struct(types): '(${ofSignatures(types)})';
			case Array(type): 'a' + ofSignature(type);
			case DictEntry(key, value): '{${ofSignature(key)}${ofSignature(value)}}';
		});
	}
	
	@:from static inline function ofMany(arr:Array<SignatureCode>):SignatureCode {
		return new SignatureCode(arr.join(''));
	}
	
	@:to function toSignature():Signature {
		for(s in iterator()) return s;
		return null;
	}
	
	public inline function iterator():SignatureCodeIterator {
		return new SignatureCodeIterator(this);
	}
	
	public static function parse(v:String):Outcome<Array<Signature>, Error> {
		return Error.catchExceptions(() -> [for(s in (cast v:SignatureCode)) s]);
	}
	
	
	#if macro
	@:to
	function toExpr():haxe.macro.Expr {
		return macro @:privateAccess new why.dbus.Signature.SignatureCode($v{this});
	}
	
	@:from
	static function fromTypes(types:Array<haxe.macro.Type>):SignatureCode {
		return types.map(fromType);
	}
	
	@:from
	public static function fromType(type:haxe.macro.Type):SignatureCode {
		return switch type.reduce() {
			case _.getID() => 'Void':
				new SignatureCode('');
			case _.getID() => 'Bool':
				new SignatureCode('b');
				
			case _.getID() => 'why.dbus.types.Int16':
				new SignatureCode('n');
			case _.getID() => 'why.dbus.types.UInt16':
				new SignatureCode('q');
				
			case _.getID() => 'Int':
				new SignatureCode('i');
			case _.getID() => 'UInt':
				new SignatureCode('u');
			case _.getID() => 'Float':
				
				new SignatureCode('d');
			case _.getID() => 'String':
				
				new SignatureCode('s');
			case _.getID() => 'tink.Chunk':
				new SignatureCode('ay');
			case _.getID() => 'why.dbus.types.Variant':
				new SignatureCode('v');
			case _.getID() => 'why.dbus.types.ObjectPath':
				new SignatureCode('o');
				
			case TInst(_.get() => {name: 'Array', pack: []}, [v]):
				new SignatureCode('a${fromType(v)}');
			case TAbstract(_.get() => {name: 'Map', pack: ['haxe', 'ds']}, [k, v]):
				new SignatureCode('a{${fromType(k)}${fromType(v)}}');
			case getSignal(_) => Some(types):
				fromTypes(types);
			case v: throw '$v not supported';
		}
	}
	#end
}

class SignatureCodeIterator {
	final s:String;
	var pos:Int = 0;
	
	public inline function new(s) {
		this.s = s;
	}
	
	public inline function hasNext():Bool {
		return !_eof();
	}
	
	public inline function next():Signature {
		return _parse();
	}
	
	inline function _eof() return pos >= s.length;
	inline function _peek() return s.charCodeAt(pos);
	inline function _next() return s.charCodeAt(pos++);
	function _expect(code) return if(_next() != code) throw 'expected "${fromCharCode(code)}"';
	
	function _parse():Signature {
		return switch _next() {
			case 'y'.code: Byte;
			case 'b'.code: Boolean;
			case 'n'.code: Int16;
			case 'q'.code: UInt16;
			case 'i'.code: Int32;
			case 'u'.code: UInt32;
			case 'x'.code: Int64;
			case 't'.code: UInt64;
			case 'd'.code: Double;
			case 'h'.code: UnixFd;
			case 's'.code: String;
			case 'o'.code: ObjectPath;
			case 'g'.code: Signature;
			case 'v'.code: Variant;
			case '('.code:
				final types = [];
				while(!_eof()) {
					if(_peek() == ')'.code) {pos++; break;}
					types.push(_parse());
				}
				Struct(types);
			case 'a'.code:
				Array(_parse());
			case '{'.code:
				final key = _parse();
				final value = _parse();
				_expect('}'.code);
				DictEntry(key, value);
			case v:
				throw 'unexpected "${fromCharCode(v)}"';
		}
	}
}

@:using(why.dbus.Signature.SignatureTools)
enum Signature {
	Byte;
	Boolean;
	Int16;
	UInt16;
	Int32;
	UInt32;
	Int64;
	UInt64;
	Double;
	UnixFd;
	String;
	ObjectPath;
	Signature;
	Struct(types:Array<Signature>);
	Array(type:Signature);
	Variant;
	DictEntry(key:Signature, value:Signature);
}

class SignatureTools {
	// public static function toTypeCode(s:Array<Signature>):SignatureCode {
	// 	final buf = new StringBuf();
	// 	for(s in s) buf.add(toSingleTypeCode(s));
	// 	return buf.toString();
	// }
	
	
	public static function eq(s1:Signature, s2:Signature):Bool {
		return switch [s1, s2] {
			case [Struct(t1), Struct(t2)]:
				if(t1.length != t2.length) return false;
				for(i in 0...t1.length) if(!eq(t1[i], t2[i])) return false;
				true;
				
			case [Array(t1), Array(t2)]: eq(t1, t2);
			case [DictEntry(k1, v1), DictEntry(k2, v2)]: eq(k1, k2) && eq(v1, v2);
			
			case [Byte, Byte]
			| [Boolean, Boolean]
			| [Int16, Int16]
			| [UInt16, UInt16]
			| [Int32, Int32]
			| [UInt32, UInt32]
			| [Int64, Int64]
			| [UInt64, UInt64]
			| [Double, Double]
			| [UnixFd, UnixFd]
			| [String, String]
			| [ObjectPath, ObjectPath]
			| [Signature, Signature]
			| [Variant, Variant]: true;
			
			case _: false;
		}
	}
	
}