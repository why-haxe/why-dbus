package why.dbus;

#if macro
using tink.MacroApi;
#end

import String.*;
using tink.CoreApi;

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
	public static function fromTypeCode(s:String):Outcome<Array<Signature>, Error> {
		var pos = 0;
		
		inline function eof() return pos >= s.length;
		inline function peek() return s.charCodeAt(pos);
		inline function next() return s.charCodeAt(pos++);
		inline function expect(code) return if(next() != code) throw 'expected "${fromCharCode(code)}"';
		
		function parse() {
			return switch next() {
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
					while(!eof()) {
						if(peek() == ')'.code) {pos++; break;}
						types.push(parse());
					}
					Struct(types);
				case 'a'.code:
					Array(parse());
				case '{'.code:
					final key = parse();
					final value = parse();
					expect('}'.code);
					DictEntry(key, value);
				case v:
					throw 'unexpected "${fromCharCode(v)}"';
			}
		}
		
		return Error.catchExceptions(() -> [while(!eof()) parse()]);
	}
	
	public static function toTypeCode(s:Array<Signature>):String {
		final buf = new StringBuf();
		for(s in s) buf.add(toSingleTypeCode(s));
		return buf.toString();
	}
	
	public static function toSingleTypeCode(s:Signature):String {
		return switch s {
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
			case Struct(types): '(${types.map(toSingleTypeCode).join('')})';
			case Array(type): 'a' + toSingleTypeCode(type);
			case DictEntry(key, value): '{${toSingleTypeCode(key)}${toSingleTypeCode(value)}}';
		}
	}
	
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
	
	#if macro
	public static function fromType(type:haxe.macro.Type):Option<Signature> {
		return switch type.reduce() {
			case _.getID() => 'Void': None;
			case _.getID() => 'Bool': Some(Boolean);
			case _.getID() => 'Int': Some(Int32);
			case _.getID() => 'UInt': Some(UInt32);
			case _.getID() => 'Float': Some(Double);
			case _.getID() => 'String': Some(String);
			case _.getID() => 'haxe.io.Bytes': Some(Array(Byte));
			case _.getID() => 'why.dbus.Variant': Some(Variant);
			case TInst(_.get() => {name: 'Array', pack: []}, [v]): Some(Array(fromType(v).force()));
			case TAbstract(_.get() => {name: 'Map', pack: ['haxe', 'ds']}, [k, v]): Some(Array(DictEntry(fromType(k).force(), fromType(v).force())));
			case v: throw '$v not supported';
		}
	}
	#end
}